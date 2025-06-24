import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    super.key,
    required this.driverController,
    required this.trip,
  });

  final TextEditingController driverController;
  final Trip trip;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  void initState() {
    super.initState();
    widget.driverController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.driverController.removeListener(() {});
    super.dispose();
  }

  /* ─────────────── حساب حالة الزر ─────────────── */

  _ButtonState _computeState(DriverTripProvider p) {
    final proposal = widget.trip.drivers[p.driverId];
    final input = widget.driverController.text.trim();

    if (proposal == null) {
      if (input.isEmpty) return _ButtonState.accept;
      if (input == widget.trip.price) return _ButtonState.updateDisabled;
      return _ButtonState.updateEnabled;
    }

    return input == proposal.proposedPrice
        ? _ButtonState.updateDisabled
        : _ButtonState.updateEnabled;
  }

  /* ─────────────── Accept Trip ─────────────── */

  Future<void> _acceptTrip() async {
    final provider = context.read<DriverTripProvider>();

    if (provider.currentTrip != Trip() &&
        provider.currentTrip.id != widget.trip.id) {
      errorMessage(context, 'You can propose only one trip at a time');
      return;
    }

    provider
      ..currentTrip = widget.trip
      ..currentDocumentTrip =
          FirebaseFirestore.instance.collection('trips').doc(widget.trip.id)
      ..tripStream = provider.currentDocumentTrip!.snapshots();

    await provider.selectTrip();

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

  /* ─────────────── Update Proposal ─────────────── */

  Future<void> _updateProposal() async {
    final provider = context.read<DriverTripProvider>();

    if (provider.currentTrip != Trip() &&
        provider.currentTrip.id != widget.trip.id) {
      errorMessage(context, 'You can propose only one trip at a time');
      return;
    }
    provider
      ..currentTrip = widget.trip
      ..currentDocumentTrip =
          FirebaseFirestore.instance.collection('trips').doc(widget.trip.id)
      ..tripStream = provider.currentDocumentTrip!.snapshots();

    final docId = await StoreUserType.getDriverDocId();
    if (docId == null) return;

    await provider.updateDriverProposal(
      widget.trip.id,
      docId,
      widget.driverController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal updated')),
      );
    }
  }

  /* ─────────────── UI ─────────────── */

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverTripProvider>();
    final state = _computeState(provider);

    final (label, color, icon, onPressed) = switch (state) {
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
        null,
      ),
    };

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,      // null ⇒ disabled
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/* ───────────── enum ───────────── */
enum _ButtonState { accept, updateEnabled, updateDisabled }
