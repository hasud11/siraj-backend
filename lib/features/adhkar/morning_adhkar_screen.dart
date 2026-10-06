import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../chat/chat_screen.dart';

class MorningAdhkarScreen extends StatelessWidget {
  const MorningAdhkarScreen({super.key});

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.cream,

        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          centerTitle: true,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title: const Text(
            'أذكار الصباح',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =========================
                // HEADER
                // =========================
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
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.wb_sunny_rounded,
                        color: Colors.white,
                        size: 36,
                      ),

                      SizedBox(height: 14),

                      Text(
                        'أذكار الصباح',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'ابدئي يومك بذكر الله والطمأنينة.',
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

                // =========================
                // DHIKR 1
                // =========================
                const _DhikrCard(
                  number: '1',
                  text:
                      'آية الكرسي\n'
                      'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
                  repeat: 'مرة واحدة',
                ),

                const SizedBox(height: 12),

                // =========================
                // DHIKR 2
                // =========================
                const _DhikrCard(
                  number: '2',
                  text:
                      'قُلْ هُوَ اللَّهُ أَحَدٌ\n'
                      'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ\n'
                      'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
                  repeat: '3 مرات',
                ),

                const SizedBox(height: 12),

                // =========================
                // DHIKR 3
                // =========================
                const _DhikrCard(
                  number: '3',
                  text:
                      'أصبحنا وأصبح الملك لله، والحمد لله، '
                      'لا إله إلا الله وحده لا شريك له، '
                      'له الملك وله الحمد وهو على كل شيء قدير.',
                  repeat: 'مرة واحدة',
                ),

                const SizedBox(height: 12),

                // =========================
                // DHIKR 4
                // =========================
                const _DhikrCard(
                  number: '4',
                  text:
                      'اللهم بك أصبحنا وبك أمسينا، '
                      'وبك نحيا وبك نموت وإليك النشور.',
                  repeat: 'مرة واحدة',
                ),

                const SizedBox(height: 12),

                // =========================
                // DHIKR 5
                // =========================
                const _DhikrCard(
                  number: '5',
                  text:
                      'رضيت بالله ربًا، وبالإسلام دينًا، '
                      'وبمحمد ﷺ نبيًا.',
                  repeat: '3 مرات',
                ),

                const SizedBox(height: 25),

                // =========================
                // SIRAJ AI CARD
                // =========================
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE8E0D6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.025),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: purple,
                        size: 30,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'هل تريدين معرفة المزيد؟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'يمكنك سؤال سِراج عن أذكار الصباح ومعانيها وطريقة قراءتها.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _askSiraj(
                              context,
                              'أريد أن أعرف أذكار الصباح ومعانيها وفوائدها وطريقة قراءتها بشكل صحيح.',
                            );
                          },
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'اسألي سِراج',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
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
      ),
    );
  }
}

// =====================================================
// DHIKR CARD
// =====================================================

class _DhikrCard extends StatelessWidget {
  final String number;
  final String text;
  final String repeat;

  const _DhikrCard({
    required this.number,
    required this.text,
    required this.repeat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E0D6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // رقم الذكر
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAE3F8),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFF7460B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'ذكر الصباح',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // عدد التكرار
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F1E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  repeat,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              height: 2,
            ),
          ),
        ],
      ),
    );
  }
}