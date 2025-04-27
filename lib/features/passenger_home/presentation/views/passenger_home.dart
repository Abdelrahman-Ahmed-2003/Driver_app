import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/tripProvider.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/bottom_sheet_app.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/show_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PassengerHome extends StatelessWidget {
  const PassengerHome({super.key});

  static const String routeName = '/passengerHome';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentOfTripProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                var contentProvider = context.read<ContentOfTripProvider>();
                var tripProvider = context.read<TripProvider>();
                if (tripProvider.tripStream != null) return;
                contentProvider.clear();
                await StoreUserType.saveLastSignIn('null');
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(
                  context,
                  DriverOrRiderView.routeName,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 25,
            child: Stack(
              children: const [
                ShowMap(isDriver: false),
                BottomSheetWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
