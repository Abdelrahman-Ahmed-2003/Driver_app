import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/sharedPref/store_user_type.dart';
import '../../../driver_or_rider/presentation/views/driver_or_rider.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Trips"),
      actions: [
        IconButton(onPressed: () async {
          await StoreUserType.saveLastSignIn('null');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverOrRider(),));
    }, icon: Icon(Icons.logout_outlined))
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: listenForAvailableTrips(), // ✅ Listen for new trips
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No available trips"));
          }

          List<Map<String, dynamic>> trips = snapshot.data!;
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              var trip = trips[index];
              return ListTile(
                title: Text("Trip to: ${trip['destination']}"),
                subtitle: Text("Passenger: ${trip['passengerName']}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    acceptTrip(trip['tripId']);
                  },
                  child: Text("Accept"),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to accept a trip
  Future<void> acceptTrip(String tripId) async {
    try {
      User? driver = FirebaseAuth.instance.currentUser;
      if (driver == null) throw "Driver is not logged in";

      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'driverId': driver.uid,
        'status': 'in progress',
      });

      print("✅ Trip accepted by driver ${driver.uid}");
    } catch (e) {
      print("❌ Error accepting trip: $e");
    }
  }
}


Stream<List<Map<String, dynamic>>> listenForAvailableTrips() {
  User? user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('trips')
      .where('status', isEqualTo: 'waiting') // ✅ Only trips needing a driver
      .where('email', isNotEqualTo: user?.email) // ✅ Exclude trips created by this driver
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => {
      'tripId': doc.id,
      ...doc.data(),
    }).toList();
  });
}

