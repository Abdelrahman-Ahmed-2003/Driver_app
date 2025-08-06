import 'package:dirver/core/services/sharedPref/store_proposed_trips.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';

class TripActionWidget extends StatefulWidget {
  final Trip trip;

  const TripActionWidget({super.key, required this.trip});

  @override
  State<TripActionWidget> createState() => _TripActionWidgetState();
}

class _TripActionWidgetState extends State<TripActionWidget> {
  late TextEditingController _controller;
  String _buttonText = 'accept';

  @override
  void initState() {
    super.initState();
    debugPrint('init state of trip action widget');

    // Initialize controller with initial value from trip
    _controller = TextEditingController(
      text: widget.trip.driverProposalPrice ?? '',
    );

      if (widget.trip.driverProposalPrice != null) {
          _buttonText = 'change price to enabled';
        
      }
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _acceptTrip(DriverTripProvider provider) async {
    await provider.selectTrip();
    provider.deleteDriverProposal();
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const DriverTripView(),
        ),
      ),
      (_) => false,
    );
  }

  Future<void> _updateProposal(DriverTripProvider provider) async {
    _buttonText = 'change price to enabled';
    provider.propsedTrips[widget.trip.id] = _controller.text;
    await StoreProposedTrips.addProposal(widget.trip.id, _controller.text);
    await provider.updateDriverProposal(
        widget.trip.id, provider.driverId!, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('intial price issssssssssssss ${widget.trip.driverProposalPrice}');
    final provider = context.read<DriverTripProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Proposed Price",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Passenger Price: ${widget.trip.price} EGP",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffix: const Text('EGP'),
                  hintText: "EGP",
                  filled: true,
                  fillColor: AppColors.greyColor.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  if (value == widget.trip.driverProposalPrice && widget.trip.driverProposalPrice != null) {
                    setState(() {
                      _buttonText = 'change price to enabled';
                    });
                  } else if (value != widget.trip.driverProposalPrice && value.isNotEmpty) {
                    setState(() {
                      _buttonText = 'update';
                      // text = value;
                    });
                  } else if (value == widget.trip.price &&
                      _buttonText != 'accept' &&
                      widget.trip.driverProposalPrice == null) {
                    setState(() {
                      _buttonText = 'accept';
                      // text = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              label: Text(_buttonText.toUpperCase()),
              onPressed: _buttonText == 'accept'
                  ? () => _acceptTrip(provider)
                  : (_buttonText == 'update'
                      ? () => _updateProposal(provider)
                      : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonText == 'accept'
                    ? Colors.green
                    : (_buttonText == 'update' ? Colors.amber : Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
