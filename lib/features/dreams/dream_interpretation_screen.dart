import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';

class DreamInterpretationScreen extends StatefulWidget {
  const DreamInterpretationScreen({super.key});

  @override
  State<DreamInterpretationScreen> createState() =>
      _DreamInterpretationScreenState();
}

class _DreamInterpretationScreenState
    extends State<DreamInterpretationScreen> {
  final TextEditingController _dreamController =
      TextEditingController();

  String? _dreamTime;
  bool _isRepeated = false;

  static const Color purple = Color(0xFF5E3FA3);
  static const Color cream = Color(0xFFF8F4EC);
  static const Color textDark = Color(0xFF302A42);
  static const Color gold = Color(0xFFD19A39);

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  void _interpretDream() {
    final dream = _dreamController.text.trim();

    if (dream.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اكتبي حلمك أولًا حتى يتمكن سِراج من مساعدتك.',
          ),
        ),
      );
      return;
    }

    final String repeatedText =
        _isRepeated ? 'نعم، الحلم تكرر.' : 'لا، الحلم لم يتكرر.';

    final String timeText =
        _dreamTime ?? 'لم يتم تحديد وقت الحلم.';

    final question = '''
أريد منك مساعدتي في فهم هذا الحلم بشكل هادئ ومتزن.

الحلم:
$dream

وقت الحلم:
$timeText

هل تكرر الحلم:
$repeatedText

حلّل الرموز الواردة في الحلم واذكر المعاني المحتملة بصورة غير قطعية.
لا تعتبر التفسير تنبؤًا بالمستقبل، ولا تجزم بوقوع أحداث، ولا تربط الحلم بالسحر أو الحسد أو العين دون دليل.
إذا كان هناك أكثر من معنى محتمل، اذكر ذلك بوضوح.
''';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          initialMessage: question,
        ),
      ),
    );
  }

  void _clearDream() {
    setState(() {
      _dreamController.clear();
      _dreamTime = null;
      _isRepeated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cream,

        appBar: AppBar(
          backgroundColor: cream,
          elevation: 0,
          centerTitle: true,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textDark,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          title: const Text(
            'تفسير الأحلام',
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ==========================================
                // HEADER
                // ==========================================

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF28184A),
                        Color(0xFF5E3FA3),
                        Color(0xFF8172C2),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -8,
                        left: 5,
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.white.withOpacity(0.35),
                          size: 18,
                        ),
                      ),

                      Positioned(
                        top: 38,
                        left: 50,
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.white.withOpacity(0.25),
                          size: 10,
                        ),
                      ),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.nightlight_round,
                              color: Color(0xFFE3C886),
                              size: 31,
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'تفسير الأحلام',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            'اكتبي حلمك بالتفصيل، وسيساعدك سِراج على فهم رموزه ومعانيه المحتملة.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // DREAM INPUT
                // ==========================================

                _sectionLabel(
                  icon: Icons.edit_note_rounded,
                  title: 'اكتبي حلمك',
                ),

                const SizedBox(height: 10),

                Container(
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
                  child: TextField(
                    controller: _dreamController,
                    minLines: 7,
                    maxLines: 12,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 15,
                      height: 1.8,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          'اكتبي حلمك هنا بالتفصيل...\n\nمثال: رأيت أنني أمشي في مكان لا أعرفه ثم...',
                      hintStyle: TextStyle(
                        color: Colors.black38,
                        fontSize: 13,
                        height: 1.7,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==========================================
                // DREAM TIME
                // ==========================================

                _sectionLabel(
                  icon: Icons.access_time_rounded,
                  title: 'متى رأيت الحلم؟',
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _timeChip('قبل النوم'),
                    _timeChip('أثناء الليل'),
                    _timeChip('قبل الفجر'),
                    _timeChip('بعد الفجر'),
                    _timeChip('لا أتذكر'),
                  ],
                ),

                const SizedBox(height: 22),

                // ==========================================
                // REPEATED DREAM
                // ==========================================

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE8E0D6),
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: purple,
                    title: const Text(
                      'هل تكرر هذا الحلم؟',
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'معلومة اختيارية تساعد في فهم السياق.',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                    value: _isRepeated,
                    onChanged: (value) {
                      setState(() {
                        _isRepeated = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // INTERPRET BUTTON
                // ==========================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _interpretDream,
                    icon: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'فسّري حلمي مع سِراج',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ==========================================
                // CLEAR BUTTON
                // ==========================================

                TextButton.icon(
                  onPressed: _clearDream,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: Colors.black45,
                  ),
                  label: const Text(
                    'مسح الحلم',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==========================================
                // DISCLAIMER
                // ==========================================

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFEEDDB5),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: gold,
                        size: 22,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'تفسير الأحلام اجتهاد لفهم الرموز والمعاني المحتملة، وليس تنبؤًا مؤكدًا بالمستقبل أو حكمًا قطعيًا على أحداث ستقع.',
                          style: TextStyle(
                            color: Color(0xFF6B5A36),
                            fontSize: 11,
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
      ),
    );
  }

  Widget _sectionLabel({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEAE3F8),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: purple,
            size: 19,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _timeChip(String title) {
    final selected = _dreamTime == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _dreamTime = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? purple
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? purple
                : const Color(0xFFE5DED5),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : textDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
