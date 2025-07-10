import 'package:dirver/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_provider.dart';
import 'package:dirver/features/driver/presentation/views/third_screen.dart';
import 'package:dirver/features/driver/presentation/views/widgets/next_button_info.dart';
import 'package:dirver/features/driver/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver/presentation/views/widgets/text_field_widger.dart';

class DriverInfoView2 extends StatefulWidget {
  DriverInfoView2({super.key});
  static const String routeName = '/driver_info_view2';

  @override
  State<DriverInfoView2> createState() => _DriverInfoView2State();
}

class _DriverInfoView2State extends State<DriverInfoView2> {
  final formKey = GlobalKey<FormState>();
  late final MaskedTextController numberOfLicenseController;
  late final TextEditingController expirationDateController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<DriverProvider>(context, listen: false);
    numberOfLicenseController = MaskedTextController(mask: '0000 0000 000 000', text: userProvider.numberOfLicense ?? '');
    expirationDateController = TextEditingController(text: userProvider.expirationDate ?? '');
  }

  @override
  void dispose() {
    numberOfLicenseController.dispose();
    expirationDateController.dispose();
    super.dispose();
  }

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

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Car Licenses', style: TextStyle()),
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
                      buildTextFieldNumber(
                          label: 'Number of License',
                          controller: numberOfLicenseController,
                          onSaved: (value) => userProvider.numberOfLicense = value!),
                      buildDateField(
                        label: 'Expired Date of License',
                        controller: expirationDateController,
                        context: context,
                        onSaved: (value) => userProvider.expirationDate = value!,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
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
