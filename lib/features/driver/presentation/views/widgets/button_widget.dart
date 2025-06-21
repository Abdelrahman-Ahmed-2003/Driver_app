import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/trip_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonWidget extends StatefulWidget {
  final Trip trip;
  const ButtonWidget(
      {super.key, required this.driverController, required this.trip});
  final TextEditingController driverController;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  late DriverTripProvider _provider;

  @override
  void initState() {
    super.initState();
    // cache provider once – cheaper than reading it every keystroke
    _provider = context.read<DriverTripProvider>();
    widget.driverController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.driverController.removeListener(_refresh);
    super.dispose();
  }

  /* ───────────────────────── LOGIC ───────────────────────── */

  void _refresh() => setState(() {});

  bool get _inputIsEmpty => widget.driverController.text.trim().isEmpty;

  bool get _inputEqualCurrentPrice =>
      widget.driverController.text.trim() == widget.trip.price;

  /// 3 possible states for the single button
  _ButtonState get _state {
    if (_inputIsEmpty) return _ButtonState.accept;
    if (_inputEqualCurrentPrice) return _ButtonState.updateDisabled;
    return _ButtonState.updateEnabled;
  }

  Future<void> _acceptTrip() async {
    // ➊ read the provider *inside* the callback
    try {
      if(_provider.currentTrip != Trip() && _provider.currentTrip.id != widget.trip.id){
        errorMessage(context, 'you can propose only one trip at a time');
        return;
      }
      _provider.currentTrip = widget.trip;
      _provider.currentDocumentTrip =
          FirebaseFirestore.instance.collection('trips').doc(widget.trip.id);
      _provider.tripStream = _provider.currentDocumentTrip!.snapshots();
      // whatever method sets the trip as accepted:
      // await provider.updateSelectedDriver(widget.driverWithProposal);
      await _provider.selectTrip(); // ← use your real method
      debugPrint(' out Trip accepted');
      if (!mounted) return; // widget might be gone after await
      // ➋ push TripView and keep the same provider instance alive
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: _provider, // same instance!
            child: const TripView(),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting driver: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProposal() async {
    debugPrint('in updating proposal funcitonnnnnnnnnnnnnnnnnnnn');
    if(_provider.currentTrip != Trip() && _provider.currentTrip.id != widget.trip.id){
        errorMessage(context, 'you can propose only one trip at a time');
        return;
      }
      debugPrint('Updating proposal trip id: ${widget.trip.id}');
    
    final docId = await StoreUserType.getDriverDocId();
    if (docId == null) return;
    _provider.currentTrip = widget.trip;
      _provider.currentDocumentTrip =
          FirebaseFirestore.instance.collection('trips').doc(widget.trip.id);
      _provider.tripStream = _provider.currentDocumentTrip!.snapshots();
    await _provider.updateDriverProposal(
      widget.trip.id,
      docId,
      widget.driverController.text.trim(),
    );
    if (!mounted) return; // widget might be gone after await
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proposal updated')),
    );
    debugPrint('Updating proposal trip id: ${_provider.currentTrip.id}');
  }

  /* ───────────────────────── UI ───────────────────────── */

  @override
  Widget build(BuildContext context) {
    final buttonState = _state;

    // everything that changes is decided here ↓
    final (label, color, icon, onPressed) = switch (buttonState) {
      _ButtonState.accept => (
          'Accept Trip',
          Colors.green,
          Icons.check,
          _acceptTrip,
        ),
      _ButtonState.updateEnabled => (
          'Update Price',
          Colors.orange,
          Icons.sync_alt,
          _updateProposal,
        ),
      _ButtonState.updateDisabled => (
          'Update Price',
          Colors.grey.shade400,
          Icons.sync_alt,
          null, // disabled
        ),
    };

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed, // null → disabled
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

/* ─────────────────────────────────────────────────────────── */

enum _ButtonState { accept, updateEnabled, updateDisabled }
