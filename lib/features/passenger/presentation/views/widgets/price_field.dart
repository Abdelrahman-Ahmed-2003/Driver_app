
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PriceField extends StatelessWidget {
  const PriceField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<PassengerTripProvider>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        readOnly: tripProvider.tripStream != null,
        keyboardType: TextInputType.number,
        controller: tripProvider.priceController,
        decoration: InputDecoration(
          filled: true,
          hintText: 'price of trip',
          fillColor: AppColors.greyColor,
          suffixText: 'EGP',
          suffixStyle: const TextStyle(color:AppColors.darkRed),
        ),
      ),
    );
  }
}
