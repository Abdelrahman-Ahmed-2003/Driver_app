import 'package:dirver/core/constant/asset_images.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AssetImages.logo,
        Text('Dirver',style: TextStyle(fontSize: 25),),
        ],
    );
  }
}
