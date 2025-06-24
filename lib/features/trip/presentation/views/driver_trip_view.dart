import 'package:dirver/features/trip/presentation/views/widgets/bottom_sheet_to_user.dart';
import 'package:dirver/features/trip/presentation/views/widgets/driver_map.dart';
import 'package:flutter/material.dart';

class DriverTripView extends StatelessWidget {
  const DriverTripView({
    super.key,
  });
  static const String routeName = '/DriverTripView';
  @override
  Widget build(BuildContext context) {
    debugPrint('DriverTripView build');
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("To Passenger"),
            ),
            body: Column(
              children: [
                DriverMap(),
                BottomSheetToUser(),
              ],
            )));
  }
}
