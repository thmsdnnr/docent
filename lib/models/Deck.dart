class Deck {
  Deck({this.id, this.title, this.cards, this.tags});

  int id;
  String title;
  List<int> cards;
  List<int> tags;

  String toString() {
    return "$id $title";
  }

  factory Deck.fromMap(Map<String, dynamic> json) => new Deck(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
    };
  }
}
