import 'package:dirver/core/models/trip.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/button_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/dest_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/price_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomSheetDriver extends StatefulWidget {
  final Trip trip;
  const BottomSheetDriver({super.key, required this.trip});

  @override
  State<BottomSheetDriver> createState() => _BottomSheetDriverState();
}

class _BottomSheetDriverState extends State<BottomSheetDriver> {
  final TextEditingController _driverController = TextEditingController();

  @override
  void dispose() {
    _driverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverTripProvider>(context, listen: false);
    if(provider.currentTrip!= Trip() && provider.currentTrip.id == widget.trip.id){
      _driverController.text = provider.driverProposal!.proposedPrice.toString();

    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Trip Details",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            DestWidget(destination: widget.trip.destination),
            const SizedBox(height: 20),
            PriceWidget(driverController: _driverController,trip: widget.trip),
            const SizedBox(height: 20),
            ButtonWidget(driverController: _driverController,trip: widget.trip),
          ],
        ),
      ),
    );
  }
}
