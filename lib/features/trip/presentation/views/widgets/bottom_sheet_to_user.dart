import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/dest_trip_widget.dart';
import 'package:dirver/features/trip/presentation/views/widgets/end_trip_button.dart';
import 'package:dirver/features/trip/presentation/views/widgets/price_trip_widget.dart';
import 'package:dirver/features/trip/presentation/views/widgets/start_trip_button.dart';
import 'package:flutter/material.dart';

class BottomSheetToUser extends StatelessWidget {
  final TripProvider provider;
  const BottomSheetToUser({super.key,required this.provider});

  @override
  Widget build(BuildContext context) {
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
                DestTripWidget(provider:provider),
                const SizedBox(height: 24),
                PriceTripWidget(provider:provider),
                const SizedBox(height: 28),
                provider is DriverTripProvider?
                (provider.currentTrip.driverDistination == 'toUser'
                    ? StartTripButton()
                    : EndTripButton()):SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}