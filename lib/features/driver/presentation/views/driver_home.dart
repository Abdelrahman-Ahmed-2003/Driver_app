import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/animated_cards.dart';
import 'package:dirver/core/sharedWidgets/shimmer_trip_card.dart';
import 'package:flutter/material.dart';
import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:provider/provider.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  static const String routeName = '/driver_home';
  

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  late final DriverTripProvider _provider;
  @override
  void initState() {
    super.initState();
    _provider = Provider.of<DriverTripProvider>(context, listen: false);
      _provider.reconnectTripStream();
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
              await StoreUserType.saveDriverDocId('null');
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
      body:Consumer<DriverTripProvider>(
  builder: (context, provider, _) {
    if (!provider.isDriverDocIdFetched) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: provider.listenForAvailableTrips(),
      builder: (context, snapshot) {
        debugPrint(" rebuild Snapshot");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No available trips"));
        }

        final trips = snapshot.data!;
        debugPrint("Trips: $trips");

        return AnimatedCards(trips: trips);
      },
    );
  },
),

    );
  }
}