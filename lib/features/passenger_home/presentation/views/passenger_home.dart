import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/auth/presentation/views/widgets/login_body.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/bottom_sheet_app.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/show_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PassengerHome extends StatelessWidget {
  const PassengerHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              // await GoogleSignIn().signOut(); // Sign out from Google account
              // await FirebaseAuth.instance.signOut(); // Sign out from Firebase
              await StoreUserType.saveLastSignIn('null');
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
              ShowMap(),
              BottomSheetWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
