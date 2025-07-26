import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver/presentation/provider/map_provider.dart';
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
      var tripProvider = context.read<PassengerTripProvider>();
      tripProvider.loadingTrip = true;
      await tripProvider.fetchTripData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var tripProvider = context.watch<PassengerTripProvider>();
    return Scaffold(
      // resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Text(
                'Ride Hailing',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 1,
              centerTitle: true,
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
              actions: [
                IconButton(
                  onPressed: () async {
                    if (tripProvider.tripStream != null) return;
                    tripProvider.clear();
                    await StoreUserType.saveLastSignIn('null');
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(
                      context,
                      DriverOrRiderView.routeName,
                    );
                  },
                  icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            body: tripProvider.loadingTrip == true ? Center(child:CircularProgressIndicator()):

                Container(
                  color: Theme.of(context).colorScheme.background,
                  child: SafeArea(
                    child: ChangeNotifierProvider(
                      create: (_) => MapProvider(),
                      child: Stack(
                        children: [
                          ShowMap(
                            destination:tripProvider.currentTrip.destinationCoords,
                          ),
                          BottomSheetWidget(),
                        ],
                      ),
                    ),
                  ),
                )
          );
  }
}
