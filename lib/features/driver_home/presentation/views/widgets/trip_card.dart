// =================================== Trip Card ===================================
import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.greyColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Trip to: ${trip['destination']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Passenger: ${trip['passengerName']}",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 20),
            Chip(
              backgroundColor: Colors.amber.shade100,
              label: Text(
                "${trip['price']} EGP",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}