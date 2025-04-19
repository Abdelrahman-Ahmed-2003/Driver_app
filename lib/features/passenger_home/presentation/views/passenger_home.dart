import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/bottom_sheet_app.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/show_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PassengerHome extends StatelessWidget {
  const PassengerHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              var provider = context.read<ContentOfTripProvider>();
              provider.clear();

              // await GoogleSignIn().signOut(); // Sign out from Google account
              // await FirebaseAuth.instance.signOut(); // Sign out from Firebase
              await StoreUserType.saveLastSignIn('null');
              // Clear the user type from shared preferences
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverOrRider(),
                  ));
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 25,
          child: Stack(
            children: [
              ShowMap(isDriver: false,),
              BottomSheetWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
