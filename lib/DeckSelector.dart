import "./database.dart";
import 'package:flutter/material.dart';
import './models/Deck.dart';

Future<List<Deck>> getDeckList() async {
  List<Deck> deckList = await DBProvider.db.getAllDecks();
  return deckList;
}

Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
  List<Deck> values = snapshot.data;
  return new ListView.builder(
    itemCount: values.length,
    itemBuilder: (BuildContext context, int index) {
      return new Column(
        children: <Widget>[
          ListTile(
              title: Text(values[index].title),
              subtitle: Text(values[index].id.toString()),
              onTap: () {
                Navigator.pop(context, values[index]);
              }),
          Divider(
            height: 4.0,
          ),
        ],
      );
    },
  );
}

class DeckSelector extends StatelessWidget {
  static const routeName = "/deckSelector";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose A Deck'),
        ),
        body: SafeArea(
            child: FutureBuilder<List<Deck>>(
          future: getDeckList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return createListView(context, snapshot);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )));
  }
}
