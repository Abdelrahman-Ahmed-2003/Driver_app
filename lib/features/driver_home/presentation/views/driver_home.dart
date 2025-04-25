import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver_home/presentation/views/widgets/selected_trip.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});
  static const String routeName = '/driver_home';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Trips"),
        actions: [
          IconButton(
            onPressed: () async {
              await StoreUserType.saveLastSignIn('null');
              if (!context.mounted)return;
              Navigator.pushReplacementNamed(
                context, 
                DriverOrRiderView.routeName,
              );
            }, 
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: listenForAvailableTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 3,
              itemBuilder: (context, index) => const ShimmerTripCard(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No available trips"));
          }

          final trips = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return InkWell(
                onTap: (){
                  Navigator.pushNamed(
                context, 
                SelectedTrip.routeName,
                arguments: trip, // Pass the trip data to the next screen
              );
                },
                child: TripCard(trip: trip));
            },
          );
        },
      ),
    );
  }
}

// ================== Trip Card with Scrollable Destination ==================
class TripCard extends StatefulWidget {
  final Map<String, dynamic> trip;
  
  const TripCard({super.key, required this.trip});

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  @override
  Widget build(BuildContext context) {
    var priceController;
    String nameOfButton = 'Accept Trip';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.greyColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Scrollable Destination Text
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      "Trip to: ${widget.trip['destination']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1, // Ensure text stays in one line
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Add spacing between text and chip
                SizedBox(
                  width: 80,
                  height: 50,
                  child: TextFormField(
                    onChanged: (value) {
                      if(value != widget.trip['price']) {
                        setState(() {
                          nameOfButton = 'update price';  
                        });
                      }
                    },
                    initialValue: widget.trip['price'],
                    keyboardType: TextInputType.number,
                    controller: priceController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0XFFC1CDCB),
                      suffixText: 'EGP',
                      suffixStyle: const TextStyle(color: Color.fromARGB(255, 131, 18, 18)),
        ),
      ),
                ),
                // Chip(
                //   backgroundColor: Colors.amber.shade100,
                //   label: Text(
                //     "${trip['price']} EGP",
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Passenger: ${widget.trip['passengerName']}",
              style: TextStyle(color: AppColors.darkGrey),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Update the price in the trip document
                  if(nameOfButton == 'update price'){
                  FirebaseFirestore.instance.collection('trips').doc(widget.trip['tripId']).update({
                    'updatedPrice': priceController.text,
                  });}
                  acceptTrip(widget.trip['tripId']);
                  },
                child: Text(nameOfButton, style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== Shimmer Loading Card ==================
class ShimmerTripCard extends StatelessWidget {
  const ShimmerTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: AppColors.greyColor,
          highlightColor: AppColors.greyColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                color: AppColors.whiteColor,
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 15,
                color: AppColors.whiteColor,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== Firebase Functions ==================
Future<void> acceptTrip(String tripId) async {
  try {
    final driver = FirebaseAuth.instance.currentUser;
    if (driver == null) throw "Driver is not logged in";

    await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
      'driverId': driver.uid,
      'status': 'in progress',
    });
  } catch (e) {
    debugPrint("❌ Error accepting trip: $e");
  }
}

Stream<List<Map<String, dynamic>>> listenForAvailableTrips() {
  final user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('trips')
      .where('status', isEqualTo: 'waiting')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .where((doc) => doc['passengerEmail'] != user?.email)
          .map((doc) => {'tripId': doc.id, ...doc.data()})
          .toList());
}