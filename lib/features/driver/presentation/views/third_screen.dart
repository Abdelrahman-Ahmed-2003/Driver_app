import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/views/widgets/next_button_info.dart';
import 'package:dirver/features/driver/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver/presentation/views/widgets/text_field_widger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/driver_provider.dart';
import 'fourth_screen.dart';

class DriverInfoView3 extends StatelessWidget {
  DriverInfoView3({super.key});
  final formKey = GlobalKey<FormState>();
  static const String routeName = '/driver_info_view3';

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<DriverProvider>(context);

    // List of images for PickPicture (Handling null values safely)
    final List<Map<String, String?>> pickPictures = [
      {'text': 'ID', 'id': '31', 'imagePath': userProvider.idImagePath},
      {'text': 'Back ID', 'id': '32', 'imagePath': userProvider.backIDImagePath},
      {'text': 'El-Fesh', 'id': '33', 'imagePath': userProvider.feshPath},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Folders', style: TextStyle()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                // ✅ Horizontally Scrollable PickPicture Widgets (Handles null safely)
                SizedBox(
                  height: 120, // Adjust height as needed
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal, // ✅ Enable horizontal scrolling
                    itemCount: pickPictures.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10), // Space between items
                        child: PickPicture(
                          text: pickPictures[index]['text']!,
                          id: pickPictures[index]['id']!,
                          imagePath: pickPictures[index]['imagePath'], // Pass null if imagePath is empty
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 100),

                buildTextField(
                  label: 'ID Number',
                  onSaved: (value) => userProvider.id = value!,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.3),

                
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildNextButton(() {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    if (userProvider.idImagePath == null ||
                        userProvider.backIDImagePath == null ||
                        userProvider.feshPath == null) {
                      errorMessage(context, 'Please pick all images');
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      DriverInfoView4.routeName,
                      arguments: userProvider,
                    );
                  }
                }),
    );
  }
}
