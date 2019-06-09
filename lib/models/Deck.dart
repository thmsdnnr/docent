import 'dart:convert';
import "./FlashCard.dart";

class Deck {
  Deck(this.id, this.title, this.cards, this.tags);

  String id;
  String title;
  List<FlashCard> cards;
  List<String> tags;

  String toString() {
    return "$id ${cards.toString()}";
  }

  Deck.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    id = jsonData["id"];
    title = jsonData["title"];
    cards = List.from(
        jsonData["cards"].map((card) => new FlashCard.fromObject(card)));
    tags = List.from(jsonData["tags"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "tags": tags.toString(),
      "cards": cards.toString()
    };
  }

  List<FlashCard> getCards() {
    return cards;
  }
}
