import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

enum FlashCardSide { front, back }

class FlashCard {
  FlashCard(this.id, this.title, this.front, this.back, this.tags, this.decks);

  String id;
  String title;
  String front;
  String back;
  List<String> tags;
  List<String> decks;

  String toString() {
    return "$id $title $front $back ${tags.toString()}, ${decks.toString()}";
  }

  FlashCard.fromJson(String jsonString) {
    final Map jsonData = json.decode(jsonString);
    id = jsonData["id"];
    title = jsonData["title"];
    front = jsonData["front"];
    back = jsonData["back"];
    tags = List.from(jsonData["tags"]);
    decks = List.from(jsonData["decks"]);
  }

  Map toJson() {
    return {
      "id": id,
      "title": title,
      "front": front,
      "back": back,
      "tags": tags.toString(),
      "decks": decks.toString()
    };
  }

  FractionallySizedBox toWidget({FlashCardSide sideToDisplay}) =>
      FractionallySizedBox(
        widthFactor: 0.8,
        heightFactor: 0.8,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                title: Text(
                  sideToDisplay == FlashCardSide.front ? front : back,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      );
}

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
  Icon _thisIcon = flipToBack;

  static String theJSON =
      """{"id":"a globally unique ID to identify the card","title":"an optional title","front":
  "This is the front of the card!","back":"This is the back of the card!","tags":["a","list","of","tags",
  "that","the","card","has"],"decks":["a","list","of","globally unique","deck IDs","that","this","Card",
  "Belongs","to"]}""";
  FlashCard _card = new FlashCard.fromJson(theJSON);

  @override
  initState() {
    super.initState();
    _cardToShow = _card.toWidget(sideToDisplay: _shownSide);
  }

  void _flipCard() {
    setState(() {
      if (_shownSide == FlashCardSide.front) {
        _shownSide = FlashCardSide.back;
        _cardToShow = _card.toWidget(sideToDisplay: _shownSide);
        _thisIcon = flipToBack;
      } else {
        _shownSide = FlashCardSide.front;
        _cardToShow = _card.toWidget(sideToDisplay: _shownSide);
        _thisIcon = flipToFront;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
        child: _cardToShow,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _flipCard,
        tooltip: 'Flip Card',
        child: _thisIcon,
      ),
    );
  }
}
