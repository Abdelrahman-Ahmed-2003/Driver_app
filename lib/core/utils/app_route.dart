import 'package:dirver/features/auth/presentation/views/login_view.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:dirver/features/driver/presentation/provider/driver_provider.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/views/select_driver.dart';
import 'package:dirver/features/driver/presentation/views/first_screen.dart';
import 'package:dirver/features/driver/presentation/views/fourth_screen.dart';
import 'package:dirver/features/driver/presentation/views/second_screen.dart';
import 'package:dirver/features/driver/presentation/views/third_screen.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/passenger/presentation/views/passenger_home.dart';
import 'package:dirver/features/splash_screen/presentation/views/splash_view.dart';
import 'package:dirver/features/trip/presentation/views/driver_trip_view.dart';
import 'package:dirver/features/trip/presentation/views/passenger_trip_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashView.routeName:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case LoginView.routeName:
        return MaterialPageRoute(builder: (_) => LoginView());
      case DriverOrRiderView.routeName:
        return MaterialPageRoute(builder: (_) => const DriverOrRiderView());
      case PassengerHome.routeName:
        return MaterialPageRoute(builder: (_) => const PassengerHome());
      case DriverHome.routeName:
        return MaterialPageRoute(builder: (_) => const DriverHome());
      case DriverInfoView1.routeName:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => DriverProvider(),
            child: DriverInfoView1(),
          ),
        );

      case DriverInfoView2.routeName:
        final driverProvider = settings.arguments as DriverProvider;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: driverProvider,
            child: DriverInfoView2(),
          ),
        );

      case DriverInfoView3.routeName:
        final driverProvider = settings.arguments as DriverProvider;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: driverProvider,
            child: DriverInfoView3(),
          ),
        );

      case DriverInfoView4.routeName:
        final driverProvider = settings.arguments as DriverProvider;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: driverProvider,
            child: DriverInfoView4(),
          ),
        );
        
      // case SelectedTrip.routeName:
      //   return MaterialPageRoute(builder: (_) => SelectedTrip(trip: null,));
      case SelectDriver.routeName:
        final provider = settings.arguments as PassengerTripProvider;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const SelectDriver(),
          ),
        );
      case DriverTripView.routeName:
        return MaterialPageRoute(builder: (_) => const DriverTripView());
      case PassengerTripView.routeName:
        return MaterialPageRoute(builder:(_)=> const PassengerTripView());
      default:
        return MaterialPageRoute(builder: (_) => errorRoute());
    }
  }

  static Widget errorRoute() {
    return const Scaffold(
      body: Center(
        child: Text('Error: Route not found'),
      ),
    );
  }
}
