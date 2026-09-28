import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color purple = Color(0xFF806CB2);
  static const Color lightPurple = Color(0xFFEDE6F5);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final String email =
        user?.email ?? 'لا يوجد بريد إلكتروني';

    final String name =
        (user?.displayName != null &&
                user!.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : 'مستخدم سِراج';

    return Scaffold(
      backgroundColor: AppColors.cream,

      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'حسابي',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // =====================================================
              // بطاقة الحساب
              // =====================================================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF8E7CC3),
                      Color(0xFFC99ACB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // الصورة
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.45,
                          ),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // الاسم
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // البريد
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.90,
                        ),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // الحساب المجاني
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'الحساب المجاني',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =====================================================
              // الحساب
              // =====================================================

              _sectionTitle('حسابك'),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.person_outline_rounded,
                title: 'بيانات الحساب',
                subtitle: 'عرض بيانات حسابك الحالية',
                onTap: () {
                  _showAccountInfo(
                    context,
                    name,
                    email,
                  );
                },
              ),

              const SizedBox(height: 10),

              _ProfileOption(
                icon: Icons.workspace_premium_outlined,
                title: 'نوع الحساب',
                subtitle: 'الحساب المجاني',
                onTap: () {
                  _showAccountType(context);
                },
              ),

              const SizedBox(height: 28),

              // =====================================================
              // سراج AI
              // =====================================================

              _sectionTitle('سِراج AI'),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.auto_awesome_rounded,
                title: 'استخدام سِراج',
                subtitle: 'معلومات استخدام خدمات سِراج AI',
                onTap: () {
                  _showUsageDialog(context);
                },
              ),

              const SizedBox(height: 28),

              // =====================================================
              // الإعدادات
              // =====================================================

              _sectionTitle('الإعدادات'),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.settings_outlined,
                title: 'إعدادات التطبيق',
                subtitle: 'اللغة والمظهر وإعدادات التطبيق',
                onTap: () {
                  _showSettingsDialog(context);
                },
              ),

              const SizedBox(height: 28),

              // =====================================================
              // الأمان
              // =====================================================

              _sectionTitle('الأمان'),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.lock_reset_outlined,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث كلمة المرور الخاصة بحسابك',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _ProfileOption(
                icon: Icons.delete_outline_rounded,
                title: 'حذف الحساب',
                subtitle: 'حذف حسابك وبيانات تسجيل الدخول',
                iconColor: Colors.redAccent,
                onTap: () {
                  _deleteAccount(context);
                },
              ),

              const SizedBox(height: 10),

              _ProfileOption(
                icon: Icons.logout_rounded,
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من حساب سِراج',
                iconColor: Colors.redAccent,
                onTap: () {
                  _logout(context);
                },
              ),

              const SizedBox(height: 28),

              // =====================================================
              // حول سراج
              // =====================================================

              _sectionTitle('حول سِراج'),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.info_outline_rounded,
                title: 'عن سِراج',
                subtitle: 'معلومات عن التطبيق والإصدار',
                onTap: () {
                  _showAbout(context);
                },
              ),

              const SizedBox(height: 10),

              _ProfileOption(
                icon: Icons.privacy_tip_outlined,
                title: 'الخصوصية',
                subtitle: 'معلومات الخصوصية وحماية البيانات',
                onTap: () {
                  _showPrivacy(context);
                },
              ),

              const SizedBox(height: 30),

              // =====================================================
              // الإصدار
              // =====================================================

              const Text(
                'سِراج',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'الإصدار 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'جميع الحقوق محفوظة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // عنوان القسم
  // ===============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  // ===============================================================
  // بيانات الحساب
  // ===============================================================

  void _showAccountInfo(
    BuildContext context,
    String name,
    String email,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'بيانات الحساب',
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(
                title: 'الاسم',
                value: name,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                title: 'البريد الإلكتروني',
                value: email,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // نوع الحساب
  // ===============================================================

  void _showAccountType(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'نوع الحساب',
            textAlign: TextAlign.right,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: purple,
                size: 48,
              ),
              SizedBox(height: 15),
              Text(
                'الحساب المجاني',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'يمكنك استخدام الخدمات المتاحة للحساب المجاني.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.6,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // استخدام سراج
  // ===============================================================

  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'استخدام سِراج',
            textAlign: TextAlign.right,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: purple,
                size: 45,
              ),
              SizedBox(height: 15),
              Text(
                'الحساب المجاني',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'سيتم ربط إحصاءات الاستخدام الفعلية مع خدمات سِراج AI عند تفعيل نظام الاستخدام.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.6,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // إعدادات التطبيق
  // ===============================================================

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'إعدادات التطبيق',
            textAlign: TextAlign.right,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.language_rounded,
                  color: purple,
                ),
                title: Text('اللغة'),
                subtitle: Text('العربية'),
              ),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.palette_outlined,
                  color: purple,
                ),
                title: Text('المظهر'),
                subtitle: Text('المظهر الافتراضي'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // عن سراج
  // ===============================================================

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'عن سِراج',
            textAlign: TextAlign.right,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: purple,
                size: 50,
              ),
              SizedBox(height: 15),
              Text(
                'سِراج AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'مساعد ذكي يقدم خدمات ومعلومات وأدوات رقمية للمستخدم.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.7,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // الخصوصية
  // ===============================================================

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'الخصوصية',
            textAlign: TextAlign.right,
          ),
          content: const SingleChildScrollView(
            child: Text(
              'نحترم خصوصية المستخدم ونسعى إلى حماية بيانات الحساب والمعلومات التي يتم إدخالها داخل التطبيق. '
              'سيتم توضيح سياسة الخصوصية الكاملة قبل إطلاق النسخة النهائية من التطبيق.',
              textAlign: TextAlign.right,
              style: TextStyle(
                height: 1.8,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // حذف الحساب
  // ===============================================================

  Future<void> _deleteAccount(
    BuildContext context,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'حذف الحساب',
            textAlign: TextAlign.right,
          ),
          content: const Text(
            'هل أنت متأكد من حذف حسابك؟\n\nهذا الإجراء لا ينبغي تنفيذه إلا بعد ربط حذف بيانات المستخدم من Firebase.',
            textAlign: TextAlign.right,
            style: TextStyle(
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'متابعة',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'سيتم تفعيل حذف الحساب الكامل عند ربط نظام حذف بيانات المستخدم.',
        ),
      ),
    );
  }

  // ===============================================================
  // تسجيل الخروج
  // ===============================================================

  Future<void> _logout(
    BuildContext context,
  ) async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'تسجيل الخروج',
            textAlign: TextAlign.right,
          ),
          content: const Text(
            'هل تريد تسجيل الخروج من حسابك؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }
}

// ==================================================================
// صف معلومات
// ==================================================================

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// عنصر الحساب
// ==================================================================

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE6F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor ??
                      const Color(0xFF806CB2),
                  size: 26,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_left_rounded,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}