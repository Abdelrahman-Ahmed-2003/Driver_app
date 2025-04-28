import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/show_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class SelectedTrip extends StatefulWidget {
  final Map<String, dynamic> trip;
  const SelectedTrip({super.key, required this.trip});
  static const String routeName = '/selected_trip';

  @override
  State<SelectedTrip> createState() => _SelectedTripState();
}

class _SelectedTripState extends State<SelectedTrip> {

  @override
  void initState() {
    super.initState();
    
    final provider = context.read<ContentOfTripProvider>();
    provider.toController.text = widget.trip['destination'];
    provider.priceController.text = widget.trip['price'];
    
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Details"),
      ),
      body: ShowMap(isDriver: true,destination: LatLng(widget.trip['userLocation']['lat'], widget.trip['userLocation']['long']))
    );
  }
}