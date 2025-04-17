
import 'dart:convert';

import 'package:dirver/features/passenger_home/presentation/views/widgets/show_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/utils/utils.dart';
import '../../../../passenger_home/presentation/provider/trip_provider.dart';

class TripBottomSheet extends StatelessWidget {
  const TripBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => setLocation(context)); // ✅ Run once when the widget builds

    return Column(
      children: [
        SizedBox(
          height: 350,
          child: ShowMap(),
        ),
      ],
    );
  }

  Future<void> setLocation(BuildContext context) async {
    var tripProvider = context.read<TripProvider>();
    try {
      tripProvider.toController.text = 'الدقي مصر';
      String query = 'الدقي مصر';

      if (query.isEmpty) {
        Future.delayed(Duration.zero, () {
          errorMessage(context, 'Please enter a location');
        });
        return;
      }

      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');


        errorMessage(context, '🔍 Searching location: $query'); // Debug log


      final response = await http.get(url);


        errorMessage(context, '📩 Response received: ${response.statusCode}');


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          Future.delayed(Duration.zero, () {
            errorMessage(context, '📍 Location found: Lat: $lat, Lon: $lon');
          });

          tripProvider.setCoordinatesPoint(LatLng(lat, lon));
        } else {

            errorMessage(context, 'Location not found, try another location');

        }
      } else {

          errorMessage(context, 'Error in search');

      }
    } catch (e, stackTrace) {
      print(stackTrace);

        errorMessage(context, 'Something went wrong. Please try again. $e');

    }
  }
}
