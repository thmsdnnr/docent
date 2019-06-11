import 'package:docent/ImportFromURL.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "./database.dart";
import './models/FlashCard.dart';
import './models/Deck.dart';
import './models/Grade.dart';

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
  int _cardGrade = -1;
  Deck _chosenDeck;
  Card _chosenCard;
  PageController controller;

  static final FlashCardSide BackSideOfCard = FlashCardSide.back;

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

  FractionallySizedBox cardToWidget(
      {BuildContext context, FlashCardSide sideToDisplay, FlashCard card}) {
    EdgeInsets contentPadding = EdgeInsets.all(24.0);
    // Pad out the top of the card more if we are displying the rating row at bottom.
    if (sideToDisplay == BackSideOfCard) {
      contentPadding = EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 0);
    }
    List<Widget> childList = [
      Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
                padding: contentPadding,
                child: Text(
                  sideToDisplay == FlashCardSide.front ? card.front : card.back,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
                  textAlign: TextAlign.center,
                )),
          ))
    ];
    if (sideToDisplay == BackSideOfCard) {
      childList.add(Wrap(
          spacing: 8.0,
          children: List<Widget>.generate(
            6,
            (int index) {
              return ChoiceChip(
                backgroundColor: Colors.cyan.shade100,
                selectedColor: Colors.orange,
                // shape: StadiumBorder(side: BorderSide()),
                selected: index == _cardGrade,
                label: Text("$index",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onSelected: (bool selected) {
                  setState(() {
                    _cardGrade = selected ? index : null;
                  });
                },
              );
            },
          ).toList()));
    }
    return FractionallySizedBox(
      widthFactor: 0.9,
      heightFactor: 0.9,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: childList,
        ),
      ),
    );
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
      return GestureDetector(
        child: cardToWidget(
            context: context,
            sideToDisplay: _shownSide,
            card: _cardList[index]),
        onTap: () => _flipCard(),
      );
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

  String buildCardTitle() {
    String title = "";
    if (_chosenDeck?.title != null) {
      title = "${_chosenDeck.title} ${_activeCardIdx + 1} / $_totalCardCt";
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
              _shownSide = FlashCardSide.front;
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
