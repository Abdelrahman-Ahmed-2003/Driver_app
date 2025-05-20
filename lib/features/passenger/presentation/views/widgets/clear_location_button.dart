import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ClearLocationButton extends StatelessWidget {
  const ClearLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<PassengerTripProvider>();
    return Container(
      decoration: BoxDecoration(
        color: tripProvider.tripStream != null 
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
          if (tripProvider.tripStream != null) return;
          tripProvider.currentTrip.price = '';
          tripProvider.currentTrip.destination = '';
          tripProvider.currentTrip.destinationCoords = LatLng(0, 0);
          tripProvider.setCurrentPoints(LatLng(0, 0));
          tripProvider.points.clear();
          tripProvider.lastDest = null;
        },
        icon: const Icon(Icons.clear, color: AppColors.whiteColor),
      ),
    );
  }
}