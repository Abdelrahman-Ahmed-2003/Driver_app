import 'dart:convert';
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
  bool _isSearching = false;
  String _lastSyncedValue = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripProvider = context.read<PassengerTripProvider>();
      final dest = tripProvider.currentTrip.destination;
      widget.controller.text = dest;
      _lastSyncedValue = dest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PassengerTripProvider, String>(
      selector: (_, provider) => provider.currentTrip.destination,
      builder: (context, destination, child) {
        final currentText = widget.controller.text.trim();

        // Sync only if destination changed AND it came from provider
        if (destination != _lastSyncedValue && destination != currentText) {
          widget.controller.text = destination;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: destination.length),
          );
          _lastSyncedValue = destination;
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              final tripProvider = context.read<PassengerTripProvider>();
              final isFieldFilled = value.text.trim().isNotEmpty;
              final canSearch = isFieldFilled &&
                  !_isSearching &&
                  tripProvider.tripStream == null &&
                  tripProvider.currentTrip.destination != value.text.trim();

              return Row(
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
                  _buildSearchButton(canSearch, tripProvider),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(
      bool canSearch, PassengerTripProvider tripProvider) {
    if (_isSearching) {
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
      onPressed: canSearch ? () => _searchLocation(tripProvider) : null,
      icon: Icon(
        Icons.search,
        color: canSearch ? AppColors.primaryColor : AppColors.greyColor,
      ),
    );
  }

  Future<void> _searchLocation(PassengerTripProvider tripProvider) async {
    final query = widget.controller.text.trim();

    try {
      if (query.isEmpty) {
        throw Exception('please entre location');
      }

      setState(() => _isSearching = true);
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
            tripProvider.updateTripDestination(query);
            tripProvider.setCoordinatesPoint(
                LatLng(lat, lon), LatLng(lat, lon));
            
          } else {
            throw Exception('please try again');
          }
        } else {
          throw Exception('Location not found');
        }
      } else {
        throw Exception('Search failed with status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(context, e.toString());
      tripProvider.clearAllData();
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }
}
