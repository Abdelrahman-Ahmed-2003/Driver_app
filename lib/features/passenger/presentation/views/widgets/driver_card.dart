import 'package:dirver/core/models/driver_with_proposal.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/trip/presentation/views/passenger_trip_view.dart';
import 'package:flutter/material.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:provider/provider.dart';

class DriverCard extends StatefulWidget {
  final String passengerPrice;
  final DriverWithProposal driverWithProposal;

  const DriverCard(
      {super.key,
      required this.driverWithProposal,
      required this.passengerPrice});

  @override
  State<DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<DriverCard> {
  String buttonText = 'Select Driver';

  @override
  Widget build(BuildContext context) {
    debugPrint('DriverCard: ${widget.driverWithProposal.driver.name}');
    debugPrint(
        'DriverCard: ${widget.driverWithProposal.proposal.proposedPrice}');
    final provider = Provider.of<PassengerTripProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Driver Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            widget.driverWithProposal.driver.imageUrl != null
                                ? NetworkImage(
                                    widget.driverWithProposal.driver.imageUrl!)
                                : null,
                        child: widget.driverWithProposal.driver.imageUrl == null
                            ? Text(widget.driverWithProposal.driver.email[0]
                                .toUpperCase())
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.driverWithProposal.driver.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  (widget.driverWithProposal.driver.rating !=
                          'no rate till now')
                      ? Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            Text(widget.driverWithProposal.driver.rating),
                          ],
                        )
                      : const Text('New Driver'),
                ],
              ),

              const SizedBox(height: 12),

              // Display Pricing & Status Info
              Text(
                "📢 Passenger Proposed: ${widget.passengerPrice} EGP",
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                "🚕 Driver Offered: ${widget.driverWithProposal.proposal.proposedPrice} EGP",
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 12),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    try {
                      await provider
                          .updateSelectedDriver(widget.driverWithProposal);
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PassengerTripView(),
                          ));
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error selecting driver: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      return;
                    }
                  },
                  child: Text('Select Driver', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
