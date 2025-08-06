import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/trip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedCards extends StatelessWidget {
  const AnimatedCards({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DriverTripProvider>();
    debugPrint('animated card build');
    return ListView.builder(
      shrinkWrap: true,
      itemCount: provider.availableTrips.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (context, index) {
        return TripCard(trip: provider.availableTrips[index]);
      },
    );
  }
}
