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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
أنت الآن تعمل داخل ميزة "افحصي شيئًا" في تطبيق سِراج.

حلّل النص التالي تحليلًا توعويًا ومحايدًا:

"$text"

أريد منك:
1. تحديد ما إذا كان المحتوى يبدو طبيعيًا أم يحتوي على مؤشرات احتيال أو تضليل أو استغلال.
2. توضيح المؤشرات التي اعتمدت عليها.
3. إعطاء المستخدم نصيحة عملية واضحة.
4. لا تجزم بأن المحتوى احتيالي إذا لم توجد أدلة كافية.
5. إذا كان المحتوى متعلقًا بالسحر أو الحسد أو الرقية أو الأمور الروحية، تعامل معه بهدوء وبدون تخويف أو تأكيد ادعاءات غير مثبتة.

اكتب النتيجة باللغة العربية وبأسلوب واضح ومطمئن.
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
            'تأكدي من تشغيل خادم سِراج ثم حاولي مرة أخرى.';
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
          'افحصي شيئًا',
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
              // العنوان
              // ==================================================

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
                  borderRadius:
                      BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E7CC3)
                          .withValues(alpha: 0.20),
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
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 38,
                    ),

                    SizedBox(height: 15),

                    Text(
                      'افحصي شيئًا مع سِراج',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'أرسلي رسالة أو عرضًا أو محتوى يثير شكك، وسيساعدك سِراج على فهم المؤشرات الموجودة فيه.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // حقل الإدخال
              // ==================================================

              const Text(
                'ماذا تريدين فحصه؟',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _controller,
                minLines: 7,
                maxLines: 12,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,

                decoration: InputDecoration(
                  hintText:
                      'الصقي هنا الرسالة أو النص أو العرض الذي تريدين فحصه...',

                  hintStyle: const TextStyle(
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
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFF8E7CC3),
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
                  onPressed:
                      _isChecking
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
                          Icons.search_rounded,
                        ),

                  label: Text(
                    _isChecking
                        ? 'سِراج يفحص المحتوى...'
                        : 'افحص الآن',
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF806CB2),
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
                            const Color(0xFFEDE6F5),
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color:
                            Color(0xFF806CB2),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      'نتيجة سِراج',
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
              // تنبيه
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(15),

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
                      Icons.info_outline_rounded,
                      color:
                          Color(0xFF806CB2),
                      size: 21,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'الفحص توعوي ولا يثبت وحده أن المحتوى احتيالي أو صحيح. عند وجود طلبات مالية أو معلومات شخصية، تحققي من المصدر قبل اتخاذ أي إجراء.',
                        textDirection:
                            TextDirection.rtl,
                        textAlign:
                            TextAlign.right,
                        style: TextStyle(
                          color:
                              AppColors.textDark,
                          fontSize: 11.5,
                          height: 1.6,
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