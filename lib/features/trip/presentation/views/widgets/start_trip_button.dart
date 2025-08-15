import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';
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
              bool check = await provider.updateDestination('toDestination');
              if (check == true) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const DriverTripView(),
                  ),
                  (_) => false,
                );
              }
            },
            child: Text(
              'Start Trip',
              style: TextStyle(fontSize: 20),
            )));
  }
}
