import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class TextInSplash extends StatelessWidget {
  final String text;
  const TextInSplash({super.key,required this.text});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color.fromARGB(221, 35, 34, 34),
        fontSize: 24,
        // fontFamily: 'Agne',
      ),
      child: AnimatedTextKit(
        totalRepeatCount: 1,
        animatedTexts: [
          TypewriterAnimatedText(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
