import 'package:dirver/core/models/driver_with_proposal.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
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
    final provider = Provider.of<PassengerTripProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.greyColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
              Text(
                "🚕 Driver Offered: ${widget.driverWithProposal.proposal.proposedPrice} EGP",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grenColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  provider.updateSelectedDriver(
                      widget.driverWithProposal.driver.id);
                },
                child: const Text('Select Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
