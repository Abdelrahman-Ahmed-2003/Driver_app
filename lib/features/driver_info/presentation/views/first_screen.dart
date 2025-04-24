import 'package:dirver/features/driver_info/presentation/provider/driver_provider.dart';
import 'package:dirver/features/driver_info/presentation/views/second_screen.dart';
import 'package:dirver/features/driver_info/presentation/views/widgets/next_button.dart';
import 'package:dirver/features/driver_info/presentation/views/widgets/pick_picture.dart';
import 'package:dirver/features/driver_info/presentation/views/widgets/text_field_widger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class DriverInfoView1 extends StatelessWidget {
  DriverInfoView1({super.key});
  static const String routeName = '/driver_info_view1';
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<DriverProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Informations', style: TextStyle()),
        // backgroundColor: Colors.black,
        
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PickPicture(text:'Personal Image', id: '11', imagePath:userProvider.profileImagePath),
                const SizedBox(height: 100),
                buildTextField(label: 'Name',onSaved: (value) => userProvider.setName(value!),),
                buildTextField(label: 'Birth Date', onSaved: (value) => userProvider.setBirthDate(value!)),
                // const Spacer(),
                SizedBox(height: MediaQuery.of(context).size.height*0.3),
        
                buildNextButton((){
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    Navigator.pushNamed(context, DriverInfoView2.routeName);
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
