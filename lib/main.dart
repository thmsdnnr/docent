import 'package:docent/ImportFromURL.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "./database.dart";
import './models/FlashCard.dart';
import './models/Deck.dart';
import './models/Grade.dart';

import './models/FlashCardDisplayer.dart';

import './CardEditor.dart';
import './DeckEditor.dart';
import './DeckSelector.dart';
import './ImportFromURL.dart';

void main() => runApp(MyApp());

enum DeckPosition { First, Last }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        CardEditor.routeName: (context) => CardEditor(),
        DeckEditor.routeName: (context) => DeckEditor(),
        DeckSelector.routeName: (context) => DeckSelector(),
        ImportFromURL.routeName: (context) => ImportFromURL(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FlashCard> _cardList;
  int _activeCardIdx = 0;
  int _totalCardCt = 0;
  int _cardGrade = -1;
  Deck _chosenDeck;
  PageController controller;

  @override
  initState() {
    super.initState();
    grabCardsAndDisplay();
  }

  void grabCardsAndDisplay({int deckId, DeckPosition startAt}) async {
    List<FlashCard> thisCardList = await DBProvider.db
        .getAllFlashCardsForDeck(deckId: deckId != null ? deckId : 0);
    Deck thisDeck =
        await DBProvider.db.getDeck(deckId: deckId != null ? deckId : 0);
    setState(() {
      _cardList = thisCardList;
      _totalCardCt = _cardList.length;
      _chosenDeck = thisDeck;
      if (startAt == DeckPosition.Last) {
        _activeCardIdx = _cardList.length - 1;
      }
    });
  }

  Card buildNiceTextBox(textColumn) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Padding(padding: EdgeInsets.all(48), child: textColumn)],
        ),
      );

  Widget safeCard(BuildContext context, int index) {
    if (_cardList != null &&
        _activeCardIdx >= 0 &&
        _activeCardIdx < _cardList.length) {
      return FlashCardDisplayer(flashCard: _cardList[index]);
    } else {
      Widget textColumn = Column(children: <Widget>[
        Text("No cards available.",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
        RaisedButton(
            child: Text("Choose another deck"),
            onPressed: () async {
              await chooseAnotherDeck(context);
            }),
        RaisedButton(
            child: Text("Create a card!"),
            onPressed: () async {
              await createACard(context);
            })
      ]);
      return buildNiceTextBox(textColumn);
    }
  }

  Future chooseAnotherDeck(BuildContext context) async {
    // grab the deck the users selects when the page returns
    dynamic selectedDeck =
        await Navigator.of(context).pushNamed(DeckSelector.routeName);
    if (selectedDeck != null && selectedDeck.id != null) {
      setState(() {
        _chosenDeck = selectedDeck;
        grabCardsAndDisplay(deckId: _chosenDeck.id);
      });
    }
  }

  Future createACard(BuildContext context) async {
    dynamic createdCard = await Navigator.of(context).pushNamed(
        CardEditor.routeName,
        arguments: ScreenArguments(currentDeck: _chosenDeck));
    if (createdCard != null && createdCard["deckId"] != null) {
      setState(() {
        _chosenDeck = createdCard["deckId"];
        grabCardsAndDisplay(deckId: _chosenDeck.id, startAt: DeckPosition.Last);
      });
    }
  }

  Future createADeck(BuildContext context) async {
    dynamic createdDeck = await Navigator.of(context).pushNamed(
        DeckEditor.routeName,
        arguments: ScreenArguments(currentDeck: _chosenDeck));
    if (createdDeck != null && createdDeck["deckId"] != null) {
      setState(() {
        grabCardsAndDisplay(deckId: createdDeck["deckId"]);
      });
    }
  }

  Future importFromURL(BuildContext context) async {
    dynamic createdDeckId =
        await Navigator.of(context).pushNamed(ImportFromURL.routeName);
    if (createdDeckId != null && createdDeckId["deckId"] != null) {
      setState(() {
        grabCardsAndDisplay(deckId: createdDeckId["deckId"]);
      });
    }
  }

  String buildCardTitle() {
    String title = "";
    if (_chosenDeck?.title != null) {
      if (_totalCardCt > 0) {
        title = "${_chosenDeck.title} ${_activeCardIdx + 1} / $_totalCardCt";
      } else {
        title = "${_chosenDeck.title} (0 / 0)";
      }
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(buildCardTitle()),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: PageView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          controller: controller,
          itemCount: _cardList != null ? _cardList.length : 0,
          itemBuilder: (BuildContext context, int index) {
            return safeCard(context, index);
          },
          onPageChanged: (int pageIdx) async {
            int thisCardId = _cardList[_activeCardIdx].id;
            if (_cardGrade != null && _cardGrade != -1) {
              // the user assigned a card grade, so save it!
              Grade thisGrade =
                  await DBProvider.db.getGrade(flashCardId: thisCardId);
              if (thisGrade != null) {
                await DBProvider.db.insertGrade(
                    grade: thisGrade.updateGradeWithQuality(_cardGrade));
              } else {
                // if there's no grade entry, create a default one for next time.
                await DBProvider.db
                    .setDefaultGradeForFlashCard(flashCardId: thisCardId);
              }
            }
            setState(() {
              _activeCardIdx = pageIdx;
              _cardGrade = -1;
            });
          },
        ),
      ),
      drawer: Drawer(
          child: ListView(children: <Widget>[
        ListTile(
            title: Text("Add New Card"),
            trailing: Icon(Icons.arrow_forward),
            onTap: () async {
              Navigator.pop(context); // close the drawer before navigating away
              await createACard(context);
            }),
        ListTile(
            title: Text("Add New Deck"),
            trailing: Icon(Icons.arrow_forward),
            onTap: () async {
              Navigator.pop(context); // close the drawer before navigating away
              await createADeck(context);
            }),
        ListTile(
          title: Text("Choose A Deck"),
          trailing: Icon(Icons.arrow_forward),
          onTap: () async {
            Navigator.pop(context); // close the drawer before navigating away
            await chooseAnotherDeck(context);
          },
        ),
        ListTile(
          title: Text("Import From URL"),
          trailing: Icon(Icons.arrow_forward),
          onTap: () async {
            Navigator.pop(context); // close the drawer before navigating away
            await importFromURL(context);
          },
        ),
      ])),
    );
  }
}
