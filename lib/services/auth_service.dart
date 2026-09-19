import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // البريد الإلكتروني الخاص بالمدير
  static const String adminEmail = 'admin@fawry.com';

  // تسجيل الدخول
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // التحقق من حالة تسجيل الدخول
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // التحقق من صلاحية المدير
  bool get isAdmin {
    return currentUser?.email == adminEmail;
  }

  // التحقق من صلاحية المدير عبر Firestore
  Future<bool> checkAdminStatus() async {
    if (currentUser == null) return false;
    
    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    
    return userDoc.exists && userDoc['role'] == 'admin';
  }

  // إنشاء حساب جديد
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // حفظ بيانات المستخدم في Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': email == adminEmail ? 'admin' : 'user',
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
