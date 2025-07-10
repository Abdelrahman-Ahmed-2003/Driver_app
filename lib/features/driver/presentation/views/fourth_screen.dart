import 'package:dirver/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_provider.dart';
import 'package:dirver/features/driver/presentation/views/driver_home.dart';
import 'package:dirver/features/driver/presentation/views/widgets/next_button_info.dart';
import 'package:dirver/features/driver/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver/presentation/views/widgets/text_field_widger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/sharedPref/store_user_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverInfoView4 extends StatefulWidget {
  const DriverInfoView4({super.key});
  static const String routeName = '/driver_info_view4';

  @override
  State<DriverInfoView4> createState() => _DriverInfoView4State();
}

class _DriverInfoView4State extends State<DriverInfoView4> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController carIconController;
  late final TextEditingController carModelController;
  late final TextEditingController carColorController;
  late final TextEditingController carYearController;
  late final TextEditingController carPlateController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<DriverProvider>(context, listen: false);
    carIconController = TextEditingController(text: userProvider.carIcon ?? '');
    carModelController = TextEditingController(text: userProvider.carModel ?? '');
    carColorController = TextEditingController(text: userProvider.carColor ?? '');
    carYearController = TextEditingController(text: userProvider.carYear ?? '');
    carPlateController = TextEditingController(text: userProvider.carPlate ?? '');
  }

  @override
  void dispose() {
    carIconController.dispose();
    carModelController.dispose();
    carColorController.dispose();
    carYearController.dispose();
    carPlateController.dispose();
    super.dispose();
  }

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

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Car Info', style: TextStyle()),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cardBorderDark.withOpacity(0.10)
                      : AppColors.cardBorderLight.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark.withOpacity(0.92)
                  : AppColors.cardLight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: pickPictures.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: PickPicture(
                                text: pickPictures[index]['text']!,
                                id: pickPictures[index]['id']!,
                                imagePath: pickPictures[index]['imagePath'],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      buildTextFieldString(
                        label: 'Icon of Car',
                        controller: carIconController,
                        onSaved: (value) => userProvider.carIcon = value!,
                      ),
                      buildTextFieldString(
                        label: 'Model of Car',
                        controller: carModelController,
                        onSaved: (value) => userProvider.carModel = value!,
                      ),
                      buildTextFieldString(
                        label: 'Color of Car',
                        controller: carColorController,
                        onSaved: (value) => userProvider.carColor = value!,
                      ),
                      buildDateField(
                        label: 'Year of Car Production',
                        controller: carYearController,
                        context: context,
                        onSaved: (value) => userProvider.carYear = value!,
                      ),
                      buildTextFieldString(
                        label: 'Plate of Car',
                        controller:carPlateController,
                        onSaved: (value) => userProvider.carPlate = value!,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: buildNextButton(() async {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            final userProvider = Provider.of<DriverProvider>(context, listen: false);
            if (userProvider.carImagePath == null ||
                userProvider.carLicense == null ||
                userProvider.backCarLicense == null) {
              errorMessage(context, 'Please pick all images');
              return;}
            CollectionReference drivers =
                FirebaseFirestore.instance.collection('drivers');
            User? user = FirebaseAuth.instance.currentUser;
            await StoreUserType.saveLastSignIn('driver');
            await StoreUserType.saveDriver(true);
            var doc = await drivers.add({
              'name': userProvider.name,
              'email':user?.email,
              'rate': 4.5,
            });
            await StoreUserType.saveDriverDocId(doc.id);
            if(!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              DriverHome.routeName
              , (route) => false
            );
          }
        }),
      ),
      onWillPop: () async {
        if (formKey.currentState != null) {
          formKey.currentState!.save();
        }
        return true;
      },
    );
  }
}
