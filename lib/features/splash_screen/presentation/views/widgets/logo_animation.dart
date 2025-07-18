import 'package:flutter/material.dart';

class LogoAnimation extends StatelessWidget {
  const LogoAnimation({super.key, required this.bottomVal, required this.widthVal, required this.heightVal, required this.ballY, required this.times, required this.showShadow});
  final double bottomVal;
  final double widthVal;
  final double heightVal;
  final double ballY;
  final int times;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedPositioned(
                  bottom: bottomVal,
                  duration: Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: Offset(0, ballY),
                        child: AnimatedScale(
                          duration: Duration(milliseconds: 200),
                          scale: times == 3 ? 5 : 1,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 1000),
                            width: widthVal,
                            height: heightVal,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary),
                          ),
                        ),
                      ),
                      if (showShadow)
                        Container(
                          width: 50,
                          height: 10,
                          decoration: BoxDecoration(
                              color: colorScheme.shadow,
                              borderRadius: BorderRadius.circular(100)),
                        )
                    ],
                  ),
                );
  }
}