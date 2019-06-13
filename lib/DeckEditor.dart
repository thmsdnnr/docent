import "./database.dart";
import 'package:flutter/material.dart';
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

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String> _deckData = {
    "title": "",
  };

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                labelText: "Title",
                labelStyle: TextStyle(fontSize: 20),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (String value) {
                this._deckData["title"] = value;
              }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Deck deckToSave = new Deck.fromMap(this._deckData);
                  int recordId = await DBProvider.db.insertDeck(deckToSave);
                  Navigator.pop(context, {"deckId": recordId});
                }
              },
              child: Text("SAVE"),
            ),
          ),
        ],
      ),
    );
  }
}

class DeckEditor extends StatelessWidget {
  static const routeName = "/editDeck";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add A Deck'),
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
