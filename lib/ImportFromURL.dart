import "./database.dart";
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import './models/FlashCard.dart';
import './models/Deck.dart';

Future<List<Deck>> getDeckList() async {
  List<Deck> deckList = await DBProvider.db.getAllDecks();
  return deckList;
}

// Create a Form Widget
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  Map<String, String> _urlForm = {
    "url": "",
  };

  @override
  initState() {
    super.initState();
  }

  Future<void> addCardToDeckId(FlashCard card, int deckId) async {
    int cardId = await DBProvider.db.insertFlashCard(card);
    await DBProvider.db
        .insertDeckToFlashCardById(deckId: deckId, cardId: cardId);
  }

  Future<int> buildDeckFromImport(parsed) async {
    Deck newDeck = new Deck(title: parsed["title"]);
    int newDeckId = await DBProvider.db.insertDeck(newDeck);
    var futures = <Future>[];
    parsed["cards"].forEach((card) {
      FlashCard thisCard = new FlashCard.fromMap(card);
      futures.add(addCardToDeckId(thisCard, newDeckId));
    });
    await Future.wait(futures);
    return newDeckId;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "URL",
                labelStyle: TextStyle(fontSize: 20),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a valid URL for import';
                }
                return null;
              },
              onSaved: (String value) {
                this._urlForm["url"] = value;
              }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  var response = await http.get(this._urlForm["url"]);
                  var parsed = json.decode(response.body);
                  int newDeckId = await buildDeckFromImport(parsed);
                  Navigator.pop(context, {
                    "deckId": newDeckId,
                  });
                }
              },
              child: Text("IMPORT"),
            ),
          ),
        ],
      ),
    );
  }
}

class ImportFromURL extends StatelessWidget {
  static const routeName = "/importFromURL";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add A Card'),
        ),
        body: SafeArea(
            child: Center(
                child: FractionallySizedBox(
                    widthFactor: 0.8,
                    heightFactor: 0.8,
                    child: Card(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          new Expanded(
                              flex: 1,
                              child: Center(
                                  child: SingleChildScrollView(
                                padding: EdgeInsets.all(24.0),
                                child: MyCustomForm(),
                              )))
                        ]))))));
  }
}
