import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController =
      TextEditingController();

  final _newPasswordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showMessage(
        'لم يتم العثور على الحساب الحالي.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential =
          EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      // إعادة التحقق من كلمة المرور الحالية
      await user.reauthenticateWithCredential(
        credential,
      );

      // تغيير كلمة المرور
      await user.updatePassword(
        _newPasswordController.text,
      );

      if (!mounted) return;

      _showMessage(
        'تم تغيير كلمة المرور بنجاح.',
        success: true,
      );

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message =
              'كلمة المرور الحالية غير صحيحة.';
          break;

        case 'weak-password':
          message =
              'كلمة المرور الجديدة ضعيفة.';
          break;

        case 'requires-recent-login':
          message =
              'يرجى تسجيل الدخول من جديد ثم المحاولة.';
          break;

        case 'network-request-failed':
          message =
              'تعذر الاتصال بالإنترنت.';
          break;

        default:
          message =
              e.message ??
              'حدث خطأ أثناء تغيير كلمة المرور.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'حدث خطأ أثناء تغيير كلمة المرور.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,

      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تغيير كلمة المرور',
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
                const SizedBox(height: 20),

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
                        color: const Color(
                          0xFF8E7CC3,
                        ).withValues(
                          alpha: 0.20,
                        ),
                        blurRadius: 20,
                        offset:
                            const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.lock_reset,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'تغيير كلمة المرور',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'أدخلي كلمة المرور الحالية ثم اختاري كلمة مرور جديدة.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),

                // كلمة المرور الحالية
                TextFormField(
                  controller:
                      _currentPasswordController,

                  obscureText:
                      _obscureCurrent,

                  textDirection:
                      TextDirection.ltr,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      InputDecoration(
                    labelText:
                        'كلمة المرور الحالية',

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureCurrent =
                              !_obscureCurrent;
                        });
                      },
                      icon: Icon(
                        _obscureCurrent
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
                      return 'أدخلي كلمة المرور الحالية';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // كلمة المرور الجديدة
                TextFormField(
                  controller:
                      _newPasswordController,

                  obscureText:
                      _obscureNew,

                  textDirection:
                      TextDirection.ltr,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      InputDecoration(
                    labelText:
                        'كلمة المرور الجديدة',

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureNew =
                              !_obscureNew;
                        });
                      },
                      icon: Icon(
                        _obscureNew
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
                      return 'أدخلي كلمة المرور الجديدة';
                    }

                    if (value.length < 6) {
                      return 'يجب أن تحتوي على 6 أحرف على الأقل';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // تأكيد كلمة المرور
                TextFormField(
                  controller:
                      _confirmPasswordController,

                  obscureText:
                      _obscureConfirm,

                  textDirection:
                      TextDirection.ltr,

                  textInputAction:
                      TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _changePassword();
                    }
                  },

                  decoration:
                      InputDecoration(
                    labelText:
                        'تأكيد كلمة المرور الجديدة',

                    prefixIcon:
                        const Icon(
                      Icons.lock_reset_outlined,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirm =
                              !_obscureConfirm;
                        });
                      },
                      icon: Icon(
                        _obscureConfirm
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
                      return 'أكدي كلمة المرور الجديدة';
                    }

                    if (value !=
                        _newPasswordController
                            .text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 56,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _changePassword,

                    style:
                        ElevatedButton
                            .styleFrom(
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
                            'حفظ كلمة المرور الجديدة',

                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}