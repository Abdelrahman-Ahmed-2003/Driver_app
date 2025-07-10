import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/address_field.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/choose_driver_button.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/clear_location_button.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/list_view_widget.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/price_field.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/trip_button.dart';
import 'package:flutter/material.dart';

class BottomSheetWidget extends StatelessWidget {
  BottomSheetWidget({super.key});
  final priceController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
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
            color: AppColors.whiteColor,
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
                  const Divider(height: 32, thickness: 1, color: AppColors.dividerColor),
                  const TripButton(),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}