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
          // const TripStatusStreamer(),
          Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChooseDriverButton(),
                ClearLocationButton(),
              ],
            ),
          ),
          
          Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListViewWidget(),
          const SizedBox(height: 12),
          AddressField(hintText: 'Destination',
              controller: addressController),
          const SizedBox(height: 12),
          PriceField(controller: priceController),
          const SizedBox(height: 16),
          const TripButton(),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    )
        ],
      ),
    );
  }
}