import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/bottom_sheet_app.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/show_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  static const String routeName = '/passengerHome';

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await StoreUserType.savePassenger(true);
      await StoreUserType.saveLastSignIn('passenger');
    });
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PassengerTripProvider(),
      child: Builder(
        builder: (context) {
          final tripProvider = Provider.of<PassengerTripProvider>(context, listen: false);
          debugPrint("PassengerHome rebuild called");
          debugPrint('tripProvider.tripStream: ${tripProvider.currentTrip}');

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Ride Hailing',
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.whiteColor,
              elevation: 1,
              centerTitle: true,
              iconTheme: const IconThemeData(color: AppColors.primaryColor),
              actions: [
                IconButton(
                  onPressed: () async {
                    if (tripProvider.tripStream != null) return;
                    tripProvider.clear();
                    await StoreUserType.saveLastSignIn('null');
                    await StoreUserType.savePassengerDocId('null');
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(
                      context,
                      DriverOrRiderView.routeName,
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppColors.primaryColor),
                ),
              ],
            ),
            body: FutureBuilder(
  future: tripProvider.fetchTripData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            ShowMap(
              isDriver: false,
              tripProvider: tripProvider,
            ),
            const BottomSheetWidget(),


          ],
        ),
      ),
    );
  },
),

          );
        },
      ),
    );
  }
}
