import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/constant/asset_images.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedWidgets/logo_widget.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:dirver/features/driver/presentation/views/first_screen.dart';
import 'package:dirver/core/utils/search_about_user.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/widgets/how_are_you.dart';
import 'package:dirver/features/passenger/presentation/views/passenger_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverOrRiderBody extends StatelessWidget {
  const DriverOrRiderBody({super.key});
  

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
              
              const SizedBox(height: 10),
              HowAreYou(
                text: 'Passenger',
                colorButton: AppColors.primaryColor,
                colorText: AppColors.whiteColor,
                onPressed: () async {
                    await StoreUserType.saveLastSignIn('passenger');
                    bool? pass = await StoreUserType.getPassenger();
                    if (pass != true) {
                      await StoreUserType.savePassenger(true);
                      CollectionReference passenger = FirebaseFirestore.instance.collection('passengers');
                      User? user = FirebaseAuth.instance.currentUser;

                      DocumentReference newPassengerRef = await passenger.add({
                        'name': user?.displayName,
                        'phone': user?.phoneNumber,
                        'email': user?.email,
                      });

                      String newPassengerId = newPassengerRef.id; // ✅ This is the new document ID
                      await StoreUserType.savePassengerDocId(newPassengerId);
                      debugPrint("New passenger document ID: $newPassengerId");

                      // You can now use `newPassengerId` to reference or store the ID
                    }

                  if(!context.mounted) return;
                  Navigator.pushReplacementNamed(context,
                      PassengerHome.routeName);
                },
              ),
              const SizedBox(height: 10),
              HowAreYou(
  text: 'Driver',
  colorButton: AppColors.blueColor,
  colorText: AppColors.whiteColor,
  onPressed: () async {
    bool? isDriver = await StoreUserType.getDriver();
    if (isDriver == true) {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverHome(),
        ),
      );
    } else {
      bool? isOnline = await searchAboutUserOnline(
        type: 'drivers',
        email: FirebaseAuth.instance.currentUser!.email!,
      );
      if (isOnline == true) {
        if (!context.mounted) return;
        errorMessage(context, 'Welcome back driver');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DriverHome(),
          ),
        );
      } else if (isOnline == false) {
        if (!context.mounted) return;
        errorMessage(context, 'We Welcome you to our app as new driver');
        Navigator.pushNamed(context, DriverInfoView1.routeName);
      } else {
        if (!context.mounted) return;
        errorMessage(context, 'Error occurred while searching for user');
      }
    }
  },
),

            ],
          ),
        ),
      ),
    );
  }
}
