import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class SirajFreeLimitException implements Exception {
  final String message;
  final int usedQuestions;
  final int freeQuestions;

  const SirajFreeLimitException({
    required this.message,
    required this.usedQuestions,
    required this.freeQuestions,
  });

  @override
  String toString() => message;
}

class SirajUsage {
  final String accountType;
  final int usedQuestions;
  final int freeQuestions;
  final int remainingQuestions;
  final bool paid;
  final bool unlimited;

  const SirajUsage({
    required this.accountType,
    required this.usedQuestions,
    required this.freeQuestions,
    required this.remainingQuestions,
    this.paid = false,
    this.unlimited = false,
  });

  bool get isFree =>
      accountType.toLowerCase() == 'free' && !paid && !unlimited;

  bool get isPremium =>
      paid ||
      unlimited ||
      accountType.toLowerCase() == 'premium' ||
      accountType.toLowerCase() == 'pro' ||
      accountType.toLowerCase() == 'paid' ||
      accountType.toLowerCase() == 'subscription' ||
      accountType.toLowerCase() == 'subscriber';

  bool get hasReachedFreeLimit =>
      isFree && remainingQuestions <= 0;
}

// ============================================================
// خدمة الذكاء الاصطناعي - سِراج
// ============================================================

class AiService {
  // عنوان الخادم على الشبكة المحلية
 static const String baseUrl =
    'http://172.18.180.28:3000';
  // إذا كان التطبيق يعمل على Windows / Web
  // على نفس اللابتوب:
  //
  // static const String baseUrl =
  //     'http://localhost:3000';

  static const Duration requestTimeout =
      Duration(seconds: 90);

  static const Duration usageTimeout =
      Duration(seconds: 20);

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  SirajUsage? lastUsage;

  // ==========================================================
  // إرسال سؤال إلى سِراج
  // ==========================================================

