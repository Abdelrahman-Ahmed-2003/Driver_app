import 'package:dirver/features/selected_trip/presentation/views/selected_trip.dart';
import 'package:dirver/features/driver_home/presentation/views/widgets/trip_card.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedCards extends StatefulWidget {
  final List<Map<String, dynamic>> trips;
  const AnimatedCards({super.key,required this.trips});

  @override
  State<AnimatedCards> createState() => _AnimatedCardsState();
}

class _AnimatedCardsState extends State<AnimatedCards> {
   late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    
  }


  @override
  Widget build(BuildContext context) {
    return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: widget.trips.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.position.haveDimensions) {
                    double page = _pageController.page ?? _pageController.initialPage.toDouble();
                    scale = (1 - (page - index).abs() * 0.2).clamp(0.8, 1.0);
                  }
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ContentOfTripProvider()),
          ChangeNotifierProvider(create: (_) => TripProvider()),
        ],
        child: SelectedTrip(trip: widget.trips[index]),
      ),
    ),
  );
},

                      child: TripCard(trip: widget.trips[index]),
                    ),
                  );
                },
              );
            },
          );
  }
}