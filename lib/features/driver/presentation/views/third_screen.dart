import 'package:dirver/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/views/widgets/next_button_info.dart';
import 'package:dirver/features/driver/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver/presentation/views/widgets/text_field_widger.dart';
import '../provider/driver_provider.dart';
import 'fourth_screen.dart';

class DriverInfoView3 extends StatefulWidget {
  DriverInfoView3({super.key});
  static const String routeName = '/driver_info_view3';

  @override
  State<DriverInfoView3> createState() => _DriverInfoView3State();
}

class _DriverInfoView3State extends State<DriverInfoView3> {
  final formKey = GlobalKey<FormState>();
  late final MaskedTextController idController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<DriverProvider>(context, listen: false);
    idController = MaskedTextController(mask: '0000 0000 000 000', text: userProvider.id ?? '');
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<DriverProvider>(context);
    // List of images for PickPicture (Handling null values safely)
    final List<Map<String, String?>> pickPictures = [
      {'text': 'ID', 'id': '31', 'imagePath': userProvider.idImagePath},
      {'text': 'Back ID', 'id': '32', 'imagePath': userProvider.backIDImagePath},
      {'text': 'El-Fesh', 'id': '33', 'imagePath': userProvider.feshPath},
    ];

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Folders', style: TextStyle()),
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
                        label: 'ID Number',
                        controller: idController,
                        onSaved: (value) => userProvider.id = value!,
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
