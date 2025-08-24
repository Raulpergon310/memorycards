import 'memory_card.dart';

class Deck {
  final String id;
  final String name;
  final String description;
  final List<MemoryCard> cards;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deck({
    required this.id,
    required this.name,
    required this.description,
    required this.cards,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cards': cards.map((card) => card.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cards: (json['cards'] as List<dynamic>?)
          ?.map((cardJson) => MemoryCard.fromJson(cardJson))
          .toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Deck copyWith({
    String? id,
    String? name,
    String? description,
    List<MemoryCard>? cards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}