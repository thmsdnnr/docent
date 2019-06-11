import 'package:docent/ImportFromURL.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "./database.dart";
import './models/FlashCard.dart';
import './models/Deck.dart';

import './CardEditor.dart';
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
  FlashCardSide _shownSide = FlashCardSide.front;

  List<FlashCard> _cardList;
  int _activeCardIdx = 0;
  int _totalCardCt = 0;
  Deck _chosenDeck;

  @override
  initState() {
    super.initState();
    grabCardsAndDisplay();
  }

  Future<void> buildFakeData() async {
    Deck newDeck = new Deck(id: 6, title: "A sick deck");
    Deck newDeck2 = new Deck(id: 4, title: "A sick deck");
    await DBProvider.db.insertDeck(newDeck);
    await DBProvider.db.insertDeck(newDeck2);
    var futures = <Future>[];
    new List<int>.generate(10, (i) {
      FlashCard thisCard = new FlashCard(
          id: i, title: "test card $i", front: "$i front", back: "$i back");
      futures.add(DBProvider.db.insertFlashCard(thisCard));
      futures.add(
          DBProvider.db.insertDeckToFlashCard(deck: newDeck, card: thisCard));
      futures.add(
          DBProvider.db.insertDeckToFlashCard(deck: newDeck, card: thisCard));
    });
    await Future.wait(futures);
  }

  void grabCardsAndDisplay({int deckId, DeckPosition startAt}) async {
    List<FlashCard> thisCardList = await DBProvider.db
        .getAllFlashCardsForDeck(deckId: deckId != null ? deckId : 0);
    Deck thisDeck = await DBProvider.db.getDeck(deckId: deckId);
    setState(() {
      _cardList = thisCardList;
      _totalCardCt = _cardList.length;
      _chosenDeck = thisDeck;
      if (startAt == DeckPosition.Last) {
        _activeCardIdx = _cardList.length - 1;
      }
    });
  }

  void _flipCard() {
    setState(() {
      if (_shownSide == FlashCardSide.front) {
        _shownSide = FlashCardSide.back;
      } else {
        _shownSide = FlashCardSide.front;
      }
    });
  }

  bool _canGoBack() => _activeCardIdx > 0 ? true : false;
  bool _canGoForward() => _activeCardIdx == _totalCardCt - 1 ? false : true;

  void _handleBackPress() {
    if (!_canGoBack()) {
      return;
    }
    setState(() {
      _activeCardIdx = _activeCardIdx - 1;
      _shownSide = FlashCardSide.front;
    });
  }

  void _handleForwardPress() {
    if (!_canGoForward()) {
      return;
    }
    setState(() {
      _activeCardIdx = _activeCardIdx + 1;
      _shownSide = FlashCardSide.front;
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

  Widget safeCard(BuildContext context) {
    if (_cardList != null &&
        _activeCardIdx >= 0 &&
        _activeCardIdx < _cardList.length) {
      return _cardList[_activeCardIdx].toWidget(sideToDisplay: _shownSide);
    } else {
      Widget textColumn = Column(children: <Widget>[
        Text("No cards available.",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
        RaisedButton(
            child: Text("Choose another deck"),
            onPressed: () async {
              // Navigator.navgiate
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

  Future importFromURL(BuildContext context) async {
    dynamic createdDeckId =
        await Navigator.of(context).pushNamed(ImportFromURL.routeName);
    if (createdDeckId != null && createdDeckId["deckId"] != null) {
      setState(() {
        grabCardsAndDisplay(deckId: createdDeckId["deckId"]);
      });
    }
  }

  Widget buildCardNavigation() {
    if (_cardList != null &&
        _activeCardIdx >= 0 &&
        _activeCardIdx < _cardList.length) {
      return ButtonBar(
        mainAxisSize: MainAxisSize.min,
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.arrow_back, size: 32),
            onPressed: _canGoBack() == true ? _handleBackPress : null,
          ),
          Text("${_activeCardIdx + 1} / $_totalCardCt",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              textAlign: TextAlign.center),
          new IconButton(
            icon: new Icon(Icons.arrow_forward, size: 32),
            onPressed: _canGoForward() == true ? _handleForwardPress : null,
          ),
        ],
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chosenDeck != null ? _chosenDeck.title : ""),
        backgroundColor: Colors.orangeAccent,
      ),
      body: new Center(
          child: new GestureDetector(
        child: safeCard(context),
        onTap: _flipCard,
      )),
      bottomNavigationBar: buildCardNavigation(),
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
