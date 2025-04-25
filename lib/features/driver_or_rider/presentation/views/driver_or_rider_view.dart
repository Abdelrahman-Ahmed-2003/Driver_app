import 'package:dirver/features/driver_or_rider/presentation/views/widgets/driver_or_rider_body.dart';
import 'package:flutter/material.dart';


class DriverOrRiderView extends StatelessWidget {
  const DriverOrRiderView({super.key});
  static const String routeName = '/driver_or_rider';

  @override
  Widget build(BuildContext context) {
    return DriverOrRiderBody();
    
  }
}