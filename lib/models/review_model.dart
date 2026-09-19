class ReviewModel {
  final String id;
  final String clientName;
  final String reviewText;
  final String? clientImageUrl;
  final bool isApproved;
  final DateTime createdAt;
  final String? userId;

  ReviewModel({
    required this.id,
    required this.clientName,
    required this.reviewText,
    this.clientImageUrl,
    required this.isApproved,
    required this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'reviewText': reviewText,
      'clientImageUrl': clientImageUrl,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      clientName: map['clientName'] ?? '',
      reviewText: map['reviewText'] ?? '',
      clientImageUrl: map['clientImageUrl'],
      isApproved: map['isApproved'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      userId: map['userId'],
    );
  }

  ReviewModel copyWith({
    String? id,
    String? clientName,
    String? reviewText,
    String? clientImageUrl,
    bool? isApproved,
    DateTime? createdAt,
    String? userId,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      reviewText: reviewText ?? this.reviewText,
      clientImageUrl: clientImageUrl ?? this.clientImageUrl,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
