import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../models/project.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- إدارة العروض ---
  Future<void> addOffer(String title, String imageUrl, DateTime startDate, DateTime endDate) async {
    await _db.collection('offers').add({
      'title': title,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getLatestOffers() {
    return _db.collection('offers')
        .where('endDate', isGreaterThan: DateTime.now().toIso8601String())
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- إدارة آراء الزبائن ---
  Future<void> submitUserReview(String userName, String text) async {
    await _db.collection('reviews').add({
      'userName': userName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // ينتظر موافقة المدير
    });
  }

  Future<void> approveReview(String reviewId) async {
    await _db.collection('reviews').doc(reviewId).update({'status': 'approved'});
  }

  Stream<List<CustomerReview>> getAllReviews(bool isAdminView) {
    Query query = _db.collection('reviews');
    
    if (!isAdminView) {
      // للمستخدم العادي: يعرض المعتمد فقط
      query = query.where('status', isEqualTo: 'approved');
    } else {
      // للمدير: يعرض الكل (المعلق والمعتمد) لترتيبهم
      query = query.orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        return CustomerReview(
          id: doc.id,
          userName: data['userName'] ?? '',
          text: data['text'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: ReviewStatus.values.firstWhere(
            (e) => e.toString().split('.').last == data['status'],
            orElse: () => ReviewStatus.pending,
          ),
        );
      }).toList();
    });
  }

  // --- إدارة المشاريع ---
  Future<void> addProject(ProjectData data) async {
    // منطق رفع الصور إلى Storage ثم حفظ الروابط هنا
    // مبسط للتوضيح: سنفترض أن الروابط تم الحصول عليها مسبقاً
    await _db.collection('projects').add(data.toJson());
  }
  
  // ... دوال إضافية للحذف والتعديل ...
}
