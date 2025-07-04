import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/driver/presentation/provider/driver_provider.dart';
import 'package:dirver/features/driver/presentation/views/third_screen.dart';
import 'package:dirver/features/driver/presentation/views/widgets/next_button_info.dart';
import 'package:dirver/features/driver/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver/presentation/views/widgets/text_field_widger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverInfoView2 extends StatelessWidget {
  DriverInfoView2({super.key});
  final formKey = GlobalKey<FormState>();
  static const String routeName = '/driver_info_view2';

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<DriverProvider>(context);

    // List of images for PickPicture (Handling null values safely)
    final List<Map<String, String?>> pickPictures = [
      {
        'text': 'Driving License',
        'id': '21',
        'imagePath': userProvider.frontLicenseDrivingImagePath
      },
      {
        'text': 'Back Driving License',
        'id': '22',
        'imagePath': userProvider.backLicenseDrivingImagePath
      },
      {
        'text': 'Selfie with License',
        'id': '23',
        'imagePath': userProvider.selfieImageWithLicense
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Licenses', style: TextStyle()),
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
                    scrollDirection:
                        Axis.horizontal, // ✅ Enable horizontal scrolling
                    itemCount: pickPictures.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10), // Space between items
                        child: PickPicture(
                          text: pickPictures[index]['text']!,
                          id: pickPictures[index]['id']!,
                          imagePath: pickPictures[index]['imagePath'],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 100),

                buildTextField(
                    label: 'Number of License',
                    onSaved: (value) => userProvider.numberOfLicense = value!),
                buildTextField(
                    label: 'Expired Date of License',
                    onSaved: (value) => userProvider.expirationDate = value!),

                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildNextButton(() {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          if (userProvider.frontLicenseDrivingImagePath == null ||
              userProvider.backLicenseDrivingImagePath == null ||
              userProvider.selfieImageWithLicense == null) {
            errorMessage(context, 'Please pick all images');
            return;
          }
          Navigator.pushNamed(context, DriverInfoView3.routeName,
              arguments: userProvider);
        }
      }),
    );
  }
}
