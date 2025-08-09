import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/dest_trip_widget.dart';
import 'package:dirver/features/trip/presentation/views/widgets/price_trip_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PassengerBottomSheet extends StatelessWidget {
  const PassengerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    TripProvider provider = context.read<TripProvider>();
    debugPrint('bottommmmmmmmmmmmmmmmmmmm sheeeeeeeettttttttttttttttttttttt');
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Material(
          elevation: 8,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          color: Theme.of(context).colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    provider.currentTrip.driverDistination == 'toUser'
                        ? "Start Trip to User"
                        : 'Start Trip to Destination',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                DestTripWidget(),
                const SizedBox(height: 24),
                PriceTripWidget(price:provider.currentTrip.price),
              ],
            ),
          ),
        ),
      ),
    );
  }
}