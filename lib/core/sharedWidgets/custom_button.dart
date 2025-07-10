import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;
  final Widget? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: FilledButton.icon(
        onPressed: isDisabled ? null : onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
            fontSize: 16,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          elevation: 2,
        ),
      ),
    );
  }
}
