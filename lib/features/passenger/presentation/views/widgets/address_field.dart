import 'dart:convert';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:free_map/free_map.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';

class AddressField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  const AddressField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  @override
  void initState() {
    super.initState();
    debugPrint('AddressField initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = context.read<MapProvider>();
      widget.controller.text = mapProvider.stringDestination;

      widget.controller.addListener(() {
        final text = widget.controller.text.trim();
        final destination = mapProvider.stringDestination.trim();

        if (text != destination && !mapProvider.canSearch) {
          mapProvider.canSearch = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AddressField build called');
    var tripProvider = context.read<PassengerTripProvider>();
    var mapProvider = context.read<MapProvider>();
    if(tripProvider.tripStream != null && (mapProvider.stringDestination != tripProvider.currentTrip.destination))
    {
      widget.controller.text = tripProvider.currentTrip.destination;
    }

    return Selector<MapProvider, String>(
      selector: (_, provider) => provider.stringDestination,
      builder: (context, destination, child) {
        final currentText = widget.controller.text.trim();

        if (currentText != destination && !mapProvider.canSearch) {
          widget.controller.text = destination;
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: tripProvider.tripStream != null,
                  controller: widget.controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    hintText: widget.hintText,
                  ),
                ),
              ),
              Consumer<MapProvider>(
                builder: (context, mapProvider, _) => _buildSearchButton(mapProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(MapProvider mapProvider) {
    if (mapProvider.isSearching) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      onPressed: mapProvider.canSearch ? () => _searchLocation(mapProvider) : null,
      icon: Icon(
        Icons.search,
        color: mapProvider.canSearch ? AppColors.primaryColor : AppColors.greyColor,
      ),
    );
  }

  Future<void> _searchLocation(MapProvider mapProvider) async {
    final query = widget.controller.text.trim();

    try {
      if (query.isEmpty) {
        throw Exception('Please enter a location');
      }

      mapProvider.isSearching = true;
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());

          if (lat != null && lon != null) {
            mapProvider.stringDestination = query;
            mapProvider.canSearch = false;
            mapProvider.destination = LatLng(lat, lon);
            mapProvider.setCurrentPoints(from: mapProvider.passengerLocation);
          } else {
            throw Exception('Invalid coordinates received. Please try again.');
          }
        } else {
          throw Exception('Location not found');
        }
      } else {
        throw Exception('Search failed with status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(context, e.toString());
      mapProvider.clearSearch();
    } finally {
      if (mounted) {
        mapProvider.isSearching = false;
      }
    }
  }
}
