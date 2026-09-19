import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/review_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final bool isAdmin = authService.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('آراء الزبائن'),
        bottom: isAdmin
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'المنشورة'),
                  Tab(text: 'بانتظار الموافقة'),
                ],
              )
            : null,
      ),
      body: isAdmin
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsList(firestoreService, isAdmin, isApproved: true),
                _buildReviewsList(firestoreService, isAdmin, isApproved: false),
              ],
            )
          : _buildReviewsList(firestoreService, isAdmin, isApproved: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReviewDialog(context),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildReviewsList(FirestoreService firestoreService, bool isAdmin, {required bool isApproved}) {
    final stream = isApproved 
        ? firestoreService.getApprovedReviews() 
        : firestoreService.getPendingReviews();

    return StreamBuilder<List<ReviewModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(isApproved ? 'لا توجد آراء منشورة' : 'لا توجد آراء بانتظار الموافقة'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final review = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    review.clientName.isNotEmpty ? review.clientName[0] : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  review.clientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(review.reviewText),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                trailing: isAdmin && !isApproved
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveReview(firestoreService, review.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReview(firestoreService, review.id),
                          ),
                        ],
                      )
                    : isAdmin
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReview(firestoreService, review.id),
                          )
                        : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final bool isAdmin = authService.isAdmin;

    final nameController = TextEditingController();
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAdmin ? 'إضافة رأي' : 'إضافة رأيك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(labelText: 'الرأي'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || reviewController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final review = ReviewModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                clientName: nameController.text,
                reviewText: reviewController.text,
                isApproved: isAdmin, // المدير ينشر فوراً، المستخدم يحتاج موافقة
                createdAt: DateTime.now(),
                userId: authService.currentUser?.uid,
              );

              await firestoreService.addReview(review);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAdmin ? 'تم نشر الرأي' : 'تم إرسال الرأي للمراجعة'),
                  ),
                );
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveReview(FirestoreService firestoreService, String reviewId) async {
    await firestoreService.approveReview(reviewId);
  }

  Future<void> _deleteReview(FirestoreService firestoreService, String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الرأي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await firestoreService.deleteReview(reviewId);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
