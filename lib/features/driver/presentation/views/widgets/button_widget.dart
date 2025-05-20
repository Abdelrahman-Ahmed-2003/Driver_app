import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonWidget extends StatefulWidget {
  final TextEditingController driverController;

  const ButtonWidget({super.key, required this.driverController});

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  bool canUpdate = false;

  @override
  void initState() {
    super.initState();
    widget.driverController.addListener(_checkUpdateState);
  }

  void _checkUpdateState() {
    final provider = context.read<DriverTripProvider>();
    setState(() {
      final input = widget.driverController.text.trim();
      canUpdate = input.isNotEmpty && input != provider.currentTrip.price;
    });
  }

  @override
  void dispose() {
    widget.driverController.removeListener(_checkUpdateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DriverTripProvider>();
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.sync_alt),
            onPressed: canUpdate
                ? () async {
                    final id = await StoreUserType.getDriverDocId();
                    if (id == null) return;
                    debugPrint('trip id: ${provider.currentTrip.id}');
                    provider.updateDriverProposal(
                        provider.currentTrip.id, id, widget.driverController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proposal updated')),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canUpdate ? Colors.orange : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            label: const Text("Update Price"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Accept trip logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            label: const Text("Accept Trip"),
          ),
        ),
      ],
    );
  }
}
