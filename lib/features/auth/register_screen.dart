import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:siraj_app/services/auth_service.dart';
import 'package:siraj_app/services/user_service.dart';

import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // إنشاء الحساب
  // ============================================================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();
      final password = _passwordController.text;

      // ========================================================
      // 1. إنشاء الحساب في Firebase Authentication
      // ========================================================

      debugPrint('========================================');
      debugPrint('REGISTER START');
      debugPrint('EMAIL: $email');
      debugPrint('========================================');

      final credential = await AuthService.register(
        email: email,
        password: password,
      );

      final createdUser = credential.user;

      if (createdUser == null) {
        throw Exception(
          'Firebase Authentication لم يُرجع مستخدمًا.',
        );
      }

      debugPrint('AUTH SUCCESS');
      debugPrint('UID: ${createdUser.uid}');

      // ========================================================
      // 2. حفظ اسم المستخدم في Firebase Authentication
      // ========================================================

      debugPrint('UPDATING DISPLAY NAME...');

      await createdUser.updateDisplayName(name);
      await createdUser.reload();

      debugPrint('DISPLAY NAME SUCCESS');

      // ========================================================
      // 3. إنشاء ملف المستخدم في Firestore
      // ========================================================

      debugPrint('========================================');
      debugPrint('FIRESTORE START');
      debugPrint('COLLECTION: users');
      debugPrint('DOCUMENT: ${createdUser.uid}');
      debugPrint('========================================');

      await UserService.createUserProfile(
        uid: createdUser.uid,
        name: name,
        email: email,
      );

      debugPrint('FIRESTORE SUCCESS');

      // ========================================================
      // 4. التحقق من إنشاء المستند
      // ========================================================

      debugPrint('VERIFYING FIRESTORE DOCUMENT...');

      final verifySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(createdUser.uid)
          .get();

      if (!verifySnapshot.exists) {
        throw Exception(
          'تم إنشاء الحساب ولكن لم يتم العثور على ملف المستخدم في Firestore.',
        );
      }

      debugPrint('FIRESTORE VERIFICATION SUCCESS');
      debugPrint(
        'DOCUMENT DATA: ${verifySnapshot.data()}',
      );

      // ========================================================
      // 5. النجاح النهائي
      // ========================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إنشاء الحساب بنجاح',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // الانتقال مباشرة إلى الصفحة الرئيسية
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    }

    // ==========================================================
    // أخطاء Firebase Authentication
    // ==========================================================

    on FirebaseAuthException catch (e) {
      debugPrint('========================================');
      debugPrint('FIREBASE AUTH ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('========================================');

      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'هذا البريد الإلكتروني مستخدم بالفعل.';
          break;

        case 'invalid-email':
          message =
              'البريد الإلكتروني غير صالح.';
          break;

        case 'weak-password':
          message =
              'كلمة المرور ضعيفة. استخدمي كلمة مرور أقوى.';
          break;

        case 'operation-not-allowed':
          message =
              'تسجيل الدخول بالبريد الإلكتروني غير مفعّل في Firebase.';
          break;

        case 'network-request-failed':
          message =
              'تعذر الاتصال بالإنترنت.';
          break;

        case 'user-disabled':
          message =
              'هذا الحساب معطّل.';
          break;

        default:
          message =
              'حدث خطأ أثناء إنشاء الحساب.\n\n'
              'Code: ${e.code}\n'
              'Message: ${e.message ?? "غير معروف"}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 8),
        ),
      );
    }

    // ==========================================================
    // أخطاء Firebase / Firestore
    // ==========================================================

    on FirebaseException catch (e) {
      debugPrint('========================================');
      debugPrint('FIREBASE ERROR');
      debugPrint('PLUGIN: ${e.plugin}');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('========================================');

      if (!mounted) return;

      String message;

      if (e.code == 'permission-denied') {
        message =
            'تعذر حفظ بيانات الحساب.\n\n'
            'تحققي من صلاحيات Firestore.';
      } else if (e.code == 'unavailable') {
        message =
            'الخدمة غير متاحة حاليًا.\n'
            'تحققي من الاتصال بالإنترنت.';
      } else {
        message =
            'حدث خطأ أثناء حفظ بيانات الحساب.\n\n'
            'Code: ${e.code}\n'
            'Message: ${e.message ?? "غير معروف"}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 8),
        ),
      );
    }

    // ==========================================================
    // أي خطأ آخر
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('REGISTER GENERAL ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('========================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء إنشاء الحساب.\n\n$e',
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    }

    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // الواجهة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,

      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إنشاء حساب',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [
                const SizedBox(height: 15),

                // =================================================
                // الشعار
                // =================================================

                Container(
                  width: 80,
                  height: 80,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF8E7CC3),
                        Color(0xFFE7A6C8),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E7CC3)
                            .withValues(alpha: 0.20),
                        blurRadius: 20,
                        offset:
                            const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // العنوان
                // =================================================

                const Text(
                  'أنشئي حسابك في سِراج',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'ابدئي رحلتك الروحية معنا',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 35),

                // =================================================
                // الاسم
                // =================================================

                TextFormField(
                  controller: _nameController,

                  textDirection:
                      TextDirection.rtl,

                  keyboardType:
                      TextInputType.name,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      InputDecoration(
                    labelText: 'الاسم',
                    hintText: 'أدخلي اسمك',

                    prefixIcon:
                        const Icon(
                      Icons.person_outline,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'أدخلي اسمك';
                    }

                    if (value.trim().length < 2) {
                      return 'الاسم قصير جدًا';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // البريد الإلكتروني
                // =================================================

                TextFormField(
                  controller:
                      _emailController,

                  textDirection:
                      TextDirection.ltr,

                  keyboardType:
                      TextInputType.emailAddress,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      InputDecoration(
                    labelText:
                        'البريد الإلكتروني',

                    hintText:
                        'أدخلي بريدك الإلكتروني',

                    prefixIcon:
                        const Icon(
                      Icons.email_outlined,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'أدخلي البريد الإلكتروني';
                    }

                    final emailRegex =
                        RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!emailRegex.hasMatch(
                      value.trim(),
                    )) {
                      return 'أدخلي بريدًا إلكترونيًا صحيحًا';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // كلمة المرور
                // =================================================

                TextFormField(
                  controller:
                      _passwordController,

                  textDirection:
                      TextDirection.ltr,

                  obscureText:
                      _obscurePassword,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      InputDecoration(
                    labelText:
                        'كلمة المرور',

                    hintText:
                        'اختاري كلمة مرور قوية',

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'أدخلي كلمة المرور';
                    }

                    if (value.length < 6) {
                      return 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // تأكيد كلمة المرور
                // =================================================

                TextFormField(
                  controller:
                      _confirmPasswordController,

                  textDirection:
                      TextDirection.ltr,

                  obscureText:
                      _obscureConfirmPassword,

                  textInputAction:
                      TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _register();
                    }
                  },

                  decoration:
                      InputDecoration(
                    labelText:
                        'تأكيد كلمة المرور',

                    hintText:
                        'أعيدي إدخال كلمة المرور',

                    prefixIcon:
                        const Icon(
                      Icons.lock_reset_outlined,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'أكدي كلمة المرور';
                    }

                    if (value !=
                        _passwordController.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // =================================================
                // زر إنشاء الحساب
                // =================================================

                SizedBox(
                  height: 56,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _register,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF8E7CC3,
                      ),

                      foregroundColor:
                          Colors.white,

                      disabledBackgroundColor:
                          const Color(
                        0xFFB9B0D4,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,

                              valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'إنشاء الحساب',

                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // تسجيل الدخول
                // =================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    const Text(
                      'لديكِ حساب بالفعل؟',
                    ),

                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  );
                                },

                      child: const Text(
                        'تسجيل الدخول',

                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}