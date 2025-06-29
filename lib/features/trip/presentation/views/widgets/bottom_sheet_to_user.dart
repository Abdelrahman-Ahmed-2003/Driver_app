import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/dest_trip_widget.dart';
import 'package:dirver/features/trip/presentation/views/widgets/end_trip_button.dart';
import 'package:dirver/features/trip/presentation/views/widgets/price_trip_widget.dart';
import 'package:dirver/features/trip/presentation/views/widgets/start_trip_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomSheetToUser extends StatelessWidget {
  const BottomSheetToUser({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = context.read<DriverTripProvider>();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(provider.currentTrip.driverDistination == 'toUser'? "Start Trip to User":'Start Trip to Destination',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
            ),
            const SizedBox(height: 16),
            DestTripWidget(),
            const SizedBox(height: 20),
            PriceTripWidget(),
            const SizedBox(height: 20),
            provider.currentTrip.driverDistination == 'toUser'?StartTripButton():
            EndTripButton(),
          ],
        ),
    )
        ],
      ),
    );
  }
}