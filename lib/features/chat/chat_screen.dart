import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  // ============================================================
  // الرسالة التي تظهر للمستخدم
  // ============================================================

  final String? initialMessage;

  // ============================================================
  // تعليمات داخلية لسِراج
  //
  // هذه لا تظهر للمستخدم.
  // تستخدم فقط لتوجيه الذكاء الاصطناعي.
  // ============================================================

  final String? initialContext;

  const ChatScreen({
    super.key,
    this.initialMessage,
    this.initialContext,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ============================================================
  // إعدادات الحساب المجاني
  // ============================================================

  static const int freeQuestionLimit = 3;

  // ============================================================
  // الخدمة
  // ============================================================

  final AiService _aiService = AiService();

  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  // ============================================================
  // الرسائل الظاهرة للمستخدم
  // ============================================================

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'مرحبًا بكِ في سِراج 🌙\n\n'
          'أنا سِراج، رفيقتكِ الروحية.\n'
          'يمكنكِ أن تسأليني عن الأذكار، الرقية الشرعية، '
          'التحصين، السحر، العين، الحسد أو أي موضوع روحي يشغلكِ.\n\n'
          'سأحاول مساعدتكِ بهدوء وبدون تخويف.',
      isUser: false,
    ),
  ];

  // ============================================================
  // ذاكرة المحادثة
  // ============================================================

  final List<Map<String, String>> _conversationHistory = [];

  bool _isTyping = false;

  // ============================================================
  // تشغيل الصفحة
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadAccountData();
  }

  // ============================================================
  // تحميل بيانات الحساب من AiService
  // ============================================================

  Future<void> _loadAccountData() async {
    try {
      await _aiService.refreshUsage();
    } catch (_) {
      // إذا تعذر تحديث الاستخدام، لا نوقف الصفحة.
      // Backend سيبقى صاحب القرار النهائي عند إرسال السؤال.
    }

    if (!mounted) {
      return;
    }

    setState(() {});

    // إذا تم فتح سراج برسالة محددة
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendInitialMessage(
          widget.initialMessage!.trim(),
        );
      });
    }
  }

  // ============================================================
  // هل الحساب Premium؟
  // ============================================================

  bool get _isPremium {
    return _aiService.isPremium;
  }

  // ============================================================
  // الأسئلة المتبقية
  // ============================================================

  int get _remainingQuestions {
    if (_isPremium) {
      return 999;
    }

    final remaining =
        _aiService.remainingQuestions;

    if (remaining < 0) {
      return 0;
    }

    return remaining;
  }

  // ============================================================
  // هل يستطيع المستخدم إرسال سؤال؟
  // ============================================================

  bool get _canAsk {
    if (_isPremium) {
      return true;
    }

    return !_aiService.hasReachedFreeLimit;
  }

  // ============================================================
  // بناء الطلب الذي يذهب إلى سِراج
  //
  // مهم:
  // initialContext لا يظهر للمستخدم.
  // ============================================================

  String _buildPromptForSiraj(String userMessage) {
    final cleanMessage = userMessage.trim();

    final context = widget.initialContext?.trim();

    if (context == null || context.isEmpty) {
      return cleanMessage;
    }

    return '''
$context

رسالة المستخدم:
$cleanMessage
''';
  }

  // ============================================================
  // نافذة الاشتراك
  // ============================================================

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            contentPadding:
                const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              12,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8E7CC3),
                        Color(0xFFC99ACB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E7CC3)
                            .withValues(alpha: 0.25),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'انتهت أسئلتك المجانية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'لقد استخدمتِ الأسئلة الثلاثة المجانية.\n\n'
                  'إذا كنتِ تريدين مواصلة الحديث مع سِراج '
                  'والحصول على إجابات أعمق ومتابعة مستمرة، '
                  'يمكنكِ الانتقال إلى الاشتراك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8E7CC3),
                          Color(0xFFC99ACB),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSubscriptionComingSoon();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent,
                        shadowColor:
                            Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'الاشتراك في سِراج',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'لاحقًا',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // الاشتراك غير مربوط بعد
  // ============================================================

  void _showSubscriptionComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'صفحة الاشتراك سيتم ربطها بنظام الدفع في الخطوة القادمة.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // التعامل مع انتهاء الأسئلة
  // ============================================================

  void _handleFreeLimitReached() {
    if (!mounted) {
      return;
    }

    setState(() {});

    FocusScope.of(context).unfocus();

    _showSubscriptionDialog();
  }

  // ============================================================
  // إرسال السؤال الأول
  // ============================================================

  Future<void> _sendInitialMessage(String text) async {
    if (!mounted || _isTyping) {
      return;
    }

    if (!_canAsk) {
      _showSubscriptionDialog();
      return;
    }

    // ----------------------------------------------------------
    // النص الذي يظهر للمستخدم
    // ----------------------------------------------------------

    final visibleMessage = text;

    // ----------------------------------------------------------
    // النص الذي يذهب إلى الذكاء الاصطناعي
    //
    // يحتوي على initialContext إذا وجد.
    // ----------------------------------------------------------

    final promptForSiraj =
        _buildPromptForSiraj(text);

    setState(() {
      _messages.add(
        _ChatMessage(
          text: visibleMessage,
          isUser: true,
        ),
      );

      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _aiService.ask(
        promptForSiraj,
        history: const [],
      );

      if (!mounted) {
        return;
      }

      // في سجل المحادثة نحتفظ فقط برسالة المستخدم الحقيقية.
      _conversationHistory.add({
        'role': 'user',
        'content': visibleMessage,
      });

      _conversationHistory.add({
        'role': 'assistant',
        'content': response,
      });

      setState(() {
        _isTyping = false;

        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
          ),
        );
      });

      _scrollToBottom();

      setState(() {});

      if (!_isPremium &&
          _aiService.hasReachedFreeLimit) {
        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            if (!mounted) {
              return;
            }

            _showSubscriptionDialog();
          },
        );
      }
    } on SirajFreeLimitException {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTyping = false;
      });

      _handleFreeLimitReached();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTyping = false;

        _messages.add(
          const _ChatMessage(
            text:
                'تعذر الاتصال بسِراج حاليًا.\n\n'
                'تأكدي من تشغيل الخادم ثم حاولي مرة أخرى.',
            isUser: false,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  // ============================================================
  // إرسال رسالة المستخدم
  // ============================================================

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty || _isTyping) {
      return;
    }

    if (!_canAsk) {
      FocusScope.of(context).unfocus();
      _showSubscriptionDialog();
      return;
    }

    final historyForRequest =
        List<Map<String, String>>.from(
      _conversationHistory,
    );

    // ----------------------------------------------------------
    // التعليمات الداخلية تبقى موجودة في كل رسالة
    // حتى تبقى هوية الوظيفة الخاصة محفوظة أثناء المحادثة.
    // ----------------------------------------------------------

    final promptForSiraj =
        _buildPromptForSiraj(text);

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _aiService.ask(
        promptForSiraj,
        history: historyForRequest,
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // نخزن الرسالة الظاهرة فقط في تاريخ المحادثة.
      // --------------------------------------------------------

      _conversationHistory.add({
        'role': 'user',
        'content': text,
      });

      _conversationHistory.add({
        'role': 'assistant',
        'content': response,
      });

      while (_conversationHistory.length > 20) {
        _conversationHistory.removeAt(0);
      }

      setState(() {
        _isTyping = false;

        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
          ),
        );
      });

      _scrollToBottom();

      setState(() {});

      if (!_isPremium &&
          _aiService.hasReachedFreeLimit) {
        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            if (!mounted) {
              return;
            }

            _showSubscriptionDialog();
          },
        );
      }
    } on SirajFreeLimitException {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTyping = false;
      });

      _handleFreeLimitReached();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTyping = false;

        _messages.add(
          const _ChatMessage(
            text:
                'تعذر الاتصال بسِراج حاليًا.\n\n'
                'تأكدي من تشغيل الخادم ثم حاولي مرة أخرى.',
            isUser: false,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  // ============================================================
  // النزول لآخر رسالة
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8E7CC3),
                    Color(0xFFE7A6C8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E7CC3)
                        .withValues(alpha: 0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'سِراج AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // حالة سراج + العداد
            // ==================================================

            Container(
              margin: const EdgeInsets.fromLTRB(
                16,
                5,
                16,
                10,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF72B68A),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'سِراج متاح لمساعدتكِ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),

                  const Spacer(),

                  if (!_isPremium)
                    Text(
                      'متبقي $_remainingQuestions من $freeQuestionLimit',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF806CB2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  if (_isPremium)
                    const Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFD19A39),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // الرسائل
            // ==================================================

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  15,
                ),
                itemCount:
                    _messages.length +
                    (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping &&
                      index == _messages.length) {
                    return const _TypingBubble();
                  }

                  return _MessageBubble(
                    message: _messages[index],
                  );
                },
              ),
            ),

            // ==================================================
            // الاقتراحات
            // ==================================================

            if (_messages.length == 1 &&
                !_isTyping &&
                _canAsk)
              _QuickSuggestions(
                onSelected: (text) {
                  _messageController.text = text;
                  _sendMessage();
                },
              ),

            // ==================================================
            // حقل الكتابة
            // ==================================================

            _MessageInput(
              controller: _messageController,
              isTyping: _isTyping,
              enabled: _canAsk,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// نموذج الرسالة
// ================================================================

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}

