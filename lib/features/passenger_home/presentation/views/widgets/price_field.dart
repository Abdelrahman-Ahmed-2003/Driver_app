
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PriceField extends StatelessWidget {
  const PriceField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var provider = context.read<ContentOfTripProvider>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: provider.priceController,
        decoration: InputDecoration(
          filled: true,
          hintText: 'price of trip',
          fillColor: Color(0XFFC1CDCB),
          suffixText: 'EGP',
          suffixStyle: const TextStyle(color: Color.fromARGB(255, 131, 18, 18)),
        ),
      ),
    );
  }
}
