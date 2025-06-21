import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:location/location.dart';
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

 

Future<LocationData?> getCurrentLocation() async {
  Location location = Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return null;
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) return null;
  }

  return await location.getLocation();
}
