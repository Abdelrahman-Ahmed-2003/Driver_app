import 'dart:convert';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/passenger_home/presentation/provider/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AddressField extends StatelessWidget {
  final String hintText;
  const AddressField({
    super.key,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    var tripProvider = context.read<TripProvider>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: tripProvider.toController,
              decoration: InputDecoration(
                filled: true,
                hintText: hintText,
                fillColor: Color(0XFFC1CDCB),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                String query = tripProvider.toController.text.trim();
                if (query.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a location')),
                  );
                  return;
                }

                final url = Uri.parse(
                    'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');

                // print('🔍 Searching location: $query'); // Debug log

                final response = await http.get(url);
                print('📩 Response received: ${response.statusCode}');

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  if (data.isNotEmpty) {
                    final lat = double.parse(data[0]['lat']);
                    final lon = double.parse(data[0]['lon']);

                    print('📍 Location found: Lat: $lat, Lon: $lon');

                    context.read<TripProvider>().setCoordinatesPoint(LatLng(lat, lon));
                  } else {
                    print('⚠️ Location not found');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Location not found, try another location')),
                    );
                  }
                } else {
                  print('❌ Error: HTTP ${response.statusCode}');
                  errorMessage(context, 'Error in search');
                }
              } catch (e, stackTrace) {
                print('🚨 Exception in AddressField: $e');
                print(stackTrace);
                errorMessage(context, 'Something went wrong. Please try again.');
              }
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
