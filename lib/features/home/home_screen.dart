import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import '../checker/checker_screen.dart';
import '../chat/chat_screen.dart';
import '../consultation/consultation_screen.dart';
import '../adhkar/adhkar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ============================================================
  // ألوان سِراج
  // ============================================================

  static const Color purpleDark = Color(0xFF21153F);
  static const Color purple = Color(0xFF5E3FA3);
  static const Color cream = Color(0xFFF8F4EC);
  static const Color textDark = Color(0xFF302A42);

  // ============================================================
  // فتح المحادثة
  // ============================================================

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatScreen(),
      ),
    );
  }

  // ============================================================
  // فتح المكتبة
  // ============================================================

  void _openLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdhkarScreen(),
      ),
    );
  }

  // ============================================================
  // فتح الفحص
  // ============================================================

  void _openChecker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CheckerScreen(),
      ),
    );
  }

  // ============================================================
  // الصفحة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: _buildHome(),
        ),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildBottomNavigation(),
      ),
    );
  }

  // ============================================================
  // الرئيسية
  // ============================================================

  Widget _buildHome() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildPurpleHeader(),
        ),

        // --------------------------------------------------------
        // الترحيب
        // --------------------------------------------------------

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              0,
            ),
            child: _buildGreeting(),
          ),
        ),

        // --------------------------------------------------------
        // سراج AI
        // --------------------------------------------------------

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              0,
            ),
            child: _buildAiBanner(),
          ),
        ),

        // --------------------------------------------------------
        // عنوان الخدمات
        // --------------------------------------------------------

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              28,
              20,
              0,
            ),
            child: _buildSectionTitle(
              'السحر والحسد والرقية',
            ),
          ),
        ),

        // --------------------------------------------------------
        // البطاقات
        // --------------------------------------------------------

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            0,
          ),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate(
              [
                _buildFeatureCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'اسأل سِراج',
                  subtitle: 'عن السحر والحسد',
                  iconBackground: const Color(0xFFE8DFFF),
                  iconColor: const Color(0xFF6643A8),
                  onTap: _openChat,
                ),

                _buildFeatureCard(
                  icon: Icons.menu_book_rounded,
                  title: 'الرقية والأذكار',
                  subtitle: 'تحصين وذكر موثوق',
                  iconBackground: const Color(0xFFE4F0EA),
                  iconColor: const Color(0xFF42816D),
                  onTap: _openLibrary,
                ),

                _buildFeatureCard(
                  icon: Icons.shield_rounded,
                  title: 'حلّل رسالة أو ادعاء',
                  subtitle: 'انتبه للاستغلال والتخويف',
                  iconBackground: const Color(0xFFE9E7F6),
                  iconColor: const Color(0xFF6557A2),
                  onTap: _openChecker,
                ),

                _buildFeatureCard(
                  icon: Icons.person_rounded,
                  title: 'استشارة بشرية',
                  subtitle: 'مساعدة موثوقة عند الحاجة',
                  iconBackground: const Color(0xFFFFEBD8),
                  iconColor: const Color(0xFFA66D39),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ConsultationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.42,
            ),
          ),
        ),

        // --------------------------------------------------------
        // برنامج التحصين اليومي
        // --------------------------------------------------------

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              28,
              20,
              0,
            ),
            child: _buildSectionTitle(
              'برنامج التحصين اليومي',
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              14,
              20,
              30,
            ),
            child: _buildDailyProgram(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // الهيدر البنفسجي
  // ============================================================

  Widget _buildPurpleHeader() {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF28184A),
                    Color(0xFF4D2F83),
                    Color(0xFF7254B4),
                  ],
                ),
              ),
            ),

            const Positioned(
              top: 28,
              right: 115,
              child: _Star(size: 5),
            ),

            const Positioned(
              top: 55,
              right: 35,
              child: _Star(size: 7),
            ),

            const Positioned(
              top: 105,
              right: 180,
              child: _Star(size: 4),
            ),

            const Positioned(
              top: 35,
              left: 80,
              child: _Star(size: 6),
            ),

            const Positioned(
              top: 90,
              left: 145,
              child: _Star(size: 4),
            ),

            const Positioned(
              top: 140,
              left: 40,
              child: _Star(size: 6),
            ),

            const Positioned(
              top: 155,
              right: 80,
              child: _Star(size: 4),
            ),

            Positioned(
              top: 72,
              left: 25,
              child: _Planet(
                size: 54,
                color: const Color(0xFF9B83D5),
              ),
            ),

            Positioned(
              top: 42,
              right: 205,
              child: _Planet(
                size: 25,
                color: const Color(0xFFE3C886),
              ),
            ),

            Positioned(
              bottom: 22,
              left: 42,
              child: Transform.rotate(
                angle: -0.12,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 58,
                  color: Colors.white.withValues(alpha: 0.13),
                ),
              ),
            ),

            Positioned(
              bottom: 35,
              left: 105,
              child: Transform.rotate(
                angle: 0.10,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 42,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                20,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _headerCircleButton(
                        Icons.notifications_none_rounded,
                        onTap: () {},
                      ),

                      const Spacer(),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'سِراج',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'رفيقك للتحصين والوعي الروحي',
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.70),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      _headerCircleButton(
                        Icons.person_outline_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'مساحة هادئة لفهم الخوف والتحصين',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'اسأل، تعلّم، تحصّن، وتحقق بوعي',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.70),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // زر الهيدر
  // ============================================================

  Widget _headerCircleButton(
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.13),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 45,
          height: 45,
          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // الترحيب
  // ============================================================

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أهلًا بكِ في سِراج',
          style: TextStyle(
            color: textDark,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'إذا كان السحر أو الحسد أو العين يسبب لكِ القلق، ابدئي بهدوء.',
          style: TextStyle(
            color: textDark.withValues(alpha: 0.60),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // سراج AI
  // ============================================================

  Widget _buildAiBanner() {
    return GestureDetector(
      onTap: _openChat,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6547A8),
              Color(0xFF9A7BDD),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: purple.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'سِراج AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'اسأل عن السحر والحسد والعين والرقية',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // عنوان القسم
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: purple,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // بطاقات الخدمات
  // ============================================================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBackground,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE9E2D9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textDark.withValues(alpha: 0.48),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // البرنامج اليومي
  // ============================================================

  Widget _buildDailyProgram() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DhikrListScreen(
                title: 'أذكار الصباح',
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: const Color(0xFFE8E0D6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0CF),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFD19A39),
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
                      'تحصين الصباح',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'ابدئي يومك بالأذكار والتحصين',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3EFE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: purpleDark,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // شريط التنقل
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        height: 72,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            _openChat();
          }

          if (index == 2) {
            _openLibrary();
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },
        indicatorColor: const Color(0xFFE9E0FA),
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: purple,
            ),
            label: 'الرئيسية',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.chat_bubble_rounded,
              color: purple,
            ),
            label: 'سِراج AI',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
            ),
            selectedIcon: Icon(
              Icons.menu_book_rounded,
              color: purple,
            ),
            label: 'الرقية',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: purple,
            ),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// نجمة
// ============================================================

class _Star extends StatelessWidget {
  final double size;

  const _Star({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      size: size,
      color: Colors.white.withValues(alpha: 0.65),
    );
  }
}

// ============================================================
// كوكب
// ============================================================

class _Planet extends StatelessWidget {
  final double size;
  final Color color;

  const _Planet({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.6,
      height: size * 1.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.25,
            child: Container(
              width: size * 1.45,
              height: size * 0.38,
              decoration: BoxDecoration(
                border: Border.all(
                  color: color.withValues(alpha: 0.55),
                  width: 2,
                ),
                borderRadius:
                    BorderRadius.circular(100),
              ),
            ),
          ),

          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}