import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../chat/chat_screen.dart';

import 'morning_adhkar_screen.dart';
class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  static const Color purple = Color(0xFF7460B8);
  static const Color deepPurple = Color(0xFF403466);

  void _askSiraj(
    BuildContext context,
    String question,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          initialMessage: question,
        ),
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
          'الأذكار والرقية',
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
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [

              // ==================================================
              // المقدمة
              // ==================================================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5A4A91),
                      Color(0xFF8172C2),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius:
                      BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 35,
                    ),

                    SizedBox(height: 14),

                    Text(
                      'الأذكار والرقية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'مساحة هادئة للأذكار والرقية الشرعية والمعلومات التوعوية.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // الأذكار
              // ==================================================

              const Text(
                'الأذكار',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _SectionCard(
                icon: Icons.wb_sunny_outlined,
                title: 'أذكار الصباح',
                subtitle:
                    'ابدئي يومك بالذكر والطمأنينة',
                iconColor:
                    const Color(0xFFD19A39),
                iconBackground:
                    const Color(0xFFFFF0CF),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MorningAdhkarScreen(),
    ),
  );
},
              ),

              const SizedBox(height: 10),

              _SectionCard(
                icon: Icons.nightlight_round,
                title: 'أذكار المساء',
                subtitle:
                    'أذكار المساء قبل النوم',
                iconColor:
                    const Color(0xFF685A80),
                iconBackground:
                    const Color(0xFFEAE7F0),
                onTap: () {
                  _askSiraj(
                    context,
                    'أريد أذكار المساء مع توضيح كيفية قراءتها.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _SectionCard(
                icon: Icons.favorite_border_rounded,
                title: 'أدعية مختارة',
                subtitle:
                    'أدعية للطمأنينة والراحة',
                iconColor:
                    const Color(0xFFA55D7D),
                iconBackground:
                    const Color(0xFFF5E5EE),
                onTap: () {
                  _askSiraj(
                    context,
                    'أريد أدعية مختارة للطمأنينة وراحة القلب.',
                  );
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // الرقية الشرعية
              // ==================================================

              const Text(
                'الرقية الشرعية',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _SectionCard(
                icon: Icons.shield_outlined,
                title: 'ما هي الرقية الشرعية؟',
                subtitle:
                    'تعريف مبسط وطريقة التعامل معها',
                iconColor:
                    const Color(0xFF52738E),
                iconBackground:
                    const Color(0xFFE7EEF5),
                onTap: () {
                  _askSiraj(
                    context,
                    'ما هي الرقية الشرعية الصحيحة؟ أريد شرحًا مبسطًا بعيدًا عن التخويف والخرافات.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _SectionCard(
                icon: Icons.auto_awesome_rounded,
                title: 'اسأل سِراج عن الرقية',
                subtitle:
                    'احصلي على توضيح وإرشاد من سِراج AI',
                iconColor: purple,
                iconBackground:
                    const Color(0xFFEAE7F7),
                onTap: () {
                  _askSiraj(
                    context,
                    'أريد أن أسألك عن الرقية الشرعية.',
                  );
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // تنبيه
              // ==================================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        const Color(0xFFE8E0D6),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: purple,
                      size: 23,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'سِراج يقدم محتوى توعويًا وإرشاديًا، ولا يغني عن استشارة المختصين عند الحاجة.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color:
                              AppColors.textDark,
                          fontSize: 12,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// بطاقة القسم
// ================================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign:
                          TextAlign.right,
                      style: const TextStyle(
                        color:
                            AppColors.textDark,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      textAlign:
                          TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
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