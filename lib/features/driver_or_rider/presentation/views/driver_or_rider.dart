import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/constant/asset_images.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedWidgets/logo_widget.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver_home/presentation/views/driver_home.dart';
import 'package:dirver/features/driver_info/presentation/views/first_screen.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/widgets/how_are_you.dart';
import 'package:dirver/features/passenger_home/presentation/views/passenger_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverOrRider extends StatelessWidget {
  const DriverOrRider({super.key});
  static const String routeName = '/driver_or_rider';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const LogoWidget(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Image.asset(AssetImages.handShake, height: 300),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.13),
              const Spacer(),
              HowAreYou(
                text: 'Driver',
                colorButton: AppColors.primaryColor,
                colorText: AppColors.whiteColor,
                onPressed: () async {


                  bool? isDriver = await StoreUserType.getDriver();
                  if(isDriver == true){
                      Navigator.pushReplacementNamed(context,
                          DriverHome.routeName);
                  }
                  else {
                    await StoreUserType.saveDriver(true);
                    Navigator.pushReplacementNamed(context,
                      DriverInfoView1.routeName);
                  }
                },
              ),
              const SizedBox(height: 10),
              HowAreYou(
                text: 'Passenger',
                colorButton: AppColors.primaryColor,
                colorText: AppColors.whiteColor,
                onPressed: () async {

                    await StoreUserType.saveLastSignIn('passenger');
                    bool? pass = await StoreUserType.getPassenger();
                    if(pass != true){
                      await StoreUserType.savePassenger(true);
                      CollectionReference passenger =
                      FirebaseFirestore.instance.collection('passengers');
                      User? user = FirebaseAuth.instance.currentUser;

                      await passenger.add({
                        'name': user?.displayName,
                        'phone': user?.phoneNumber,
                        'email':user?.email,
                        'currentLocation':{'lat':30,'long':40},
                        'requestTrip':'tripId'
                      });
                    }

                  Navigator.pushReplacementNamed(context,
                      PassengerHome.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
