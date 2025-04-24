import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/features/driver_home/presentation/views/driver_home.dart';
import 'package:dirver/features/driver_info/presentation/views/widgets/next_button.dart';
import 'package:dirver/features/driver_info/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver_info/presentation/views/widgets/text_field_widger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/sharedPref/store_user_type.dart';
import '../provider/driver_provider.dart';

class DriverInfoView4 extends StatelessWidget {
  DriverInfoView4({super.key});
  final formKey = GlobalKey<FormState>();
  static const String routeName = '/driver_info_view4';

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<DriverProvider>(context);

    // List of images for PickPicture (Handling null values safely)
    final List<Map<String, String?>> pickPictures = [
      {
        'text': 'Image of Car',
        'id': '41',
        'imagePath': userProvider.carImagePath
      },
      {
        'text': 'License of Car',
        'id': '42',
        'imagePath': userProvider.carLicense
      },
      {
        'text': 'Back of License of Car',
        'id': '43',
        'imagePath': userProvider.backCarLicense
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Info', style: TextStyle()),
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
                          imagePath:
                              pickPictures[index]['imagePath']!.isNotEmpty
                                  ? pickPictures[index]['imagePath']
                                  : null, // Pass null if imagePath is empty
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 100),

                buildTextField(
                  label: 'Icon of Car',
                  onSaved: (value) => userProvider.carIcon = value!,
                ),
                buildTextField(
                  label: 'Model of Car',
                  onSaved: (value) => userProvider.carModel = value!,
                ),
                buildTextField(
                  label: 'Color of Car',
                  onSaved: (value) => userProvider.carColor = value!,
                ),
                buildTextField(
                  label: 'Year of Car Production',
                  onSaved: (value) => userProvider.carYear = value!,
                ),
                buildTextField(
                  label: 'Plate of Car',
                  onSaved: (value) => userProvider.carPlate = value!,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.3),

                buildNextButton(() async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                        var userProvider = Provider.of<DriverProvider>(context,listen: false);

                    CollectionReference drivers =
                        FirebaseFirestore.instance.collection('drivers');
                    User? user = FirebaseAuth.instance.currentUser;
                    await StoreUserType.saveLastSignIn('driver');
                    await drivers.add({
                      'name': userProvider.name,
                      'email':user?.email,
                      'rate': 4.5,
                    });
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      DriverHome.routeName
                      , (route) => false
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
