import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/provider/passenger_trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListViewWidget extends StatefulWidget {
  const ListViewWidget({super.key});

  @override
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  int selectedIndex = 0;
  List<String> items = ["Car", "Motorcycle"];
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PassengerTripProvider>();
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.opalGrey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (provider.tripStream != null) return;
                setState(() {
                  selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? AppColors.whiteColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selectedIndex == index
                      ? [
                          BoxShadow(
                            color: AppColors.blackColor.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      color: selectedIndex == index
                          ? AppColors.primaryColor
                          : AppColors.darkGrey,
                      fontWeight: selectedIndex == index
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}