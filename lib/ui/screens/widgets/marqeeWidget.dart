import 'package:Bareeq/data/cubits/system/language_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // pixels per second
  final double? blankSpace; // extra space between repeats (optional)

  const MarqueeText({
    Key? key,
    required this.text,
    this.style,
    this.velocity = 50.0,
    this.blankSpace,
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool isRTL = false;

  @override
  void initState() {
    super.initState();

    if (context.read<LanguageCubit>().state is LanguageLoader) {
      isRTL = (context.read<LanguageCubit>().state as LanguageLoader)
          .language['rtl'];
    }

    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() async {
    final textWidth = _scrollController.position.maxScrollExtent;
    final scrollTo = isRTL ? 0.0 : textWidth;
    final scrollBack = isRTL ? textWidth : 0.0;

    while (mounted) {
      await _scrollController.animateTo(
        scrollTo,
        duration: Duration(seconds: (textWidth / widget.velocity).round()),
        curve: Curves.linear,
      );
      await Future.delayed(Duration(seconds: 1));

      await _scrollController.animateTo(
        scrollBack,
        duration: Duration(seconds: (textWidth / widget.velocity).round()),
        curve: Curves.linear,
      );
      await Future.delayed(Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<LanguageCubit>().state is LanguageLoader) {
      isRTL = (context.read<LanguageCubit>().state as LanguageLoader)
          .language['rtl'];
    }

    return SizedBox(
      height: 30,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        reverse: isRTL,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.blankSpace ?? 40),
            child: Center(
              child: Text(
                widget.text,
                style: widget.style ?? TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/* import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // pixels per second

  const MarqueeText({
    Key? key,
    required this.text,
    this.style,
    this.velocity = 50,
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late double _textWidth;
  late double _containerWidth;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) => startScrolling());
  }

  void startScrolling() async {
    final textKey = GlobalKey();
    final textWidget = Text(widget.text, style: widget.style, key: textKey);
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    _textWidth = textPainter.width;
    _containerWidth = context.size?.width ?? 0;

    if (_textWidth <= _containerWidth) return;

    final scrollAmount = _textWidth + 50;
    final duration =
        Duration(milliseconds: (scrollAmount / widget.velocity * 1000).round());

    while (mounted) {
      await _scrollController.animateTo(
        scrollAmount,
        duration: duration,
        curve: Curves.linear,
      );
      await Future.delayed(const Duration(seconds: 1));
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}
 */