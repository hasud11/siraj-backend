import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
      accountType.toLowerCase() == 'free' &&
      !paid &&
      !unlimited;

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
  static const String baseUrl =
      'https://siraj-backend-ersy.onrender.com';

  static const Duration requestTimeout =
      Duration(seconds: 90);

  static const Duration usageTimeout =
      Duration(seconds: 20);

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseAppCheck _appCheck =
      FirebaseAppCheck.instance;

  SirajUsage? lastUsage;

  // ==========================================================
  // الحصول على Firebase App Check Token
  // ==========================================================

  Future<String?> _getAppCheckToken() async {
    try {
      final token =
          await _appCheck.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        return null;
      }

      return token.trim();
    } catch (e) {
      // لا نكشف تفاصيل App Check للمستخدم.
      // في وضع Audit الحالي يستطيع الطلب الاستمرار،
      // وبعد تفعيل Enforcement على Render سيتم رفض
      // الطلبات التي لا تحمل App Check صالحًا.
      return null;
    }
  }

  // ==========================================================
  // إنشاء Headers آمنة للاتصال مع Render
  // ==========================================================

  Future<Map<String, String>> _buildHeaders(
    String idToken,
  ) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    final appCheckToken =
        await _getAppCheckToken();

    if (appCheckToken != null &&
        appCheckToken.isNotEmpty) {
      headers['X-Firebase-AppCheck'] =
          appCheckToken;
    }

    return headers;
  }

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

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'يجب تسجيل الدخول لاستخدام سِراج.',
      );
    }

    // Firebase ID Token
    final idToken =
        await user.getIdToken();

    if (idToken == null ||
        idToken.trim().isEmpty) {
      throw Exception(
        'تعذر التحقق من حسابك. حاولي تسجيل الدخول مرة أخرى.',
      );
    }

    // ========================================================
    // المسار الموجود فعليًا في index.js
    // ========================================================

    final uri = Uri.parse(
      '$baseUrl/api/ai/chat',
    );

    final cleanHistory =
        _cleanHistory(history);

    try {
      // ======================================================
      // Firebase ID Token + App Check Token
      // ======================================================

      final headers =
          await _buildHeaders(idToken);

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({
              'message': cleanPrompt,
              'history': cleanHistory,
            }),
          )
          .timeout(requestTimeout);

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

        // Backend يضع معلومات الاستخدام داخل usage
        _updateUsageFromChatResponse(data);

        return reply;
      }

      // ======================================================
      // الحد المجاني
      //
      // index.js يعيد HTTP 402
      // والبيانات داخل usage
      // ======================================================

      if (response.statusCode == 402 &&
          data['error'] ==
              'FREE_LIMIT_REACHED') {
        final usageData =
            data['usage'] is Map
                ? Map<String, dynamic>.from(
                    data['usage'] as Map,
                  )
                : <String, dynamic>{};

        final used =
            _toInt(
          usageData['questionsUsed'],
        );

        final free =
            _toInt(
          usageData['questionsLimit'],
          fallback: 3,
        );

        final remaining =
            _toInt(
          usageData['questionsRemaining'],
        );

        final accountType =
            usageData['accountType']
                    ?.toString() ??
                'free';

        lastUsage = SirajUsage(
          accountType: accountType,
          usedQuestions: used,
          freeQuestions: free,
          remainingQuestions: remaining,
        );

        throw SirajFreeLimitException(
          message:
              'انتهت الأسئلة المجانية لسِراج.',
          usedQuestions: used,
          freeQuestions: free,
        );
      }

      // ======================================================
      // Firebase Authentication
      // ======================================================

      if (response.statusCode == 401) {
        final error =
            data['error']
                ?.toString();

        if (error ==
            'AUTH_REQUIRED') {
          throw Exception(
            'لم يتم إرسال جلسة تسجيل الدخول إلى خادم سِراج.',
          );
        }

        if (error ==
            'INVALID_AUTH_TOKEN') {
          throw Exception(
            'جلسة تسجيل الدخول غير صالحة. '
            'سجلي الخروج ثم الدخول مرة أخرى.',
          );
        }

        throw Exception(
          'تعذر التحقق من تسجيل الدخول.',
        );
      }

      // ======================================================
      // Firebase غير مهيأ
      // ======================================================

      if (data['error'] ==
          'FIREBASE_NOT_CONFIGURED') {
        throw Exception(
          'خدمة الحسابات غير مهيأة على الخادم.',
        );
      }

      // ======================================================
      // Firestore غير مهيأ
      // ======================================================

      if (data['error'] ==
          'FIRESTORE_NOT_CONFIGURED') {
        throw Exception(
          'قاعدة بيانات سِراج غير مهيأة على الخادم.',
        );
      }

      // ======================================================
      // المستخدم ليس لديه Profile
      // ======================================================

      if (response.statusCode == 404 &&
          data['error'] ==
              'USER_PROFILE_NOT_FOUND') {
        throw Exception(
          'لم يتم العثور على ملف حسابك في قاعدة بيانات سِراج.',
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
      // خطأ الخادم
      // ======================================================

      if (response.statusCode >= 500) {
        throw Exception(
          'خدمة سِراج مشغولة مؤقتًا. '
          'حاولي مرة أخرى.',
        );
      }

      final message =
          data['message']
                  ?.toString() ??
              data['error']
                  ?.toString() ??
              'حدث خطأ في خادم سِراج.';

      throw Exception(
        '$message (HTTP ${response.statusCode})',
      );
    } on SirajFreeLimitException {
      rethrow;
    } on http.ClientException catch (e) {
      throw Exception(
        'تعذر الاتصال بخادم سِراج.\n$e',
      );
    } on FormatException {
      throw Exception(
        'وصل رد غير مفهوم من خادم سِراج.',
      );
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception(
        'تعذر الاتصال بسِراج: $e',
      );
    }
  }

  // ==========================================================
  // معلومات الاستخدام
  //
  // المسار الموجود فعليًا في index.js:
  // /api/usage
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

    final uri = Uri.parse(
      '$baseUrl/api/usage',
    );

    try {
      // ======================================================
      // Firebase ID Token + App Check Token
      // ======================================================

      final headers =
          await _buildHeaders(idToken);

      final response =
          await http
              .get(
                uri,
                headers: headers,
              )
              .timeout(usageTimeout);

      final data =
          _decodeResponse(response);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final usage =
            _usageFromServer(data);

        lastUsage = usage;

        return usage;
      }

      if (response.statusCode == 401) {
        throw Exception(
          'انتهت جلسة تسجيل الدخول. '
          'سجلي الدخول مرة أخرى.',
        );
      }

      final message =
          data['message']
                  ?.toString() ??
              data['error']
                  ?.toString() ??
              'تعذر الحصول على معلومات استخدام سِراج.';

      throw Exception(
        '$message (HTTP ${response.statusCode})',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'تعذر الاتصال بخادم سِراج.\n$e',
      );
    } on FormatException {
      throw Exception(
        'وصل رد غير صالح من خادم سِراج.',
      );
    }
  }

  // ==========================================================
  // تحويل /api/usage
  // ==========================================================

  SirajUsage _usageFromServer(
    Map<String, dynamic> data,
  ) {
    final accountType =
        data['accountType']
                ?.toString() ??
            'free';

    final used =
        _toInt(
      data['questionsUsed'],
    );

    final limit =
        _toInt(
      data['questionsLimit'],
      fallback: 3,
    );

    final remaining =
        _toInt(
      data['questionsRemaining'],
      fallback:
          _calculateRemaining(
        limit,
        used,
      ),
    );

    final unlimited =
        accountType.toLowerCase() ==
            'premium' ||
        accountType.toLowerCase() ==
            'pro' ||
        accountType.toLowerCase() ==
            'paid' ||
        accountType.toLowerCase() ==
            'subscription' ||
        accountType.toLowerCase() ==
            'subscriber';

    return SirajUsage(
      accountType: accountType,
      usedQuestions: used,
      freeQuestions:
          unlimited ? 0 : limit,
      remainingQuestions:
          unlimited ? 0 : remaining,
      paid: unlimited,
      unlimited: unlimited,
    );
  }

  // ==========================================================
  // تحديث الاستخدام بعد نجاح المحادثة
  // ==========================================================

  void _updateUsageFromChatResponse(
    Map<String, dynamic> data,
  ) {
    final usageData =
        data['usage'] is Map
            ? Map<String, dynamic>.from(
                data['usage'] as Map,
              )
            : <String, dynamic>{};

    final accountType =
        usageData['accountType']
                ?.toString() ??
            'free';

    final unlimited =
        accountType.toLowerCase() ==
            'premium' ||
        accountType.toLowerCase() ==
            'pro' ||
        accountType.toLowerCase() ==
            'paid' ||
        accountType.toLowerCase() ==
            'subscription' ||
        accountType.toLowerCase() ==
            'subscriber';

    final used =
        _toInt(
      usageData['questionsUsed'],
    );

    final freeLimit =
        _toInt(
      usageData['questionsLimit'],
      fallback: 3,
    );

    final remaining =
        _toInt(
      usageData['questionsRemaining'],
    );

    lastUsage = SirajUsage(
      accountType: accountType,
      usedQuestions: used,
      freeQuestions:
          unlimited ? 0 : freeLimit,
      remainingQuestions:
          unlimited ? 0 : remaining,
      paid: unlimited,
      unlimited: unlimited,
    );
  }

  // ==========================================================
  // تنظيف تاريخ المحادثة
  // ==========================================================

  List<Map<String, String>> _cleanHistory(
    List<Map<String, String>> history,
  ) {
    return history
        .where((item) {
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
        })
        .map((item) {
          return {
            'role':
                item['role']!.trim(),
            'content':
                item['content']!.trim(),
          };
        })
        .toList();
  }

  // ==========================================================
  // قراءة JSON
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
        jsonDecode(response.body);

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

    return remaining < 0
        ? 0
        : remaining;
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
      return int.tryParse(value) ??
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
  // الأسئلة المتبقية
  // ==========================================================

  int get remainingQuestions =>
      lastUsage?.remainingQuestions ??
      3;

  // ==========================================================
  // هل انتهت الأسئلة؟
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
  // هل Premium؟
  // ==========================================================

  bool get isPremium =>
      lastUsage?.isPremium ??
      false;

  // ==========================================================
  // الأسئلة المستخدمة
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