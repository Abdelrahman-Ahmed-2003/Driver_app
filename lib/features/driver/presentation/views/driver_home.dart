import 'package:dirver/features/driver/presentation/views/widgets/no_trip_widget.dart';
import 'package:dirver/features/driver/presentation/views/widgets/skeletonizer_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dirver/core/services/sharedPref/store_user_type.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/widgets/animated_cards.dart';

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
final provider = context.read<DriverTripProvider>();
  provider.isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      

      await StoreUserType.saveDriver(true);
      await StoreUserType.saveLastSignIn('driver');

      if (!provider.isDriverDocIdFetched) {
        await provider.fetchDriverDocId();
      }
      provider.listenTrips();
    });
  }



  @override
  Widget build(BuildContext context) {
    var provider = context.read<DriverTripProvider>();
    debugPrint('DriverHome Rebuild');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Available Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await StoreUserType.saveLastSignIn('null');
              provider.clear();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DriverOrRiderView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Consumer<DriverTripProvider>(
        
        builder: (context, provider, child) {
          debugPrint('Consumer build ${provider.availableTrips.length}');
          if(provider.isLoading) return const SkeletonizerWidget();
          
          return provider.isLoading
          ?  SkeletonizerWidget()
          :(!provider.updated ? const Center(child: NoTripWidget()):const AnimatedCards()); 
        },
      ),
          
    );
  }
}
