import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';

class StorageService {
  static const String _decksKey = 'memory_card_decks';

  Future<List<Deck>> getDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final decksJson = prefs.getString(_decksKey);
    
    if (decksJson == null) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(decksJson);
      return decodedList
          .map((deckJson) => Deck.fromJson(deckJson))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveDeck(Deck deck) async {
    final decks = await getDecks();
    final existingIndex = decks.indexWhere((d) => d.id == deck.id);
    
    if (existingIndex != -1) {
      decks[existingIndex] = deck;
    } else {
      decks.add(deck);
    }

    await _saveDecks(decks);
  }

  Future<void> deleteDeck(String deckId) async {
    final decks = await getDecks();
    decks.removeWhere((deck) => deck.id == deckId);
    await _saveDecks(decks);
  }

  Future<void> _saveDecks(List<Deck> decks) async {
    final prefs = await SharedPreferences.getInstance();
    final decksJson = jsonEncode(decks.map((deck) => deck.toJson()).toList());
    await prefs.setString(_decksKey, decksJson);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_decksKey);
  }
}