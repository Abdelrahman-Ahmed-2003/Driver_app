import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/views/widgets/animated_cards.dart';
import 'package:dirver/core/sharedWidgets/shimmer_trip_card.dart';
import 'package:flutter/material.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  static const String routeName = '/driver_home';

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await StoreUserType.saveDriver(true);
      await StoreUserType.saveLastSignIn('driver');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Trips"),
        actions: [
          IconButton(
            onPressed: () async {
              await StoreUserType.saveLastSignIn('null');
              if (!context.mounted) return;
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
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerTripCard(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No available trips"));
          }

          final trips = snapshot.data!;

          return AnimatedCards(trips: trips);
        },
      ),
    );
  }
}
