import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DestTripWidget extends StatefulWidget {
  const DestTripWidget({super.key});

  @override
  State<DestTripWidget> createState() => _DestTripWidgetState();
}

class _DestTripWidgetState extends State<DestTripWidget> {

  @override
  Widget build(BuildContext context) {
    var provider = context.read<DriverTripProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.blueColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.currentTrip.driverDistination == 'toUser' ? provider.currentTrip.userLocation! : provider.currentTrip.destination,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.darkGrey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
