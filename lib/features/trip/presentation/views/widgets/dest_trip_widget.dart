import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class DestTripWidget extends StatefulWidget {

  const DestTripWidget({super.key,});

  @override
  State<DestTripWidget> createState() => _DestTripWidgetState();
}

class _DestTripWidgetState extends State<DestTripWidget> {
  String? address ;

  Future<String> _coordsToAddress(double lat, double lng) async {
  // Returns a list of Placemark; we take the first
  final placemarks = await placemarkFromCoordinates(lat, lng);

  if (placemarks.isEmpty) return 'No address available';

  final Placemark p = placemarks.first;

  // Compose the full street-level address (customise as you like)
  return [
    p.street,            // e.g. “5th Avenue”
    p.subLocality,       // e.g. “Manhattan”
    p.locality,          // e.g. “New York”
    p.country            // e.g. “United States”
  ].where((e) => e != null && e.isNotEmpty).join(', ');
}
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
    var provider = Provider.of<DriverTripProvider>(context, listen: false);
    address = await _coordsToAddress(provider.currentTrip.userLocation!.latitude, provider.currentTrip.userLocation!.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              address??'unknown address',
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
