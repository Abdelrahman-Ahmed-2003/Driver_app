import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ClearLocationButton extends StatelessWidget {
  const ClearLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
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
              final provider = context.read<ContentOfTripProvider>();
              provider.toController.clear();
              provider.priceController.clear();
              provider.setFrom('');
              provider.setPrice('');
              provider.setDest(LatLng(0, 0));
              provider.setCurrentPoints(LatLng(0, 0));
              provider.points.clear();
              provider.lastDest = null;
            },
            icon: const Icon(Icons.clear, color: AppColors.whiteColor),
          ),
        ),
      ),
    );
  }
}