import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:dirver/core/utils/colors_app.dart';

class SkeletonizerWidget extends StatelessWidget {
  const SkeletonizerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      child: ListView.builder(
        itemCount: 2,
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.cardBorderLight, width: 1),
            ),
            elevation: 2,
            shadowColor: AppColors.blackColor,
            color: AppColors.whiteColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.blueColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Destination',
                          style: TextStyle(fontSize: 15, color: AppColors.darkGrey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Calculating distances...'),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffix: const Text('EGP'),
                      hintText: "EGP",
                      filled: true,
                      fillColor: AppColors.greyColor.withOpacity(0.2),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("ACCEPT"),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
