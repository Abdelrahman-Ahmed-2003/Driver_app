import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartTripButton extends StatelessWidget {
  const StartTripButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
        width: double.infinity,
        child: ElevatedButton(
            onPressed: () async {
              var provider = context.read<DriverTripProvider>();
              await provider.updateDestination('toDestination');
            },
            child: Text('Start Trip',style: TextStyle(fontSize: 20),)));
  }
}
