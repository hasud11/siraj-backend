import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  UserService._();

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // ============================================================
  // إنشاء ملف المستخدم
  // ============================================================

  static Future<String> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),

        // ======================================================
        // نوع الحساب
        // ======================================================

        'accountType': 'free',

        // ======================================================
        // الأسئلة المجانية
        // ======================================================

        'freeQuestionsUsed': 0,

        // الحد المجاني
        'freeQuestionsLimit': 3,

        // ======================================================
        // تاريخ إنشاء الحساب
        // ======================================================

        'createdAt': FieldValue.serverTimestamp(),
      });

      return 'تم إنشاء ملف المستخدم في Firestore بنجاح.\n\n'
          'Collection: users\n'
          'Document ID: $uid\n\n'
          'الاسم: ${name.trim()}\n'
          'البريد: ${email.trim()}';
    } on FirebaseException catch (e) {
      throw Exception(
        'Firestore Error\n'
        'Code: ${e.code}\n'
        'Message: ${e.message ?? "لا توجد رسالة"}',
      );
    } catch (e) {
      throw Exception(
        'Firestore Error\n'
        '$e',
      );
    }
  }
}