import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/offer_model.dart';
import '../models/review_model.dart';
import '../models/project_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ========== العروض ==========
  
  Stream<List<OfferModel>> getOffers() {
    return _firestore
        .collection('offers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addOffer(OfferModel offer) async {
    await _firestore.collection('offers').doc(offer.id).set(offer.toMap());
  }

  Future<void> updateOffer(OfferModel offer) async {
    await _firestore.collection('offers').doc(offer.id).update(offer.toMap());
  }

  Future<void> deleteOffer(String offerId) async {
    await _firestore.collection('offers').doc(offerId).delete();
  }

  // ========== آراء الزبائن ==========
  
  Stream<List<ReviewModel>> getApprovedReviews() {
    return _firestore
        .collection('reviews')
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ReviewModel>> getPendingReviews() {
    return _firestore
        .collection('reviews')
        .where('isApproved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').doc(review.id).set(review.toMap());
  }

  Future<void> approveReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'isApproved': true,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  // ========== المشاريع ==========
  
  Stream<List<ProjectModel>> getProjects() {
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addProject(ProjectModel project) async {
    await _firestore.collection('projects').doc(project.id).set(project.toMap());
  }

  Future<void> updateProject(ProjectModel project) async {
    await _firestore.collection('projects').doc(project.id).update(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }

  // ========== المنتجات ==========
  
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).set(product.toMap());
  }

  // ========== رفع الصور ==========
  
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('فشل في رفع الصورة: $e');
    }
  }

  // ========== إعدادات الاستشارة ==========
  
  Stream<DocumentSnapshot> getConsultationSettings() {
    return _firestore.collection('settings').doc('consultation').snapshots();
  }

  Future<void> updateConsultationSettings({
    required String instagram,
    required String facebook,
    required String tiktok,
    required String whatsapp,
  }) async {
    await _firestore.collection('settings').doc('consultation').set({
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'whatsapp': whatsapp,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
