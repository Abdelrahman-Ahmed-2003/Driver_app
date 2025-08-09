import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/passenger/presentation/views/passenger_home.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';
import 'package:dirver/features/trip/presentation/views/passenger_trip_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as location_package;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

void errorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating, // <-- Important!!
      margin: const EdgeInsets.all(20), // <-- Add margin to not cover bottomNavigationBar
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

Future<bool> alertMessage(String message, BuildContext context) async {
  bool confirmed = false;

  await QuickAlert.show(
    context: context,
    type: QuickAlertType.confirm,
    title: 'Confirmation',
    text: message,
    confirmBtnText: 'OK',
    cancelBtnText: 'No',
    onConfirmBtnTap: () {
      confirmed = true;
      Navigator.of(context).pop();
    },
    onCancelBtnTap: () {
      confirmed = false;
      Navigator.of(context).pop();
    },
  );

  return confirmed;
}

 

Future<location_package.LocationData?> getCurrentLocation() async {
  final location = location_package.Location();

  // Ensure location services are enabled
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return null;
  }

  // Check for permission
  location_package.PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == location_package.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != location_package.PermissionStatus.granted) {
      return null;
    }
  }

  // Get current location
  try {
    return await location.getLocation();
  } catch (e) {
    print("Error getting location: $e");
    return null;
  }
}




Future<String?> searchAboutUserOnline({
    required String type, // "drivers" or "passengers"
    required String email,
  }) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final result = await firestore
          .collection(type)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        return result.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

Future<void> checkPassengerStatus() async {
  var isPassenger = await StoreUserType.getPassenger();
  debugPrint('splashView: isPassenger: $isPassenger');

  if (isPassenger == false || isPassenger == null) {
    debugPrint('splashView: user is not a passenger');
    final passengerId = await searchAboutUserOnline(
      type: 'passengers',
      email: FirebaseAuth.instance.currentUser!.email!,
    );
    if (passengerId != null) {
      debugPrint('splashView: user is a passenger');
      await StoreUserType.savePassenger(true);
      await StoreUserType.savePassengerDocId(passengerId);
    }
  }
}

Future<bool> checkDriverStatus() async {
  var isDriver = await StoreUserType.getDriver();

  if (isDriver == false || isDriver == null) {
    debugPrint('splashView: user is not a driver');
    final driverId = await searchAboutUserOnline(
      type: 'drivers',
      email: FirebaseAuth.instance.currentUser!.email!,
    );
    if (driverId != null) {
      debugPrint('splashView: user is a driver');
      await StoreUserType.saveDriver(true);
      await StoreUserType.saveDriverDocId(driverId);
      return true;
    }
  }
      return false;

}


Future<({String routeName, String? tripId})> decideNavigationRoute(String? userType) async {
  String? tripId;

  if (userType == 'passenger') {
    debugPrint('splashView: user is a passenger');
    var passengerDoc = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(await StoreUserType.getPassengerDocId())
        .get();

    var data = passengerDoc.data();
    if (data != null &&
        data['tripId'] != null &&
        data['tripId'] != '') {
      tripId = data['tripId'];
      var tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();
      var tripData = tripDoc.data();

      debugPrint('splashView: tripData: $tripData');

      if (tripData != null &&
          tripData['driverDocId'] != null) {
        debugPrint('splashView: trip has a driver');
        return (routeName: PassengerTripView.routeName, tripId: tripId);
      } else {
        debugPrint('splashView: trip has no driver');
        return (routeName: PassengerHome.routeName, tripId: tripId);
      }
    } else {
      debugPrint('splashView: passenger has no trip');
      return (routeName: PassengerHome.routeName, tripId: null);
    }
  } else if (userType == 'driver') {
    debugPrint('splashView: user is a driver');
    var driverDoc = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(await StoreUserType.getDriverDocId())
        .get();
    var data = driverDoc.data();
    if (data != null &&
        data['tripId'] != null &&
        data['tripId'] != '') {
      tripId = data['tripId'];
      debugPrint('splashView: driver has a trip');
      return (routeName: DriverTripView.routeName, tripId: tripId);
    } else {
      debugPrint('splashView: driver has no trip');
      return (routeName: DriverHome.routeName, tripId: null);
    }
  } else {
    debugPrint('splashView: user type is null or unknown');
    return (routeName: DriverOrRiderView.routeName, tripId: null);
  }
}

Future<String> coordsToAddress(double lat, double lng) async {
    debugPrint('Converting coordinates to address: $lat, $lng');
  // Returns a list of Placemark; we take the first
  final placemarks = await placemarkFromCoordinates(lat, lng);

  if (placemarks.isEmpty) return 'No address available';

  final Placemark p = placemarks.first;

  // Compose the full street-level address (customise as you like)
  return [
    p.street,            // e.g. “5th Avenue”
    p.subLocality,       // e.g. “Manhattan”
    p.locality,          // e.g. “New York”
    p.country            // e.g. “United States”
  ].where((e) => e != null && e.isNotEmpty).join(', ');
}

