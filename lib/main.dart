import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  FractionallySizedBox _cardToShow;
  static final Icon flipToBack = new Icon(Icons.flip_to_back);
  static final Icon flipToFront = new Icon(Icons.flip_to_front);

  static String testDeck =
      """{"id":"the-deck-id","title":"atestdeck","tags":["some","deck","tags"],"cards":[
    {"id":"uniq-id-0","title":"card 0","front":"front of card 0front of card 0front of card 0front of card 0front of card 0front of card 0front of card0front of card 0front of card0front of card 0front of card0front of card 0front of card0front of card 0front of card0front of card 0front of card0front of card 0front of card0front of card 0front of card0front of card 0front of card0front of card 0front of card 0front of card 0front of card 0front of card 0front of card 0front of card 0front of card 0front of card 0","back":"back of card 0","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-1","title":"card 1","front":"front of card 1","back":"back of card 1","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-2","title":"card 2","front":"front of card 2","back":"back of card 2","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-3","title":"card 3","front":"front of card 3","back":"back of card 3","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-4","title":"card 4","front":"front of card 4","back":"back of card 4","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-5","title":"card 5","front":"front of card 5","back":"back of card 5","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-6","title":"card 6","front":"front of card 6","back":"back of card 6","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-7","title":"card 7","front":"front of card 7","back":"back of card 7","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-8","title":"card 8","front":"front of card 8","back":"back of card 8","tags":["list","of","tags"],"decks":["a","list"]},
    {"id":"uniq-id-9","title":"card 9","front":"front of card 9","back":"back of card 9","tags":["list","of","tags"],"decks":["a","list"]}]}""";

  Deck _deck = new Deck.fromJsonString(testDeck);
  List<FlashCard> _cardList;
  FlashCard _activeCard;
  int _activeCardIdx = 0;
  int _totalCardCt;
  Icon _thisIcon;

  @override
  initState() {
    super.initState();
    _cardList = _deck.getCards();
    _activeCard = _cardList[_activeCardIdx];
    _cardToShow = _activeCard.toWidget(sideToDisplay: _shownSide);
    _totalCardCt = _cardList.length;
  }

  void _flipCard() {
    setState(() {
      if (_shownSide == FlashCardSide.front) {
        _shownSide = FlashCardSide.back;
        _thisIcon = flipToBack;
      } else {
        _shownSide = FlashCardSide.front;
        _thisIcon = flipToFront;
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

  @override
  Widget build(BuildContext context) {
    _activeCard = _cardList[_activeCardIdx];
    _cardToShow = _activeCard.toWidget(sideToDisplay: _shownSide);
    return Scaffold(
      body: new Center(
          child: new GestureDetector(
        child: _cardToShow,
        onTap: _flipCard,
      )),
      bottomNavigationBar: new ButtonBar(
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
      ),
    );
  }
}
