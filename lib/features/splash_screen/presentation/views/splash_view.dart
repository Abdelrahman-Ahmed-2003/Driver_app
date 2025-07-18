import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/search_about_user.dart';
import 'package:dirver/features/auth/presentation/views/login_view.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/passenger/presentation/views/passenger_home.dart';
import 'package:dirver/features/splash_screen/presentation/views/widgets/logo_animation.dart';
import 'package:dirver/features/splash_screen/presentation/views/widgets/text_in_splash.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';
import 'package:dirver/features/trip/presentation/views/passenger_trip_view.dart';
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
      

      String routeName;
      String? tripId;
      debugPrint('splashView: ${FirebaseAuth.instance.currentUser}');
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint('splashView: user is logged in');
        var isPassenger = await StoreUserType.getPassenger();
      if(isPassenger == false){
        debugPrint('splashView: user is not a passenger');
        final passengerId = await searchAboutUserOnline(
          type: 'passengers',
          email: FirebaseAuth.instance.currentUser!.email!,
        );
        if(passengerId != null) {
          debugPrint('splashView: user is a passenger');
          await StoreUserType.savePassenger(true);
          await StoreUserType.savePassengerDocId(passengerId);
        }
      }
      var isDriver = await StoreUserType.getDriver();
      if(isDriver == false){
        debugPrint('splashView: user is not a driver');
        final driverId = await searchAboutUserOnline(
          type: 'drivers',
          email: FirebaseAuth.instance.currentUser!.email!,
        );
        if(driverId != null) {
          debugPrint('splashView: user is a driver');
          await StoreUserType.saveDriver(true);
          await StoreUserType.saveDriverDocId(driverId);
        }
      }
        String? userType = await StoreUserType.getLastSignIn();

        if (!mounted) return; // ✅ Again after async

        if (userType == 'passenger') {
          debugPrint('splashView: user is a passenger');
          var passengerDoc = await FirebaseFirestore.instance
              .collection('passengers')
              .doc(await StoreUserType.getPassengerDocId())
              .get();

          var data = passengerDoc.data();
          if (data != null &&
              data.containsKey('tripId') &&
              data['tripId'] != null &&
              data['tripId'] != '') {
            // if the passenger has a trip, redirect to the trip view
            tripId = data['tripId'];
            var tripDoc = await FirebaseFirestore.instance
                .collection('trips')
                .doc(tripId)
                .get();
            var tripData = tripDoc.data();
            debugPrint('splashView: tripData: $tripData');
            if(tripData != null && tripData.containsKey('driverDocId') && tripDoc['driverDocId'] != null) {
              debugPrint('splashView: trip has a driver');
              // if the trip has a driver, redirect to the passenger trip view
              routeName = PassengerTripView.routeName;
            } else {
              debugPrint('splashView: trip has no driver');
              // if the trip doesn't have a driver, redirect to the passenger home
              routeName = PassengerHome.routeName;
            }
          } else {
            debugPrint('splashView: passenger has no trip');
            // if the passenger doesn't have a trip, redirect to the home
            routeName = PassengerHome.routeName;
          }
        } else if (userType == 'driver') {
          debugPrint('splashView: user is a driver');
          var driverDoc = await FirebaseFirestore.instance
              .collection('drivers')
              .doc(await StoreUserType.getDriverDocId())
              .get();
          var data = driverDoc.data();
          if (data != null &&
              data.containsKey('tripId') &&
              data['tripId'] != null &&
              data['tripId'] != '') {
                debugPrint('splashView: driver has a trip');
            tripId = data['tripId'];
            routeName = DriverTripView.routeName;
          } else {
            debugPrint('splashView: driver has no trip');
            routeName = DriverHome.routeName;
          }
        } else {
          debugPrint('splashView: user type is null or unknown');
          // errorMessage(context, 'Sorry, error occurred.');
          routeName = DriverOrRiderView.routeName;
        }
      } else {
        debugPrint('splashView: user is not logged in');
        routeName = LoginView.routeName;
      }
      debugPrint('splashView: routeName: $routeName');
      if (routeName == PassengerTripView.routeName) {
        debugPrint('tripIdddddd: $tripId');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PassengerTripView(tripId:tripId),
            
          ),
        );
      } else if (routeName == DriverTripView.routeName) {

        debugPrint('tripId: $tripId');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DriverTripView(tripId: tripId),
            
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, routeName);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 💥 Must be here to avoid the Ticker error
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
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
                // Pass theme color to LogoAnimation if needed
              ),
              if (showComic)
                Positioned(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_filled,
                            size: 60,
                            color: AppColors.orangeColor, // Use accent color for balance
                          ),
                          const SizedBox(width: 10),
                          DefaultTextStyle(
                            style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.black, // Force all splash text to black
                                  fontFamily: 'Bobbers',
                                ) ?? const TextStyle(
                                  color: Colors.black,
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
                      TextInSplash(
                        text: 'Choose the suitable trip for you',
                        // Optionally pass color: Colors.black
                      ),
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
