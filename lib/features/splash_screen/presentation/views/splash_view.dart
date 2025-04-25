import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/auth/presentation/views/login_view.dart';
import 'package:dirver/features/driver_home/presentation/views/driver_home.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/passenger_home/presentation/views/passenger_home.dart';
import 'package:dirver/features/splash_screen/presentation/views/widgets/logo_animation.dart';
import 'package:dirver/features/splash_screen/presentation/views/widgets/text_in_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  static const routeName = '/splash-screen';

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  double ballY = 0;
  bool add = false;
  bool showShadow = false;
  int times = 0;
  bool showComic = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            if (add) {
              ballY += 15;
            } else {
              ballY -= 15;
            }
            if (ballY <= -200) {
              times += 1;
              add = true;
              showShadow = true;
            }
            if (ballY >= 0) {
              add = false;
              showShadow = false;
            }
            if (times == 3) {
              showShadow = false;
              Timer(const Duration(milliseconds: 300), () {
                setState(() {
                  showComic = true;
                });
              });
              _controller.stop();
            }
            setState(() {});
          });

    _controller.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
  await Future.delayed(const Duration(seconds: 4));

  if (!mounted) return; // ✅ Ensure context is still valid

  if (FirebaseAuth.instance.currentUser != null) {
    String? userType = await StoreUserType.getLastSignIn();

    if (!mounted) return; // ✅ Again after async

    if (userType == 'passenger') {
      Navigator.pushReplacementNamed(context, PassengerHome.routeName);
    } else if (userType == 'driver') {
      Navigator.pushReplacementNamed(context, DriverHome.routeName);
    } else {
      // errorMessage(context, 'Sorry, error occurred.');
      Navigator.pushReplacementNamed(context, DriverOrRiderView.routeName);
    }
  } else {
    Navigator.pushReplacementNamed(context, LoginView.routeName);
  }
});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          double widthVal = times < 3 ? 50 + (times * 50) : screenWidth;
          double heightVal = times < 3 ? 50 + (times * 50) : screenHeight;
          double bottomVal = times < 3 
    ? screenHeight * 0.6 - (times * (screenHeight * 0.2)) 
    : 0;


          return Stack(
            alignment: Alignment.center,
            children: [
              LogoAnimation(
                bottomVal: bottomVal,
                heightVal: heightVal,
                ballY: ballY,
                times: times,
                showShadow: showShadow,
                widthVal: widthVal,
              ),
              if (showComic)
                Positioned(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_car_filled,
                            size: 60,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 10),
                          DefaultTextStyle(
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 30.0,
                              fontFamily: 'Bobbers',
                            ),
                            child: AnimatedTextKit(
                              totalRepeatCount: 1,
                              animatedTexts: [
                                TyperAnimatedText('Driver'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const TextInSplash(text: 'Choose the suitable trip for you'),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

Future<String?> getUserAddress() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Location services are disabled.";
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permission denied.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Location permissions are permanently denied.";
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return "${place.locality}, ${place.country}";
    } else {
      return "No address found.";
    }
  } catch (e) {
    return "Error: $e";
  }
}
