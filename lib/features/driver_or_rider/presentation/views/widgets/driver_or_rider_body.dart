import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/sharedWidgets/logo_widget.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:dirver/features/driver/presentation/views/first_screen.dart';
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
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cardBorderDark.withOpacity(0.10)
                      : AppColors.cardBorderLight.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark.withOpacity(0.92)
                  : AppColors.cardLight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LogoWidget(),
                    const SizedBox(height: 32),
                    Text(
                      'Continue as:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 32),
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
                        }
                        else{
                        }
                        if(!context.mounted) return;
                        Navigator.pushReplacementNamed(context, PassengerHome.routeName);
                      },
                    ),
                    const SizedBox(height: 18),
                    HowAreYou(
                      text: 'Driver',
                      colorButton: AppColors.blueColor,
                      colorText: AppColors.whiteColor,
                      onPressed: () async {
                        bool? isDriver = await StoreUserType.getDriver();
                        if (isDriver == true) {
                          await StoreUserType.saveLastSignIn('driver');
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DriverHome(),
                            ),

                          );
                        } else {
                            bool isDriver =await checkDriverStatus();
                            if(isDriver){
                              StoreUserType.saveLastSignIn('driver');
                              StoreUserType.saveDriver(true);
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DriverHome(),
                                ),
                              );
                              return;
                            } 
                            
                            if (!context.mounted) return;
                            Navigator.pushNamed(context, DriverInfoView1.routeName);
                          
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
