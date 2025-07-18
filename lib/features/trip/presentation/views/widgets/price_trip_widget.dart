import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:flutter/material.dart';

class PriceTripWidget extends StatelessWidget {
  final TripProvider provider;
  const PriceTripWidget({super.key,required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Trip Price: ${provider.currentTrip.price} EGP",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}