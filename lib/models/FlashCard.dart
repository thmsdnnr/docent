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
}
