import 'package:dirver/core/utils/app_route.dart';
import 'package:dirver/core/utils/theme.dart';
import 'package:dirver/features/splash_screen/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver APP',
      theme: lightTheme.copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
      ),
      themeMode: ThemeMode.system,
      home: SplashView(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
