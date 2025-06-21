import 'package:dirver/core/models/trip.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:provider/provider.dart';

class PriceWidget extends StatelessWidget {
  final TextEditingController driverController;
  final Trip trip;
  const PriceWidget({super.key, required this.driverController, required this.trip});

  @override
  Widget build(BuildContext context) {
    var provider = context.read<DriverTripProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Proposed Price",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Passenger Price: ${trip.price} EGP",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 130,
              child: TextFormField(
              
                controller: driverController,
                keyboardType: TextInputType.number,
                readOnly: provider.currentTrip != Trip(),
                decoration: InputDecoration(
                  suffix: Text('EGP'),
                  hintText: "EGP",
                  filled: true,
                  fillColor: AppColors.greyColor.withOpacity(0.2),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}