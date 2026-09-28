import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() =>
      _ConsultationScreenState();
}

class _ConsultationScreenState
    extends State<ConsultationScreen> {
  final TextEditingController _questionController =
      TextEditingController();

  String? _selectedType;

  bool _submitted = false;

  final List<String> _consultationTypes = [
    'استشارة دينية',
    'استشارة أسرية',
    'استشارة روحية',
    'استشارة عامة',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  // ============================================================
  // إرسال طلب الاستشارة
  // ============================================================

  void _submitRequest() {
    if (_selectedType == null ||
        _questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار نوع الاستشارة وكتابة السؤال.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _submitted = true;
    });
  }

  // ============================================================
  // الصفحة
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
          'استشارة بشرية',
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

          child: _submitted
              ? _buildSuccess()
              : _buildForm(),
        ),
      ),
    );
  }

  // ============================================================
  // نموذج الاستشارة
  // ============================================================

  Widget _buildForm() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        // ========================================================
        // البطاقة الرئيسية
        // ========================================================

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
                color: const Color(0xFF5A4A91)
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
                Icons.person_search_rounded,
                color: Colors.white,
                size: 35,
              ),

              SizedBox(height: 14),

              Text(
                'تحتاجين إلى رأي بشري؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'يمكنك إرسال طلب استشارة ليتم التعامل معه من خلال مختص مناسب.',
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

        // ========================================================
        // نوع الاستشارة
        // ========================================================

        const Text(
          'نوع الاستشارة',
          textAlign: TextAlign.right,

          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color: const Color(0xFFE8E0D6),
            ),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,

              isExpanded: true,

              hint: const Text(
                'اختاري نوع الاستشارة',
                textDirection:
                    TextDirection.rtl,
              ),

              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
              ),

              items:
                  _consultationTypes.map(
                (type) {
                  return DropdownMenuItem<String>(
                    value: type,

                    child: Text(
                      type,
                      textDirection:
                          TextDirection.rtl,
                    ),
                  );
                },
              ).toList(),

              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 22),

        // ========================================================
        // السؤال
        // ========================================================

        const Text(
          'اكتبي سؤالك',
          textAlign: TextAlign.right,

          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color: const Color(0xFFE8E0D6),
            ),
          ),

          child: TextField(
            controller:
                _questionController,

            minLines: 6,
            maxLines: 10,

            textDirection:
                TextDirection.rtl,

            textAlign:
                TextAlign.right,

            decoration:
                const InputDecoration(
              border: InputBorder.none,

              hintText:
                  'اكتبي تفاصيل السؤال أو الموضوع الذي تريدين الاستشارة حوله...',

              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ========================================================
        // زر إرسال الطلب
        // ========================================================

        SizedBox(
          height: 54,

          child: ElevatedButton.icon(
            onPressed: _submitRequest,

            icon: const Icon(
              Icons.send_rounded,
            ),

            label: const Text(
              'إرسال طلب الاستشارة',
            ),

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF7460B8),

              foregroundColor:
                  Colors.white,

              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              textStyle:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // ========================================================
        // ملاحظة الخصوصية
        // ========================================================

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: Color(0xFF806CB2),
            ),

            const SizedBox(width: 6),

            Text(
              'معلوماتك تعامل بسرية',
              style: TextStyle(
                color: AppColors.textDark
                    .withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // نجاح إرسال الطلب
  // ============================================================

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 50),

        Container(
          width: 90,
          height: 90,

          decoration:
              const BoxDecoration(
            color: Color(0xFFE5F3EA),
            shape: BoxShape.circle,
          ),

          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF4F9A6D),
            size: 50,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'تم إرسال طلبك',
          textAlign: TextAlign.center,

          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'تم تسجيل طلب الاستشارة بنجاح.\n'
          'سيتم تطوير نظام التواصل مع المختصين وربطه بالخدمة في المرحلة القادمة.',
          textAlign: TextAlign.center,

          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            height: 1.8,
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 52,

          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },

            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(0xFF7460B8),

              side: const BorderSide(
                color: Color(0xFF7460B8),
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(17),
              ),
            ),

            child: const Text(
              'العودة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}