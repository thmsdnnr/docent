import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "./database.dart";
import './models/FlashCard.dart';
import './models/Deck.dart';

void main() => runApp(MyApp());

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

  void grabCardsAndDisplay() async {
    // await buildFakeData();
    // List<Deck> _deckList = await DBProvider.db.getAllDecks();
    // print(_deckList);
    _cardList = await DBProvider.db.getAllFlashCardsForDeck(deckId: 6);
    setState(() {
      _cardList = _cardList;
      _totalCardCt = _cardList.length;
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

  Widget safeCard() {
    if (_cardList != null &&
        _activeCardIdx >= 0 &&
        _activeCardIdx < _cardList.length) {
      return _cardList[_activeCardIdx].toWidget(sideToDisplay: _shownSide);
    } else {
      return CircularProgressIndicator();
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
      body: new Center(
          child: new GestureDetector(
        child: safeCard(),
        onTap: _flipCard,
      )),
      bottomNavigationBar: buildCardNavigation(),
    );
  }
}