  Future<String> ask(
    String prompt, {
    List<Map<String, String>> history = const [],
  }) async {
    final cleanPrompt = prompt.trim();

    if (cleanPrompt.isEmpty) {
      throw Exception(
        'اكتبي سؤالك أولًا.',
      );
    }

    // --------------------------------------------------------
    // المستخدم الحالي
    // --------------------------------------------------------

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'يجب تسجيل الدخول لاستخدام سِراج.',
      );
    }

    // --------------------------------------------------------
    // الحصول على Firebase ID Token
    // --------------------------------------------------------

    final idToken =
        await user.getIdToken();

    if (idToken == null ||
        idToken.trim().isEmpty) {
      throw Exception(
        'تعذر التحقق من حسابك. حاولي تسجيل الدخول مرة أخرى.',
      );
    }

    // --------------------------------------------------------
    // عنوان الطلب
    // --------------------------------------------------------

    final uri =
        Uri.parse('$baseUrl/api/chat');

    // --------------------------------------------------------
    // تنظيف History
    // --------------------------------------------------------

    final cleanHistory =
        _cleanHistory(history);

    // --------------------------------------------------------
    // إرسال الطلب
    // --------------------------------------------------------

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type':
                  'application/json',

              'Accept':
                  'application/json',

              'Authorization':
                  'Bearer $idToken',
            },
            body: jsonEncode({
              'message':
                  cleanPrompt,

              'history':
                  cleanHistory,
            }),
          )
          .timeout(
            requestTimeout,
          );

      // ------------------------------------------------------
      // قراءة JSON
      // ------------------------------------------------------

      final data =
          _decodeResponse(response);

      // ======================================================
      // نجاح
      // ======================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final reply =
            data['reply']
                ?.toString()
                .trim();

        if (reply == null ||
            reply.isEmpty) {
          throw Exception(
            'لم يصل رد من سِراج.',
          );
        }

        _updateUsageFromChatResponse(
          data,
        );

        return reply;
      }

      // ======================================================
      // انتهاء الأسئلة المجانية
      //
      // server.js يعيد 402
      // ======================================================

      if (response.statusCode == 402 &&
          data['code'] ==
              'FREE_LIMIT_REACHED') {
        final used =
            _toInt(
          data['used'],
        );

        final free =
            _toInt(
          data['limit'],
          fallback: 3,
        );

        lastUsage =
            SirajUsage(
          accountType:
              data['accountType']
                      ?.toString() ??
                  'free',

          usedQuestions:
              used,

          freeQuestions:
              free,

          remainingQuestions:
              0,

          paid:
              false,

          unlimited:
              false,
        );

        throw SirajFreeLimitException(
          message:
              data['message']
                      ?.toString() ??
                  'انتهت الأسئلة المجانية لسِراج.',

          usedQuestions:
              used,

          freeQuestions:
              free,
        );
      }

      // ======================================================
      // انتهاء الجلسة
      // ======================================================

      if (response.statusCode == 401) {
        throw Exception(
          'انتهت جلسة تسجيل الدخول. سجلي الدخول مرة أخرى.',
        );
      }

      // ======================================================
      // Firebase غير مهيأ
      // ======================================================

      if (data['code'] ==
          'FIREBASE_NOT_CONFIGURED') {
        throw Exception(
          'خدمة الحسابات غير مهيأة على الخادم.',
        );
      }

      // ======================================================
      // Firestore غير مهيأ
      // ======================================================

      if (data['code'] ==
          'FIRESTORE_NOT_CONFIGURED') {
        throw Exception(
          'قاعدة بيانات سِراج غير مهيأة على الخادم.',
        );
      }

      // ======================================================
      // الذكاء الاصطناعي غير مهيأ
      // ======================================================

      if (data['code'] ==
          'AI_NOT_CONFIGURED') {
        throw Exception(
          'خدمة سِراج الذكية غير مفعلة حاليًا.',
        );
      }

      // ======================================================
      // حد الطلبات
      // ======================================================

      if (response.statusCode == 429) {
        throw Exception(
          'تم الوصول إلى حد الاستخدام مؤقتًا. '
          'حاولي مرة أخرى بعد قليل.',
        );
      }

      // ======================================================
      // خطأ خادم
      // ======================================================

      if (response.statusCode >= 500) {
        throw Exception(
          'خدمة سِراج مشغولة مؤقتًا. '
          'حاولي مرة أخرى.',
        );
      }

      // ======================================================
      // خطأ عام
      // ======================================================

      final message =
          data['message']
                  ?.toString() ??
              data['error']
                  ?.toString() ??
              'حدث خطأ في خادم سِراج.';

      throw Exception(
        '$message (HTTP ${response.statusCode})',
      );
    }

    // --------------------------------------------------------
    // انتهاء الأسئلة المجانية
    // --------------------------------------------------------

    on SirajFreeLimitException {
      rethrow;
    }

    // --------------------------------------------------------
    // خطأ اتصال HTTP
    // --------------------------------------------------------

    on http.ClientException catch (e) {
      throw Exception(
        'تعذر الاتصال بخادم سِراج.\n'
        'تأكدي من تشغيل الخادم ثم حاولي مرة أخرى.\n\n'
        '$e',
      );
    }

    // --------------------------------------------------------
    // JSON غير صالح
    // --------------------------------------------------------

    on FormatException {
      throw Exception(
        'وصل رد غير مفهوم من خادم سِراج.',
      );
    }

    // --------------------------------------------------------
    // أخطاء عادية
    // --------------------------------------------------------

    on Exception {
      rethrow;
    }

    // --------------------------------------------------------
    // أي خطأ آخر
    // --------------------------------------------------------

    catch (e) {
      throw Exception(
        'تعذر الاتصال بسِراج: $e',
      );
    }
  }

  // ==========================================================
  // تحديث معلومات الاستخدام
  // ==========================================================

  Future<SirajUsage> refreshUsage() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'يجب تسجيل الدخول أولًا.',
      );
    }

    final idToken =
        await user.getIdToken();

    if (idToken == null ||
        idToken.trim().isEmpty) {
      throw Exception(
        'تعذر التحقق من حسابك.',
      );
    }

    final uri =
        Uri.parse('$baseUrl/api/usage');

    try {
      final response =
          await http
              .get(
                uri,
                headers: {
                  'Accept':
                      'application/json',

                  'Authorization':
                      'Bearer $idToken',
                },
              )
              .timeout(
                usageTimeout,
              );

      final data =
          _decodeResponse(
        response,
      );

      // ------------------------------------------------------
      // نجاح
      // ------------------------------------------------------

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final usage =
            _usageFromServer(
          data,
        );

        lastUsage =
            usage;

        return usage;
      }

      // ------------------------------------------------------
      // جلسة غير صالحة
      // ------------------------------------------------------

      if (response.statusCode == 401) {
        throw Exception(
          'انتهت جلسة تسجيل الدخول. '
          'سجلي الدخول مرة أخرى.',
        );
      }

      final message =
          data['message']
                  ?.toString() ??
              'تعذر الحصول على معلومات استخدام سِراج.';

      throw Exception(
        '$message (HTTP ${response.statusCode})',
      );
    }

    on http.ClientException catch (e) {
      throw Exception(
        'تعذر الاتصال بخادم سِراج.\n$e',
      );
    }

    on FormatException {
      throw Exception(
        'وصل رد غير صالح من خادم سِراج.',
      );
    }
  }

  // ==========================================================
  // تحويل رد /api/usage إلى SirajUsage
  // ==========================================================

  SirajUsage _usageFromServer(
    Map<String, dynamic> data,
  ) {
    final accountType =
        data['accountType']
                ?.toString() ??
            'free';

    final paid =
        data['paid'] == true;

    final unlimited =
        data['unlimited'] == true;

    final used =
        _toInt(
      data['used'],
    );

    final limit =
        _toInt(
      data['limit'],
      fallback: 3,
    );

    final remaining =
        data['remaining'] == null
            ? (
                unlimited
                    ? 0
                    : _calculateRemaining(
                        limit,
                        used,
                      )
              )
            : _toInt(
                data['remaining'],
              );

    return SirajUsage(
      accountType:
          accountType,

      usedQuestions:
          used,

      freeQuestions:
          unlimited
              ? 0
              : limit,

      remainingQuestions:
          unlimited
              ? 0
              : remaining,

      paid:
          paid,

      unlimited:
          unlimited,
    );
  }

  // ==========================================================
  // تحديث الاستخدام من /api/chat
  // ==========================================================

  void _updateUsageFromChatResponse(
    Map<String, dynamic> data,
  ) {
    final accountType =
        data['accountType']
                ?.toString() ??
            'free';

    final paid =
        data['paid'] == true;

    final freeLimit =
        _toInt(
      data['freeLimit'],
      fallback: 3,
    );

    final usedValue =
        data['questionsUsed'];

    final remainingValue =
        data['questionsRemaining'];

    final unlimited =
        paid &&
        usedValue == null &&
        remainingValue == null;

    final used =
        unlimited
            ? 0
            : _toInt(
                usedValue,
              );

    final remaining =
        unlimited
            ? 0
            : _toInt(
                remainingValue,
              );

    lastUsage =
        SirajUsage(
      accountType:
          accountType,

      usedQuestions:
          used,

      freeQuestions:
          paid
              ? 0
              : freeLimit,

      remainingQuestions:
          remaining,

      paid:
          paid,

      unlimited:
          unlimited,
    );
  }

  // ==========================================================
  // تنظيف تاريخ المحادثة
  // ==========================================================

  List<Map<String, String>> _cleanHistory(
    List<Map<String, String>> history,
  ) {
    return history
        .where(
          (item) {
            final role =
                item['role'];

            final content =
                item['content'];

            if (role == null ||
                content == null) {
              return false;
            }

            if (role != 'user' &&
                role != 'assistant') {
              return false;
            }

            return content
                .trim()
                .isNotEmpty;
          },
        )
        .map(
          (item) {
            return {
              'role':
                  item['role']!
                      .trim(),

              'content':
                  item['content']!
                      .trim(),
            };
          },
        )
        .toList();
  }

  // ==========================================================
  // قراءة JSON من الخادم
  // ==========================================================

  Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    if (response.body
        .trim()
        .isEmpty) {
      throw const FormatException(
        'Empty server response',
      );
    }

    final decoded =
        jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw const FormatException(
        'Invalid JSON object',
      );
    }

    return Map<String, dynamic>.from(
      decoded,
    );
  }

  // ==========================================================
  // حساب المتبقي
  // ==========================================================

  int _calculateRemaining(
    int limit,
    int used,
  ) {
    final remaining =
        limit - used;

    if (remaining < 0) {
      return 0;
    }

    return remaining;
  }

  // ==========================================================
  // تحويل آمن إلى int
  // ==========================================================

  int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(
            value,
          ) ??
          fallback;
    }

    return fallback;
  }

  // ==========================================================
  // المستخدم الحالي
  // ==========================================================

  User? get currentUser =>
      _auth.currentUser;

  // ==========================================================
  // هل المستخدم مسجل الدخول؟
  // ==========================================================

  bool get isLoggedIn =>
      _auth.currentUser != null;

  // ==========================================================
  // عدد الأسئلة المتبقية
  // ==========================================================

  int get remainingQuestions =>
      lastUsage?.remainingQuestions ??
      3;

  // ==========================================================
  // هل انتهت الأسئلة المجانية؟
  // ==========================================================

  bool get hasReachedFreeLimit =>
      lastUsage?.hasReachedFreeLimit ??
      false;

  // ==========================================================
  // نوع الحساب
  // ==========================================================

  String get accountType =>
      lastUsage?.accountType ??
      'free';

  // ==========================================================
  // هل الحساب مدفوع؟
  // ==========================================================

  bool get isPremium =>
      lastUsage?.isPremium ??
      false;

  // ==========================================================
  // عدد الأسئلة المستخدمة
  // ==========================================================

  int get usedQuestions =>
      lastUsage?.usedQuestions ??
      0;

  // ==========================================================
  // الحد المجاني
  // ==========================================================

  int get freeQuestions =>
      lastUsage?.freeQuestions ??
      3;
}