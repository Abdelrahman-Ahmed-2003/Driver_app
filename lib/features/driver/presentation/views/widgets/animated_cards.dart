import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/trip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedCards extends StatelessWidget {
  const AnimatedCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<DriverTripProvider, int>(
      selector: (_, provider) => provider.availableTrips.length,
      builder: (context, tripCount, child) {
        debugPrint('animated card build — trip count: $tripCount');

        // Still need to get the trips here without listening for changes
        final provider = context.read<DriverTripProvider>();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: tripCount,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) {
            return TripCard(trip: provider.availableTrips[index]);
          },
        );
      },
    );
  }
}
