import 'package:dirver/core/constant/asset_images.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AssetImages.logo,
        const SizedBox(width: 8),
        Text(
          'Dirver',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
