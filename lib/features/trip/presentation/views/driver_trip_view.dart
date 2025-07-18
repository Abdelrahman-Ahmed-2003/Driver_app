import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/bottom_sheet_to_user.dart';
import 'package:dirver/features/trip/presentation/views/widgets/driver_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

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
              if(widget.tripId != null) {
                provider.isLoading = true;
                debugPrint('DriverTripView tripId: ${widget.tripId}');
              } else {
                debugPrint('DriverTripView tripId is null, fetching online trip');
              }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
              
      debugPrint('DriverTripView post frame callback ${widget.tripId}');
      if (widget.tripId != null) {

        await provider.fetchOnlineTrip(widget.tripId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<DriverTripProvider>();
    LatLng destination = provider.currentTrip.driverDistination == 'toUser'
        ? provider.currentTrip.userLocation!
        : provider.currentTrip.destinationCoords;
    debugPrint('DriverTripView build, isLoading: ${destination}');
    return SafeArea(
        child: Scaffold(
            
           body: provider.isLoading
    ? const Center(child: CircularProgressIndicator())
    : Stack(
        children: [
          ChangeNotifierProvider.value(value: provider, child: DriverMap(destination: destination)),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetToUser(provider: provider,),
          ),
        ],
      )
));
  }
}