// ================================================================
// فقاعة الرسالة
// ================================================================

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [
                    Color(0xFF8E7CC3),
                    Color(0xFFC99ACB),
                  ],
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:
                const Radius.circular(20),
            topRight:
                const Radius.circular(20),
            bottomLeft: Radius.circular(
              isUser ? 20 : 5,
            ),
            bottomRight: Radius.circular(
              isUser ? 5 : 20,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message.text,
          textDirection:
              TextDirection.rtl,
          textAlign:
              TextAlign.right,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.7,
            color: isUser
                ? Colors.white
                : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// مؤشر الكتابة
// ================================================================

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            _TypingDot(),
            SizedBox(width: 4),
            _TypingDot(),
            SizedBox(width: 4),
            _TypingDot(),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// نقطة الكتابة
// ================================================================

class _TypingDot extends StatefulWidget {
  const _TypingDot();

  @override
  State<_TypingDot> createState() =>
      _TypingDotState();
}

class _TypingDotState
    extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController
      _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 700,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.3,
        end: 1,
      ).animate(_controller),
      child: Container(
        width: 7,
        height: 7,
        decoration:
            const BoxDecoration(
          color: Color(0xFF8E7CC3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ================================================================
// الاقتراحات السريعة
// ================================================================

class _QuickSuggestions
    extends StatelessWidget {
  final Function(String) onSelected;

  const _QuickSuggestions({
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection:
            Axis.horizontal,
        reverse: true,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        children: [
          _SuggestionChip(
            text:
                'أريد أذكارًا لليوم',
            onTap: () {
              onSelected(
                'أريد أذكارًا مناسبة لليوم',
              );
            },
          ),

          _SuggestionChip(
            text: 'أشعر بالقلق',
            onTap: () {
              onSelected(
                'أشعر بالقلق وأحتاج إلى بعض التوجيه',
              );
            },
          ),

          _SuggestionChip(
            text: 'ما هي الرقية؟',
            onTap: () {
              onSelected(
                'ما هي الرقية الشرعية؟',
              );
            },
          ),

          _SuggestionChip(
            text: 'أخاف من الحسد',
            onTap: () {
              onSelected(
                'أخاف من الحسد وأريد أن أعرف كيف أتعامل مع هذا الخوف',
              );
            },
          ),

          _SuggestionChip(
            text: 'ما هو السحر؟',
            onTap: () {
              onSelected(
                'أريد أن أعرف ما هو السحر وكيف أتعامل مع الخوف منه',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================================================================
// زر الاقتراح
// ================================================================

class _SuggestionChip
    extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8),
      child: ActionChip(
        onPressed: onTap,
        backgroundColor:
            Colors.white,
        side: BorderSide(
          color: const Color(0xFF8E7CC3)
              .withValues(alpha: 0.15),
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color:
                AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// حقل الرسالة
// ================================================================

class _MessageInput
    extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final bool enabled;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.isTyping,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        12,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              gradient:
                  enabled
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF8E7CC3),
                            Color(0xFFC99ACB),
                          ],
                        )
                      : null,
              color: enabled
                  ? null
                  : Colors.grey.shade300,
              shape:
                  BoxShape.circle,
            ),
            child: IconButton(
              onPressed:
                  enabled && !isTyping
                      ? onSend
                      : null,
              icon:
                  const Icon(
                Icons
                    .arrow_upward_rounded,
                color:
                    Colors.white,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: TextField(
              controller:
                  controller,
              enabled: enabled,
              textDirection:
                  TextDirection.rtl,
              textInputAction:
                  TextInputAction.send,
              onSubmitted: (_) {
                if (enabled &&
                    !isTyping) {
                  onSend();
                }
              },
              minLines: 1,
              maxLines: 4,
              decoration:
                  InputDecoration(
                hintText:
                    enabled
                        ? 'اكتبي رسالتكِ لسِراج...'
                        : 'انتهت الأسئلة المجانية',
                hintStyle:
                    const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                filled: true,
                fillColor:
                    enabled
                        ? Colors.white
                        : Colors.grey.shade200,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    25,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
                prefixIcon:
                    const Icon(
                  Icons.auto_awesome,
                  color:
                      Color(0xFF8E7CC3),
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}