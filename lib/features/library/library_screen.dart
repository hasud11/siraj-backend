import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const Color navy = Color(0xFF292546);
  static const Color purple = Color(0xFF7460B8);
  static const Color cream = Color(0xFFF8F4EC);
  static const Color textDark = Color(0xFF302A42);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        centerTitle: false,

        title: const Text(
          'المكتبة',
          style: TextStyle(
            color: navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(
              left: 16,
            ),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE7DFD2),
              ),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: navy,
              size: 22,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // مقدمة
                // ==================================================

                const Text(
                  'المعرفة بين يديك',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'اقرئي واستكشفي محتوى سِراج بهدوء وطمأنينة.',
                  style: TextStyle(
                    color: textDark.withOpacity(0.58),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // بطاقة سراج AI
                // ==================================================

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ChatScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(24),

                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFF51427F),
                          Color(0xFF8172C2),
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF51427F,
                          ).withOpacity(0.20),
                          blurRadius: 18,
                          offset:
                              const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.17),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اسألي سِراج',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'اسألي عن أي موضوع تريدين معرفته',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // العنوان
                // ==================================================

                const Text(
                  'الأقسام',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // شبكة الأقسام
                // ==================================================

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.12,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  children: [
                    _LibraryCard(
                      icon: Icons.menu_book_rounded,
                      title: 'الأذكار',
                      subtitle:
                          'أذكار الصباح والمساء',
                      background:
                          const Color(0xFFE8E2F7),
                      iconColor:
                          const Color(0xFF6955A4),
                      onTap: () {},
                    ),

                    _LibraryCard(
                      icon: Icons.favorite_rounded,
                      title: 'الرقية الشرعية',
                      subtitle:
                          'معلومات وأذكار',
                      background:
                          const Color(0xFFF4E3EC),
                      iconColor:
                          const Color(0xFFA65E7E),
                      onTap: () {},
                    ),

                    _LibraryCard(
                      icon: Icons.shield_rounded,
                      title: 'التحصين',
                      subtitle:
                          'روتين يومي',
                      background:
                          const Color(0xFFE1EFEB),
                      iconColor:
                          const Color(0xFF43887D),
                      onTap: () {},
                    ),

                    _LibraryCard(
                      icon: Icons.wb_sunny_rounded,
                      title: 'الأدعية',
                      subtitle:
                          'أدعية مختارة',
                      background:
                          const Color(0xFFFFF0D3),
                      iconColor:
                          const Color(0xFFC08C32),
                      onTap: () {},
                    ),

                    _LibraryCard(
                      icon: Icons.visibility_rounded,
                      title: 'العين والحسد',
                      subtitle:
                          'معلومات توعوية',
                      background:
                          const Color(0xFFE8E9EF),
                      iconColor:
                          const Color(0xFF646A83),
                      onTap: () {},
                    ),

                    _LibraryCard(
                      icon: Icons.info_outline_rounded,
                      title: 'السحر والشعوذة',
                      subtitle:
                          'التوعية والحذر',
                      background:
                          const Color(0xFFE9E4F0),
                      iconColor:
                          const Color(0xFF705B82),
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // محتوى مقترح
                // ==================================================

                const Text(
                  'محتوى مقترح',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                _ArticleCard(
                  icon: Icons.nights_stay_rounded,
                  title: 'أذكار المساء',
                  subtitle:
                      'أذكار تساعدك على إنهاء يومك بهدوء.',
                  iconBackground:
                      const Color(0xFFE6E1F4),
                  iconColor:
                      const Color(0xFF66549C),
                  onTap: () {},
                ),

                const SizedBox(height: 10),

                _ArticleCard(
                  icon: Icons.self_improvement_rounded,
                  title: 'الطمأنينة والهدوء',
                  subtitle:
                      'خطوات بسيطة للتعامل مع القلق والخوف.',
                  iconBackground:
                      const Color(0xFFE3EFEA),
                  iconColor:
                      const Color(0xFF4A8A7B),
                  onTap: () {},
                ),

                const SizedBox(height: 10),

                _ArticleCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'اسألي سِراج',
                  subtitle:
                      'إذا لم تجدي ما تبحثين عنه، تحدثي مع سِراج AI.',
                  iconBackground:
                      const Color(0xFFFFEED0),
                  iconColor:
                      const Color(0xFFC18D36),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ChatScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// بطاقة القسم
// ================================================================

class _LibraryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(22),

        child: Container(
          padding:
              const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(22),

            border: Border.all(
              color:
                  const Color(0xFFE8E0D6),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.035),
                blurRadius: 10,
                offset:
                    const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: background,
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Color(0xFF302A42),
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
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
// بطاقة المقال
// ================================================================

class _ArticleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(20),

        child: Container(
          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color:
                  const Color(0xFFE8E0D6),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF302A42),
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF292546),
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}