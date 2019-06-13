import "./database.dart";
import 'package:flutter/material.dart';
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
  Map<String, String> _cardData = {
    "title": "",
    "front": "",
    "back": "",
  };
  List<Deck> _deckList;
  Deck _chosenDeck;
  bool _firstDeckListCall = true;

  @override
  initState() {
    super.initState();
    grabDecksAndDisplay();
  }

  void grabDecksAndDisplay() async {
    List<Deck> deckList = await getDeckList();
    setState(() {
      _deckList = deckList;
    });
  }

  Widget buildDeckList({Deck selectedDeck}) {
    if (_deckList == null) {
      return Text("");
    }
    List deckItems = _deckList.map((Deck deck) {
      return DropdownMenuItem<Deck>(
        value: deck,
        child: Text("${deck.title} (${deck.id})"),
      );
    }).toList();
    if (_firstDeckListCall == true &&
        selectedDeck != null &&
        selectedDeck.id != null) {
      _chosenDeck = _deckList
          .where((Deck deck) => deck.id == selectedDeck.id)
          .toList()[0];
    }
    return DropdownButton<Deck>(
      hint: Text("Add to deck"),
      isExpanded: true,
      isDense: false,
      value: _chosenDeck,
      onChanged: (Deck newDeck) {
        setState(() {
          _chosenDeck = newDeck;
          _firstDeckListCall = false;
        });
      },
      items: deckItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    final Deck currentDeck = args.currentDeck;
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
                this._cardData["title"] = value;
              }),
          TextFormField(
              minLines: 1,
              maxLines: 10,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "Front",
                labelStyle: TextStyle(fontSize: 20),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a front';
                }
                return null;
              },
              onSaved: (String value) {
                this._cardData["front"] = value;
              }),
          TextFormField(
              minLines: 1,
              maxLines: 10,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "Back",
                labelStyle: TextStyle(fontSize: 20),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a back';
                }
                return null;
              },
              onSaved: (String value) {
                this._cardData["back"] = value;
              }),
          buildDeckList(selectedDeck: currentDeck),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  FlashCard cardToSave = new FlashCard.fromMap(this._cardData);
                  int recordId =
                      await DBProvider.db.insertFlashCard(cardToSave);
                  if (this._chosenDeck != null) {
                    await DBProvider.db.insertDeckToFlashCardById(
                        deckId: this._chosenDeck.id, cardId: recordId);
                  }
                  Navigator.pop(context,
                      {"cardId": recordId, "deckId": this._chosenDeck});
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

class ScreenArguments {
  final Deck currentDeck;
  ScreenArguments({this.currentDeck});
}

class CardEditor extends StatelessWidget {
  static const routeName = "/editCard";

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
