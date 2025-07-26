import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/full_screen_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class DestWidget extends StatefulWidget {
  final String destination;
  final LatLng destinationCoords;
  final LatLng passengerLocation;
  const DestWidget({super.key, required this.destination,required this.destinationCoords,required this.passengerLocation});

  @override
  State<DestWidget> createState() => _DestWidgetState();
}

class _DestWidgetState extends State<DestWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var mapProvider = context.read<MapProvider>();
      mapProvider.destination = widget.destinationCoords;
      mapProvider.passengerLocation = widget.passengerLocation;
    });
  }
  @override
  Widget build(BuildContext context) {
    var mapProvider = context.read<MapProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value:mapProvider,// Pass the existing instance
                child: FullScreenMap(),
              ),
            ),
          );
        },
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.blueColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.destination,
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
