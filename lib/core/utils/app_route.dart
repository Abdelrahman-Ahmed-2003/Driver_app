import 'package:dirver/features/auth/presentation/views/login_view.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/views/select_driver.dart';
import 'package:dirver/features/selected_trip/presentation/views/selected_trip.dart';
import 'package:dirver/features/driver_info/presentation/views/first_screen.dart';
import 'package:dirver/features/driver_info/presentation/views/fourth_screen.dart';
import 'package:dirver/features/driver_info/presentation/views/second_screen.dart';
import 'package:dirver/features/driver_info/presentation/views/third_screen.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/passenger/presentation/views/passenger_home.dart';
import 'package:dirver/features/splash_screen/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';

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
        return MaterialPageRoute(builder: (_) => DriverInfoView1());
      case DriverInfoView2.routeName:
        return MaterialPageRoute(builder: (_) => DriverInfoView2());
      case DriverInfoView3.routeName:
        return MaterialPageRoute(builder: (_) => DriverInfoView3());
      case DriverInfoView4.routeName:
        return MaterialPageRoute(builder: (_) => DriverInfoView4());
      case SelectedTrip.routeName:
        return MaterialPageRoute(
            builder: (_) => SelectedTrip(trip: settings.arguments as Map<String, dynamic>));
      case SelectDriver.routeName:
      final args = settings.arguments as PassengerTripProvider;
        return MaterialPageRoute(
            builder: (_) => SelectDriver(provider: args,));
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