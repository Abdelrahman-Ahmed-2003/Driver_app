import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/full_screen_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AddressWidget extends StatelessWidget {
  final String destination;
  final LatLng destinationCoords;
  final LatLng passengerLocation;
  const AddressWidget(
      {super.key,
      required this.destination,
      required this.destinationCoords,
      required this.passengerLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          var mapProvider = context.read<MapProvider>();
          mapProvider.destination = destinationCoords;
          mapProvider.stringDestination = destination;
          mapProvider.passengerLocation = passengerLocation;
          debugPrint('passenger location: ${mapProvider.passengerLocation}');

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FullScreenMap()),
          );
        },
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.blueColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                destination,
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
      ),
    );
  }
}
