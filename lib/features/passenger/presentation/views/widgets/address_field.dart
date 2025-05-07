import 'dart:convert';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AddressField extends StatefulWidget {
  final String hintText;
  const AddressField({
    super.key,
    required this.hintText,
  });

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<PassengerTripProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              readOnly: tripProvider.tripStream != null,
              keyboardType: TextInputType.text,
              controller: tripProvider.toController,
              decoration: InputDecoration(
                filled: true,
                hintText: widget.hintText,
                fillColor: AppColors.greyColor,
              ),
            ),
          ),
          _buildTripButton(tripProvider),
        ],
      ),
    );
  }

  Widget _buildTripButton(PassengerTripProvider tripProvider) {
    return _isSearching
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : IconButton(
            onPressed: _isSearching ? null : tripProvider.tripStream!= null?null:() => _handleSearch(tripProvider),
            icon: const Icon(Icons.search),
          );
  }

  Future<void> _handleSearch(PassengerTripProvider tripProvider) async {
  final query = tripProvider.toController.text.trim();
  
  if (query.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a location')),
    );
    return;
  }

  setState(() => _isSearching = true);

  try {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );

    debugPrint('🔍 Searching location: $query');

    final response = await http.get(url);
    debugPrint('📩 Response received: ${response.statusCode}');

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        // Handle both string and numeric values
        final lat = data[0]['lat'] is String 
            ? double.parse(data[0]['lat']) 
            : (data[0]['lat'] as num).toDouble();
            
        final lon = data[0]['lon'] is String 
            ? double.parse(data[0]['lon']) 
            : (data[0]['lon'] as num).toDouble();

        debugPrint('📍 Location found: Lat: $lat, Lon: $lon');
        tripProvider.setCoordinatesPoint(LatLng(lat, lon));
      } else {
        debugPrint('⚠️ Location not found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found, try another location')),
        );
      }
    } else {
      debugPrint('❌ Error: HTTP ${response.statusCode}');
      errorMessage(context, 'Error in search');
    }
  } catch (e, stackTrace) {
    debugPrint('🚨 Exception in AddressField: $e');
    debugPrint(stackTrace.toString());
    errorMessage(context, 'Something went wrong. Please try again.');
  } finally {
    if (mounted) {
      setState(() => _isSearching = false);
    }
  }
}
}