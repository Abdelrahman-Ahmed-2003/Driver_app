import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/views/select_driver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseDriverButton extends StatelessWidget {
  const ChooseDriverButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<PassengerTripProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          height: 56,
          width: 56,
          child: FloatingActionButton(
            backgroundColor: tripProvider.tripStream == null
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
            elevation: 6,
            shape: const CircleBorder(),
            onPressed: () {
              if (tripProvider.tripStream == null) return;
              Navigator.pushNamed(
                context,
                SelectDriver.routeName,
                arguments: tripProvider,
              );
            },
            child: Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.onPrimary, size: 30),
          ),
        ),
      ),
    );
  }
}
