class MemoryCard {
  final String id;
  final String front;
  final String back;

  MemoryCard({
    required this.id,
    required this.front,
    required this.back,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
    };
  }

  factory MemoryCard.fromJson(Map<String, dynamic> json) {
    return MemoryCard(
      id: json['id'] ?? '',
      front: json['front'] ?? '',
      back: json['back'] ?? '',
    );
  }

  MemoryCard copyWith({
    String? id,
    String? front,
    String? back,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
    );
  }
}