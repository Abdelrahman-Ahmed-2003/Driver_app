import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EndTripButton extends StatelessWidget {
  const EndTripButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(onPressed: ()async{
        var provider = context.read<DriverTripProvider>();
        await provider.endTrip();
        Navigator.pushNamedAndRemoveUntil(
                      context,
                      DriverHome.routeName
                      , (route) => false
                    );
      }, child: Text('end trip', style: TextStyle(fontSize: 20),)));
  }
}