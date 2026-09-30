import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/ai_service.dart';

class CheckerScreen extends StatefulWidget {
  const CheckerScreen({super.key});

  @override
  State<CheckerScreen> createState() => _CheckerScreenState();
}

class _CheckerScreenState extends State<CheckerScreen> {
  final AiService _aiService = AiService();

  final TextEditingController _controller =
      TextEditingController();

  bool _isChecking = false;
  String? _result;

  String _selectedMode = 'رسالة أو ادعاء';

  final List<Map<String, dynamic>> _modes = [
    {
      'title': 'رسالة أو ادعاء',
      'subtitle': 'شخص أخبرني أن لدي سحرًا أو حسدًا',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    {
      'title': 'أخاف من السحر',
      'subtitle': 'أشعر بالخوف وأريد معرفة ماذا أفعل',
      'icon': Icons.shield_outlined,
    },
    {
      'title': 'الحسد أو العين',
      'subtitle': 'أريد التعامل مع خوفي من الحسد أو العين',
      'icon': Icons.visibility_outlined,
    },
    {
      'title': 'رقية شرعية',
      'subtitle': 'أريد إرشادات للرقية الذاتية',
      'icon': Icons.menu_book_outlined,
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // اختيار نوع الفحص
  // ============================================================

  void _selectMode(String mode) {
    setState(() {
      _selectedMode = mode;
      _result = null;
    });
  }

  // ============================================================
  // بدء الفحص
  // ============================================================

  Future<void> _checkContent() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
      _result = null;
    });

    try {
      final prompt = '''
أنت "سِراج"، مساعد عربي متخصص في التوعية الروحية والرقية الشرعية والتحصين، ويهتم خصوصًا بموضوعات السحر والحسد والعين.

نوع طلب المستخدم:
$_selectedMode

النص الذي أدخله المستخدم:
"$text"

حلّل الحالة بهدوء ووضوح باللغة العربية.

قواعد مهمة جدًا:

1. لا تشخّص المستخدم بأنه مصاب بالسحر أو الحسد أو العين اعتمادًا على الأعراض أو الكلام فقط.

2. لا تقل إن عرضًا معينًا يثبت وجود سحر أو حسد أو عين.

3. لا تحدد شخصًا على أنه ساحر أو حاسد أو متسبب في ضرر خارق للطبيعة.

4. إذا كان هناك شخص يدعي أنه معالج أو راقٍ، فحلّل كلامه من ناحية مؤشرات الاستغلال والضغط والتخويف وطلب المال أو الصور أو المعلومات الخاصة.

5. إذا كان هناك طلب مالي، أو طلب صور شخصية أو صور للجسد، أو طلب معلومات حساسة، أو ضغط للدفع، أو تخويف شديد، أو مطالبة بإيقاف علاج طبي؛ وضّح أن هذه مؤشرات تستحق الحذر والتحقق.

6. إذا كان المستخدم خائفًا من السحر أو الحسد، لا تزيد خوفه. ابدأ بتهدئته ثم أعطه خطوات عملية آمنة.

7. يمكنك تقديم إرشادات عامة للرقية الشرعية الذاتية والأذكار والدعاء بصورة هادئة، دون ادعاء أن ذلك يثبت وجود مرض أو سحر.

8. إذا ذكر المستخدم أعراضًا جسدية أو نفسية شديدة أو مستمرة، شجعه أيضًا على استشارة مختص طبي أو نفسي مناسب، ولا تنسب الأعراض تلقائيًا إلى سبب روحي.

9. إذا ظهر خطر فوري أو إيذاء للنفس أو للآخرين، أعطِ الأولوية للسلامة واطلب المساعدة الطارئة المناسبة.

10. لا تستخدم عبارات تخويف مثل:
"السحر مؤكد"
"أنت مصاب بسحر قوي"
"فلان سحرك"
"هناك جن بداخلك"
إلا إذا كان المستخدم يذكر هذه العبارات على أنها كلام شخص آخر، وعندها انسبها بوضوح إلى صاحبها ولا تؤكدها.

11. فرّق بوضوح بين:
- ما قاله المستخدم.
- ما يمكن استنتاجه من النص.
- ما لا يمكن إثباته من النص.
- الخطوة الآمنة التالية.

12. إذا كان الطلب عن الرقية، أعطِ خطوات عملية مختصرة للرقية الذاتية دون مبالغة أو وعود بالشفاء.

أريد النتيجة بهذا التنظيم قدر الإمكان:

الخلاصة:
شرح مختصر ومطمئن.

ما الذي يظهر من كلامك:
النقاط المهمة الموجودة في النص.

ما الذي لا يمكن إثباته:
وضح بصدق ما لا يمكن تحديده من الأعراض أو الرسالة.

إذا كان هناك استغلال أو ضغط:
اذكر المؤشرات الموجودة، إن وجدت.

ماذا أنصحك الآن:
خطوات عملية وآمنة.

اكتب بالعربية وبأسلوب إنساني هادئ وغير مخيف.
''';

      final response = await _aiService.ask(prompt);

      if (!mounted) {
        return;
      }

      setState(() {
        _isChecking = false;
        _result = response;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isChecking = false;
        _result =
            'تعذر إجراء الفحص حاليًا.\n\n'
            'تأكدي من اتصال التطبيق بخادم سِراج ثم حاولي مرة أخرى.';
      });
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
          'السحر والحسد والرقية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
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
              // البطاقة الرئيسية
              // ==================================================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF25213F),
                      Color(0xFF6E5B9E),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25213F)
                          .withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: AppColors.gold,
                      size: 40,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'سِراج للتحصين والرقية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'إذا كنتِ تخافين من السحر أو الحسد أو العين، سيساعدك سِراج على فهم ما أمامك بهدوء، ومعرفة الخطوة الآمنة التالية.',
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
              // أنواع المساعدة
              // ==================================================

              const Text(
                'كيف يمكن لسِراج مساعدتك؟',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ..._modes.map(
                (mode) {
                  final String title =
                      mode['title'] as String;
                  final String subtitle =
                      mode['subtitle'] as String;
                  final IconData icon =
                      mode['icon'] as IconData;

                  final bool selected =
                      _selectedMode == title;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Material(
                      color: selected
                          ? AppColors.purpleLight
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(18),
                        onTap: () {
                          _selectMode(title);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration:
                                    BoxDecoration(
                                  color: selected
                                      ? AppColors.purple
                                          .withValues(
                                          alpha: 0.14,
                                        )
                                      : const Color(
                                          0xFFF3EFF7,
                                        ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    15,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: selected
                                      ? AppColors.purple
                                      : AppColors
                                          .textMuted,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(
                                width: 13,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      title,
                                      style:
                                          const TextStyle(
                                        color: AppColors
                                            .textDark,
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      subtitle,
                                      style:
                                          const TextStyle(
                                        color: AppColors
                                            .textMuted,
                                        fontSize: 11.5,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                selected
                                    ? Icons
                                        .radio_button_checked_rounded
                                    : Icons
                                        .radio_button_off_rounded,
                                color: selected
                                    ? AppColors.purple
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // ==================================================
              // حقل الإدخال
              // ==================================================

              const Text(
                'اكتبي ما يحدث معك',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _selectedMode == 'رسالة أو ادعاء'
                    ? 'انسخي الرسالة التي وصلتك من الشخص الذي يدعي معرفة السحر أو الحسد.'
                    : 'اكتبي بالتفصيل ما يقلقك وسيساعدك سِراج على فهم الخطوة المناسبة.',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _controller,
                minLines: 7,
                maxLines: 12,
                textDirection:
                    TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText:
                      'اكتبي هنا الرسالة أو الأعراض أو ما قيل لك...',
                  hintStyle:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                    borderSide:
                        BorderSide.none,
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                    borderSide:
                        const BorderSide(
                      color: AppColors.purple,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // زر الفحص
              // ==================================================

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isChecking
                      ? null
                      : _checkContent,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.auto_awesome_rounded,
                        ),
                  label: Text(
                    _isChecking
                        ? 'سِراج يحلل ما كتبتِ...'
                        : 'حلّل مع سِراج',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFB8AECF),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // النتيجة
              // ==================================================

              if (_result != null) ...[
                const SizedBox(height: 28),

                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.purpleLight,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color:
                            AppColors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'تحليل سِراج',
                      style: TextStyle(
                        color:
                            AppColors.textDark,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(20),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color:
                          const Color(0xFFE5DDEB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(
                          alpha: 0.035,
                        ),
                        blurRadius: 12,
                        offset:
                            const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _result!,
                    textDirection:
                        TextDirection.rtl,
                    textAlign:
                        TextAlign.right,
                    style: const TextStyle(
                      color:
                          AppColors.textDark,
                      fontSize: 14.5,
                      height: 1.8,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ==================================================
              // رسالة الأمان
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFF3EFE7),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons
                          .verified_user_outlined,
                      color:
                          AppColors.purple,
                      size: 21,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'سِراج لا يستطيع إثبات وجود السحر أو الحسد أو العين من الأعراض وحدها. هدفه مساعدتك على التعامل مع الخوف بوعي، والاستفادة من الرقية الشرعية، والانتباه إلى أساليب الاستغلال والتخويف.',
                        textDirection:
                            TextDirection.rtl,
                        textAlign:
                            TextAlign.right,
                        style: TextStyle(
                          color:
                              AppColors.textDark,
                          fontSize: 11.5,
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