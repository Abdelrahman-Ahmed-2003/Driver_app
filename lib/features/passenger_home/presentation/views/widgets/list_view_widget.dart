import 'package:dirver/core/utils/colors_app.dart';
import 'package:flutter/material.dart';

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
    return SizedBox(
      height: 50, // ✅ Constrain height
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
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
