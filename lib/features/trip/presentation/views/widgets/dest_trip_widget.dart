import 'package:dirver/core/sharedProvider/trip_provider.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class DestTripWidget extends StatefulWidget {
  final TripProvider provider;
  const DestTripWidget({super.key,required this.provider,});

  @override
  State<DestTripWidget> createState() => _DestTripWidgetState();
}

class _DestTripWidgetState extends State<DestTripWidget> {
  String? address ;

  Future<String> _coordsToAddress(double lat, double lng) async {
    debugPrint('Converting coordinates to address: $lat, $lng');
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

    if(widget.provider.currentTrip.driverDistination == 'toUser'){
          address = await _coordsToAddress(widget.provider.currentTrip.userLocation!.latitude, widget.provider.currentTrip.userLocation!.longitude);
          debugPrint('addresssssssssssssssssssss + $address');
          // setState(() {
            
          // });

    }
    else {
      address = widget.provider.currentTrip.destination;
    }
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
