import 'dart:io';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/driver/presentation/provider/driver_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PickPicture extends StatelessWidget {
  final String id;
  final String text;
  final String? imagePath;
  const PickPicture({super.key, required this.text,required this.imagePath, required this.id});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>( // ✅ Listens for changes
      builder: (context, driverProvider, child) {
        return GestureDetector(
          onTap: () {
            _showImagePicker(context, driverProvider);
          },
          child: Column(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryColor, // ✅ Change border color here
                    width: 3, // Border width
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.greyColor,
                  image: imagePath != null
                      ? DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover, // Adjust image fit
                  )
                      : null, // Don't set image if profileImagePath is null
                ),
                child: Center(
                  child: imagePath== null?Icon(Icons.add):null
                ),
              ),
              Text(text),
            ],
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context,DriverProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("التقاط صورة"),
                onTap: () {
                  _pickImage(provider, ImageSource.camera,context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("اختيار من المعرض"),
                onTap: () {
                  _pickImage(provider, ImageSource.gallery,context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(DriverProvider provider, ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if(!context.mounted) return;
      if(id =='11') {
        provider.setProfileImagePath(pickedFile.path);
      }      else if(id == '21') {
        provider.setFrontLicenseImagePath(pickedFile.path);
      }      else if(id == '22') {
        provider.setBackLicenseImagePath(pickedFile.path);
      }      else if(id == '23') {
        provider.setSelfieImageWithLicense(pickedFile.path);
      }      else if(id=='31') {
        provider.setIDImagePath(pickedFile.path);
      }      else if(id =='32') {
        provider.setBackIDImagePath(pickedFile.path);
      }      else if(id == '33') {
        provider.setFeshPath(pickedFile.path);
      }      else if(id == '41') {
        provider.setCarImagePath(pickedFile.path);
      }      else if(id == '42') {
        provider.setLicensePlateImage(pickedFile.path);
      }      else if(id == '43') {
        provider.setBackLicensePlateImage(pickedFile.path);
      }}

    // Close bottom sheet
    if(!context.mounted) return;
    Navigator.of(context).pop();
  }
}
