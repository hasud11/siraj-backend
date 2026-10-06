import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'data/dhikr_data.dart';
import 'models/dhikr_item.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  final List<_DhikrCategory> _categories = [
    _DhikrCategory(
      title: 'أذكار الصباح',
      subtitle: 'ابدأ يومك بطمأنينة',
      icon: Icons.wb_sunny_rounded,
      isPremium: false,
      adhkar: DhikrData.morning,
    ),
    _DhikrCategory(
      title: 'أذكار المساء',
      subtitle: 'اختم يومك بذكر الله',
      icon: Icons.nights_stay_rounded,
      isPremium: false,
      adhkar: DhikrData.evening,
    ),
    _DhikrCategory(
      title: 'أذكار النوم',
      subtitle: 'أذكار قبل النوم',
      icon: Icons.bedtime_rounded,
      isPremium: true,
      adhkar: DhikrData.sleep,
    ),
    _DhikrCategory(
      title: 'أذكار الاستيقاظ',
      subtitle: 'ابدأ صباحك بالحمد',
      icon: Icons.alarm_rounded,
      isPremium: false,
      adhkar: DhikrData.awakening,
    ),
    _DhikrCategory(
      title: 'بعد الصلاة',
      subtitle: 'أذكار ما بعد الصلاة',
      icon: Icons.mosque_rounded,
      isPremium: true,
      adhkar: DhikrData.afterPrayer,
    ),
    _DhikrCategory(
      title: 'أدعية مختارة',
      subtitle: 'أدعية يومية متنوعة',
      icon: Icons.favorite_rounded,
      isPremium: true,
      adhkar: DhikrData.selectedDuas,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'الأذكار',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textDark,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 22),
            const Text(
              'اختر القسم',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            ..._categories.map(_buildCategoryCard),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF403662),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Color(0x25FFFFFF),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.gold,
              size: 29,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لحظات من السكينة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'اجعل الذكر جزءًا هادئًا من يومك.',
                  style: TextStyle(
                    color: Color(0xFFDCD7E8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Category Card
  // ============================================================

  Widget _buildCategoryCard(
    _DhikrCategory category,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (category.isPremium) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PremiumLibraryScreen(
                    categoryTitle: category.title,
                    adhkar: category.adhkar,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DhikrListScreen(
                    title: category.title,
                    adhkar: category.adhkar,
                  ),
                ),
              );
            }
          },
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: category.isPremium
                    ? AppColors.gold.withValues(alpha: 0.30)
                    : AppColors.purple.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: category.isPremium
                        ? AppColors.gold.withValues(alpha: 0.12)
                        : AppColors.purpleLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.isPremium
                        ? AppColors.gold
                        : AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              category.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (category.isPremium) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold
                                    .withValues(alpha: 0.14),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_rounded,
                                    size: 11,
                                    color: AppColors.gold,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Plus',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  category.isPremium
                      ? Icons.lock_outline_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: category.isPremium
                      ? AppColors.gold
                      : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// شاشة Plus
// ============================================================

class PremiumLibraryScreen extends StatelessWidget {
  final String categoryTitle;
  final List<DhikrItem> adhkar;

