import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
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
        child: Container(
          decoration: BoxDecoration(
            color: tripProvider.tripStream == null 
                ? AppColors.greyColor 
                : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          height: 50,
          width: 50,
          child: IconButton(
            onPressed: () {
              if (tripProvider.tripStream == null) return;
              Navigator.pushNamed(context, '/select-driver');
              
            },
            icon: const Icon(Icons.directions_bus, color: AppColors.whiteColor),
          ),
        ),
      ),
    );
  }
}