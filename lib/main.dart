import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:dirver/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  // await Supabase.initialize(url: 'https://roqhphnlmagvhxfhncaw.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvcWhwaG5sbWFndmh4ZmhuY2F3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxNTExNDUsImV4cCI6MjA1NTcyNzE0NX0.d-DyQVT2gEh7FRTErDVFy00D9t4t9fdLML3ErUd-BtQ');
  try {
    await Firebase.initializeApp(
    );
  } catch (e) {
    throw Exception('Failed to initialize Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DriverTripProvider()),
        ChangeNotifierProvider(create: (context)=> PassengerTripProvider())


      ],
      child: MyApp(),
    ),
  );
}


