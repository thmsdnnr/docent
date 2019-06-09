import 'dart:convert';
import 'package:flutter/material.dart';

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

  FlashCard.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    id = jsonData["id"];
    title = jsonData["title"];
    front = jsonData["front"];
    back = jsonData["back"];
    tags = List.from(jsonData["tags"]);
    decks = List.from(jsonData["decks"]);
  }

  FlashCard.fromObject(flashcardObj) {
    id = flashcardObj["id"];
    title = flashcardObj["title"];
    front = flashcardObj["front"];
    back = flashcardObj["back"];
    tags = List.from(flashcardObj["tags"]);
    decks = List.from(flashcardObj["decks"]);
  }

  Map<String, dynamic> toJson() {
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
              new Expanded(
                  flex: 1,
                  child: Center(
                    child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          sideToDisplay == FlashCardSide.front ? front : back,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 32),
                          textAlign: TextAlign.center,
                        )),
                  ))
            ],
          ),
        ),
      );
}
