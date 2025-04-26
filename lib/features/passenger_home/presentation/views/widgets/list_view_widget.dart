import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger_home/presentation/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListViewWidget extends StatefulWidget {
  const ListViewWidget({super.key});

  @override
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  int selectedIndex = 0; // ✅ Track selected item
  List<String> items = ["Car", "Motocycle"];
  @override
  Widget build(BuildContext context) {
    final TripProvider tripProvider = context.watch<TripProvider>();
    return SizedBox(
      height: 50, // ✅ Constrain height
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if(tripProvider.tripStream != null) return; // ✅ Prevent selection if trip is active
                setState(() {
                  selectedIndex = index; // ✅ Update selected item
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? Color(0XFFC1CDCB)// ✅ Selected item color
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    items[index],
                    style: const TextStyle(color: AppColors.whiteColor),
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
