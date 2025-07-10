import 'package:dirver/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_provider.dart';
import 'package:dirver/features/driver/presentation/views/second_screen.dart';
import 'package:dirver/features/driver/presentation/views/widgets/next_button_info.dart';
import 'package:dirver/features/driver/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver/presentation/views/widgets/text_field_widger.dart';

class DriverInfoView1 extends StatefulWidget {
  DriverInfoView1({super.key});
  static const String routeName = '/driver_info_view1';

  @override
  State<DriverInfoView1> createState() => _DriverInfoView1State();
}

class _DriverInfoView1State extends State<DriverInfoView1> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController birthDateController;
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<DriverProvider>(context, listen: false);
    birthDateController = TextEditingController(text: userProvider.birthDate ?? '');
    nameController = TextEditingController(text: userProvider.name ?? '');
  }

  @override
  void dispose() {
    birthDateController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<DriverProvider>(context);
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Informations', style: TextStyle()),
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
                      PickPicture(
                          text: 'Personal Image',
                          id: '11',
                          imagePath: userProvider.profileImagePath),
                      const SizedBox(height: 40),
                      buildTextFieldString(
                        label: 'Name',
                        controller: nameController,
                        onSaved: (value) => userProvider.setName(value!),
                      ),
                      buildDateField(
                        label: 'Birth Date',
                        controller: birthDateController,
                        context: context,
                        onSaved: (value) => userProvider.setBirthDate(value!),
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
            var provider = Provider.of<DriverProvider>(context, listen: false);
            if (provider.profileImagePath == null) {
              errorMessage(context, 'Please pick a image');
              return;
            }
            Navigator.of(context).pushNamed(
              DriverInfoView2.routeName,
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
