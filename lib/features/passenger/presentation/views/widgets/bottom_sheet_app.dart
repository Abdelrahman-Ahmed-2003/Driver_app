import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/address_field.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/choose_driver_button.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/clear_location_button.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/list_view_widget.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/price_field.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/trip_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({super.key});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late final TextEditingController priceController;
  late final TextEditingController addressController;
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<PassengerTripProvider>(context, listen: false);
    debugPrint("BottomSheetWidget initState called");
    debugPrint('Current trip price: ${userProvider.currentTrip.price}');
    priceController = TextEditingController(text: userProvider.currentTrip.price);
    addressController = TextEditingController(text: userProvider.currentTrip.destination);
  }
  @override
Widget build(BuildContext context) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChooseDriverButton(),
                ClearLocationButton(),
              ],
            ),
          ),
          Card(
            elevation: 8,
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListViewWidget(),
                  const SizedBox(height: 16),
                  AddressField(hintText: 'Destination', controller: addressController),
                  const SizedBox(height: 16),
                  PriceField(controller: priceController),
                  Divider(
                    height: 32,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const TripButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}