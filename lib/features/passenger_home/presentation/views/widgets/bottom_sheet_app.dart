import 'package:dirver/features/passenger_home/presentation/provider/trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/address_field.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/list_view_widget.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/price_field.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/search_button.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key});
  // TextEditingController fromController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    debugPrint('build bottom sheet widget ');
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: 
            Container(
                decoration: const BoxDecoration(
                    color: Color(0XFF661AFD),
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                // alignment: Alignment.bottomRight,
                height: 50,
                width: 50,
                child: IconButton(
                  onPressed: () {
                    var provider = context.read<TripProvider>();
                    provider.toController.clear();
                    provider.priceController.clear();
                    provider.setFrom('');
                    provider.setPrice('');
                    provider.setDest(LatLng(0, 0));
                    provider.setCurrentPoints(LatLng(0, 0));
                    provider.points.clear();
                    provider.lastDest = null;
                  },
                  icon: Icon(
                    Icons.wrong_location_outlined,
                    color: Colors.white,
                  ),
                )),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            height: 250,
            width: double.infinity,
            child: Column(
              children: [
                ListViewWidget(),
                // AddressField(hintText: 'From', controller: fromController),
                AddressField(hintText: 'To',),
                PriceField(),
                SearchButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
