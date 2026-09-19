class OfferModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
