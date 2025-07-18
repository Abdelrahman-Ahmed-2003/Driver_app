import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ClearLocationButton extends StatelessWidget {
  const ClearLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<PassengerTripProvider>();
    return Container(
      decoration: BoxDecoration(
        color: tripProvider.tripStream != null 
            ? Theme.of(context).colorScheme.outline 
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 50,
      width: 50,
      child: IconButton(
        onPressed: () {
          if (tripProvider.tripStream != null) return;
            tripProvider.clearAllData();
        },
        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}