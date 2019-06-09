import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

// Models
import './models/FlashCard.dart';
import './models/Deck.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "docent.db");
    return await openDatabase(path,
        version: 1,
        onCreate: (Database db, int version) {}, onOpen: (Database db) async {
      // await db.execute("DROP TABLE FlashCard");
      // await db.execute("DROP TABLE Deck");
      // await db.execute("DROP TABLE DeckToFlashCard");
      await db.execute("CREATE TABLE IF NOT EXISTS FlashCard ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "front TEXT,"
          "back TEXT"
          ")");
      await db.execute("CREATE TABLE IF NOT EXISTS Deck ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT"
          ")");
      await db.execute("CREATE TABLE IF NOT EXISTS DeckToFlashCard ("
          "id INTEGER PRIMARY KEY,"
          "deckId INTEGER,"
          "flashCardId INTEGER,"
          "FOREIGN KEY(deckId) REFERENCES Deck(id),"
          "FOREIGN KEY(flashCardId) REFERENCES FlashCard(id),"
          "UNIQUE(deckId, flashCardId)"
          ")");
    });
  }

  getFlashCard({String flashCardId}) async {
    final db = await database;
    var res =
        await db.query("FlashCard", where: "id = ?", whereArgs: [flashCardId]);
    return res.isNotEmpty ? FlashCard.fromMap(res.first) : null;
  }

  Future<Deck> getDeck({String deckId}) async {
    final db = await database;
    var res = await db.query("Deck", where: "id = ?", whereArgs: [deckId]);
    return res.isNotEmpty ? Deck.fromMap(res.first) : null;
  }

  Future<int> insertEntity({String kind, Map<String, dynamic> values}) async {
    final Database db = await database;
    int recordId = await db.insert(
      kind,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return recordId;
  }

  Future<void> insertDeckToFlashCard({Deck deck, FlashCard card}) async {
    final Database db = await database;
    await db.rawInsert(
        "INSERT OR IGNORE INTO DeckToFlashCard (deckId, flashCardId) VALUES(?, ?)",
        [deck.id, card.id]);
  }

  Future<void> insertDeck(Deck deck) async {
    return await insertEntity(kind: "Deck", values: deck.toMap());
  }

  Future<void> insertFlashCard(FlashCard card) async {
    return await insertEntity(kind: "FlashCard", values: card.toMap());
  }

  Future<List<Deck>> getAllDecks() async {
    final db = await database;
    var res = await db.query("Deck");
    print(res);
    List<Deck> list = res.isNotEmpty
        ? res.map((c) {
            print(c);
            return Deck.fromMap(c);
          }).toList()
        : [];
    return list;
  }

  Future<List<FlashCard>> getAllFlashCards() async {
    final db = await database;
    var res = await db.query("FlashCard");
    List<FlashCard> list =
        res.isNotEmpty ? res.map((c) => FlashCard.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<FlashCard>> getAllFlashCardsForDeck({int deckId}) async {
    final db = await database;
    var res = await db.rawQuery("""
    SELECT * FROM DeckToFlashCard dtfc
      INNER JOIN FlashCard fc
      ON dtfc.flashCardId = fc.id
      WHERE dtfc.deckId = ?""", [deckId]);
    List<FlashCard> flashCardList =
        res.isNotEmpty ? res.map((c) => FlashCard.fromMap(c)).toList() : [];
    return flashCardList;
  }

  deleteById({String entity, String id}) async {
    final db = await database;
    return db.delete(entity, where: "id = ?", whereArgs: [id]);
  }

  deleteFlashCard(String flashCardId) async {
    return await deleteById(entity: "FlashCard", id: flashCardId);
  }

  deleteDeck(String deckId) async {
    return await deleteById(entity: "Deck", id: deckId);
  }
}