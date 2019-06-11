import 'package:flutter/material.dart';

enum FlashCardSide { front, back }

class FlashCard {
  FlashCard({this.id, this.title, this.front, this.back});

  int id;
  String title;
  String front;
  String back;

  String toString() {
    return "$id $title $front $back";
  }

  factory FlashCard.fromMap(Map<String, dynamic> json) => new FlashCard(
        id: json["id"],
        title: json["title"],
        front: json["front"],
        back: json["back"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "front": front,
        "back": back,
      };

  FractionallySizedBox toWidget({FlashCardSide sideToDisplay}) =>
      FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.9,
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
