import 'package:dirver/features/driver/presentation/provider/driver_trip_provider.dart';
import 'package:dirver/features/driver/presentation/views/selected_trip.dart';
import 'package:dirver/features/driver/presentation/views/widgets/trip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedCards extends StatefulWidget {
  const AnimatedCards({super.key});

  @override
  State<AnimatedCards> createState() => _AnimatedCardsState();
}

class _AnimatedCardsState extends State<AnimatedCards> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    debugPrint('AnimatedCards initState');
    _pageController = PageController(viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverTripProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      itemCount: provider.availableTrips.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double scale = 1.0;
            if (_pageController.position.haveDimensions) {
              double page = _pageController.page ??
                  _pageController.initialPage.toDouble();
              scale = (1 - (page - index).abs() * 0.2).clamp(0.8, 1.0);
            }

            final dynamicHeight = screenHeight * 0.5 * scale;

            return Center(
              child: SizedBox(
                height: dynamicHeight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider,
                          child: SelectedTrip(trip: provider.availableTrips[index]),
                        ),
                      ),
                    );
                  },
                  child: TripCard(trip: provider.availableTrips[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
