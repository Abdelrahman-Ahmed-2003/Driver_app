import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';

class PriceTripWidget extends StatelessWidget {
  const PriceTripWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DriverTripProvider>();
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