  const PremiumLibraryScreen({
    super.key,
    required this.categoryTitle,
    this.adhkar = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: AppColors.textDark,
          ),
          title: const Text(
            'سِراج Plus',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            35,
          ),
          child: Column(
            children: [
              _buildPremiumHero(),
              const SizedBox(height: 18),
              _buildPreviewCard(),
              const SizedBox(height: 18),
              _buildFeaturesCard(),
              const SizedBox(height: 24),
              _buildSubscribeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF403662),
            Color(0xFF5A4770),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.gold,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            categoryTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'هذا القسم متاح ضمن تجربة سِراج Plus',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFDCD7E8),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final DhikrItem? preview =
        adhkar.isNotEmpty ? adhkar.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.visibility_rounded,
                color: AppColors.gold,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'معاينة',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              preview?.text ??
                  'محتوى موثق ومنظم يساعدك على بناء روتين ثابت وهادئ في يومك.',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '🔒 المحتوى الكامل متاح لمشتركي سِراج Plus',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    const features = [
      'المحتوى الكامل للأقسام المميزة',
      'برامج ذكر منظمة حسب الوقت',
      'تذكيرات يومية',
      'متابعة التقدم والالتزام',
      'تجربة أكثر تخصيصًا مع سِراج',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ماذا تحصل عليه مع Plus؟',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: AppColors.success
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'نظام الاشتراكات سيتم ربطه في الخطوة القادمة.',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 17,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.gold,
            ),
            SizedBox(width: 8),
            Text(
              'فتح سِراج Plus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// شاشة الأذكار
// ============================================================

class DhikrListScreen extends StatefulWidget {
  final String title;
  final List<DhikrItem>? adhkar;

  const DhikrListScreen({
    super.key,
    required this.title,
    this.adhkar,
  });

  @override
  State<DhikrListScreen> createState() =>
      _DhikrListScreenState();
}

class _DhikrListScreenState
    extends State<DhikrListScreen> {
  late final List<DhikrItem> _adhkar;
  late final List<int> _currentCounts;

  @override
  void initState() {
    super.initState();

    _adhkar =
        widget.adhkar ?? _getAdhkarByTitle(widget.title);

    _currentCounts = List<int>.filled(
      _adhkar.length,
      0,
    );

    debugPrint(
      'SIRAJ DHIKR: ${widget.title} = ${_adhkar.length} items',
    );
  }

  List<DhikrItem> _getAdhkarByTitle(String title) {
    switch (title.trim()) {
      case 'أذكار الصباح':
        return DhikrData.morning;

      case 'أذكار المساء':
        return DhikrData.evening;

      case 'أذكار النوم':
        return DhikrData.sleep;

      case 'أذكار الاستيقاظ':
        return DhikrData.awakening;

      case 'بعد الصلاة':
        return DhikrData.afterPrayer;

      case 'أدعية مختارة':
        return DhikrData.selectedDuas;

      default:
        debugPrint(
          'SIRAJ DHIKR: unknown category "$title"',
        );
        return <DhikrItem>[];
    }
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
          title: Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textDark,
          ),
        ),
        body: _adhkar.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  30,
                ),
                itemCount: _adhkar.length,
                itemBuilder: (context, index) {
                  return _buildDhikrCard(
                    _adhkar[index],
                    index,
                  );
                },
              ),
      ),
    );
  }

  // ============================================================
  // Empty State
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد أذكار في هذا القسم',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'القسم: ${widget.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Dhikr Card
  // ============================================================

  Widget _buildDhikrCard(
    DhikrItem dhikr,
    int index,
  ) {
    final int current = _currentCounts[index];

    final int targetCount =
        dhikr.count > 0 ? dhikr.count : 1;

    final bool completed =
        current >= targetCount;

    final double progress =
        (current / targetCount).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cardWidth = constraints.maxWidth;

          return SizedBox(
            width: cardWidth,
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // عنوان الذكر
                  Text(
                    dhikr.title,
                    textAlign: TextAlign.right,
                    softWrap: true,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // نص الذكر
                  Text(
                    dhikr.text,
                    textAlign: TextAlign.right,
                    softWrap: true,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 19,
                      height: 1.9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // المصدر والتصنيف
                  Container(
                    width: cardWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 17,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                dhikr.source,
                                softWrap: true,
                                style: const TextStyle(
                                  color:
                                      AppColors.textMuted,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'التصنيف: ${dhikr.grade}',
                          softWrap: true,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // شريط التقدم
                  SizedBox(
                    width: cardWidth,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor:
                            AppColors.purpleLight,
                        valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                          AppColors.purple,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // حالة الذكر
                  Text(
                    completed
                        ? 'تم بحمد الله ✓'
                        : 'التكرار: $current / $targetCount',
                    textAlign: TextAlign.right,
                    softWrap: true,
                    style: TextStyle(
                      color: completed
                          ? AppColors.success
                          : AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // زر الذكر
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: completed
                          ? null
                          : () {
                              setState(() {
                                _currentCounts[index] =
                                    current + 1;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.purpleLight,
                        disabledForegroundColor:
                            AppColors.success,
                        minimumSize:
                            const Size.fromHeight(50),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        completed ? 'تم ✓' : 'ذكر',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// نموذج القسم
// ============================================================

class _DhikrCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPremium;
  final List<DhikrItem> adhkar;

  const _DhikrCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPremium,
    required this.adhkar,
  });
}