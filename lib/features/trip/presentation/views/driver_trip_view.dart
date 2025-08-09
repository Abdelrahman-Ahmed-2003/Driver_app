import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/driver_bottom_sheet.dart';
import 'package:dirver/features/trip/presentation/views/widgets/driver_trip_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DriverTripView extends StatefulWidget {
  final String? tripId;
  const DriverTripView({
    super.key,
    this.tripId,
  });
  static const String routeName = '/DriverTripView';

  @override
  State<DriverTripView> createState() => _DriverTripViewState();
}

class _DriverTripViewState extends State<DriverTripView> {
  @override
  void initState() {
    super.initState();
    debugPrint('DriverTripView initState');
    var provider = Provider.of<DriverTripProvider>(context, listen: false);
    provider.isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('DriverTripView post frame callback ${widget.tripId}');
      if(provider.driverId == null) {
        await provider.fetchDriverDocId();
      }
      if (widget.tripId != null) {
        debugPrint('in if condation');
                debugPrint('current trip${provider.currentTrip.destination}');

        await provider.fetchOnlineTrip(widget.tripId!,provider.driverId!);
        
        debugPrint('current trip${provider.currentTrip.destination}');
      }
      else {
        setState(() {
          provider.isLoading = false;
        });
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<DriverTripProvider>();
        debugPrint('DriverTripView build ${provider.isLoading}');

    LatLng destination = provider.currentTrip.driverDistination == 'toUser'
        ? provider.currentTrip.userLocationCoords!
        : provider.currentTrip.destinationCoords;
    debugPrint('DriverTripView build, isLoading: ${destination}');
    return SafeArea(
        child: Scaffold(
            
           body:  Skeletonizer(
      enabled: provider.isLoading,
      enableSwitchAnimation: true,
      child: Stack(
          children: [
            DriverTripMap(destination: destination),
            Align(
              alignment: Alignment.bottomCenter,
              child: DriverBottomSheet(),
            ),
          ],
        ),
    )
));
  }
}
