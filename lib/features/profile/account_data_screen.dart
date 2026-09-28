import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AccountDataScreen extends StatefulWidget {
  const AccountDataScreen({super.key});

  @override
  State<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends State<AccountDataScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال الاسم'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await user.updateDisplayName(name);
      await user.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات الحساب بنجاح'),
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'حدث خطأ أثناء حفظ البيانات',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ غير متوقع'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final String email =
        user?.email ?? 'لا يوجد بريد إلكتروني';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'بيانات الحساب',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // الاسم
              const Text(
                'الاسم',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'أدخلي اسمك',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF806CB2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF8E7CC3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // البريد الإلكتروني
              const Text(
                'البريد الإلكتروني',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF806CB2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        email,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'لا يمكن تعديل البريد الإلكتروني من هنا.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 35),

              // زر الحفظ
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E7CC3),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFB9ADD5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'حفظ التغييرات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}