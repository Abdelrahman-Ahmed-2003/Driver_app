import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/dest_trip_widget.dart';
import 'package:dirver/features/trip/presentation/views/widgets/end_trip_button.dart';
import 'package:dirver/features/trip/presentation/views/widgets/price_trip_widget.dart';
import 'package:dirver/features/trip/presentation/views/widgets/start_trip_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverBottomSheet extends StatelessWidget {
  const DriverBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = context.read<DriverTripProvider>();
    debugPrint('bottommmmmmmmmmmmmmmmmmmm sheeeeeeeettttttttttttttttttttttt');
    return Align(
      alignment: Alignment.bottomCenter,
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
                      ? "Moving to User"
                      : 'Moving to Destination',
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
              const SizedBox(height: 28),
              
              (provider.currentTrip.driverDistination == 'toUser'
                  ? StartTripButton()
                  : EndTripButton()),
            ],
          ),
        ),
      ),
    );
  }
}