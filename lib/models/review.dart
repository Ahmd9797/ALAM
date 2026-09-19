enum ReviewStatus { pending, approved, rejected }

class CustomerReview {
  final String id;
  final String userName;
  final String text;
  final DateTime createdAt;
  final ReviewStatus status; // مدير فقط يرى 'pending' وينشره ليصبح 'approved'

  CustomerReview({
    required this.id,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.status = ReviewStatus.pending,
  });
}
