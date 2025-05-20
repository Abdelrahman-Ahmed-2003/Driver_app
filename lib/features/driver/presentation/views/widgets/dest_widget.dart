import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';

class DestWidget extends StatelessWidget {
  final String destination;
  const DestWidget({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.blueColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              destination,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.darkGrey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
