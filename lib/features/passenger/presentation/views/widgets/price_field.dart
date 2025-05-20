import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PriceField extends StatefulWidget {
  final TextEditingController controller;
  const PriceField({super.key, required this.controller});

  @override
  State<PriceField> createState() => _PriceFieldState();
}

class _PriceFieldState extends State<PriceField> {
  bool isPrice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripProvider = context.read<PassengerTripProvider>();
      final price = tripProvider.currentTrip.price;

      if (widget.controller.text.trim() != price.trim()) {
        widget.controller.text = price;
      }
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   final tripProvider = context.read<PassengerTripProvider>();
  //   final price = tripProvider.currentTrip.price;

  //   if (widget.controller.text.trim() != price.trim()) {
  //     widget.controller.text = price;
  //   }

  // }

  void _checkUpdatePrice(String text, String previousText) {
    final hasPrice = text.isNotEmpty && text.trim() != previousText.trim();
    if (hasPrice != isPrice) {
      setState(() {
        isPrice = hasPrice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<PassengerTripProvider>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: widget.controller,
              onChanged: (value) {
                _checkUpdatePrice(value, tripProvider.currentTrip.price);
              }, // ⬅️ التغيير هنا
              decoration: InputDecoration(
                filled: true,
                hintText: 'Price of trip',
                fillColor: AppColors.greyColor,
                suffixText: 'EGP',
                suffixStyle: const TextStyle(color: AppColors.darkRed),
              ),
            ),
          ),
          IconButton(
            onPressed: ((tripProvider.currentTrip.price.trim() !=
                        widget.controller.text.trim()) &&
                    isPrice)
                ? ()async {
                    debugPrint('Price changed to: ${widget.controller.text}');
                    await tripProvider
                        .changePassengerPrice(widget.controller.text.trim());
                    debugPrint(
                        'Price updated in provider: ${tripProvider.currentTrip.price}');
                    _checkUpdatePrice(tripProvider.currentTrip.price,
                        tripProvider.currentTrip.price);
                  }
                : null,
            icon: Icon(
              Icons.check,
              color: (isPrice) ? AppColors.primaryColor : AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}
