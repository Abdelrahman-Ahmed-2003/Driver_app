import 'package:dirver/core/models/trip.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/widgets/bottom_sheet_to_user.dart';
import 'package:dirver/features/trip/presentation/views/widgets/tracking_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class PassengerTripView extends StatefulWidget {
  final String? tripId;
  const PassengerTripView({super.key,this.tripId});
  static const String routeName = '/PassengerTripView';

  @override
  State<PassengerTripView> createState() => _PassengerTripViewState();
}

class _PassengerTripViewState extends State<PassengerTripView> {
  @override
  void initState() {
    super.initState();
    debugPrint('passengerTripView initState');
    var provider = Provider.of<PassengerTripProvider>(context, listen: false);
              if(widget.tripId != null) {
                provider.isLoading = true;
                debugPrint('passengerTripView tripId: ${widget.tripId}');
              } else {
                debugPrint('passengerTripView tripId is null, fetching online trip');
              }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
              
      debugPrint('passengerTripView post frame callback ${widget.tripId}');
      if (widget.tripId != null) {
          debugPrint('in if condation');
        await provider.fetchOnlineTrip(widget.tripId!);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    var tripProvider = context.watch<PassengerTripProvider>();
    // tripProvider.reconnectTripStream();
    debugPrint(tripProvider.toString());
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Driver move to you"),
      ),
      body: StreamBuilder(
        stream: tripProvider.tripStream,
        builder: (context, snapshot) {
          debugPrint('StreamBuilder stream hash: ${tripProvider.tripStream.hashCode}');

          debugPrint('StreamBuilder state: ${snapshot.connectionState}');
          debugPrint('StreamBuilder hasData: ${snapshot.hasData}');
          debugPrint('StreamBuilder data: ${snapshot.data}');
          debugPrint('StreamBuilder error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('load data in passenger home');
            if(tripProvider.tripStream == null) {
              debugPrint('stream is nullllllllll');
            } else {
              debugPrint('stream not equal nullllllllllll');
            }
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No trip data available'));
          }
          debugPrint('passenger trip data');
          tripProvider.currentTrip = Trip.fromFirestore(snapshot.data!);
          debugPrint('passenger trip data');
          debugPrint('${tripProvider.currentTrip.driverLocation}' );
          debugPrint('${tripProvider.currentTrip.userLocation}');
          return Column(
            children: [
              Expanded(
                child:ChangeNotifierProvider(
                  create: (_) => MapProvider(),
                  child: TrackingMap(
                            current: tripProvider.currentTrip.driverLocation ?? const LatLng(0, 0),
                            destination: tripProvider.currentTrip.userLocation ?? const LatLng(0, 0),
                          ),
                ),
              ),
          BottomSheetToUser(provider: tripProvider,)
            ],
          );
        },
      ),
    ));
  }
}