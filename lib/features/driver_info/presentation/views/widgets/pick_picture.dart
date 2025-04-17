import 'dart:io';
import 'package:dirver/features/driver_info/presentation/provider/driver_provider.dart';
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
    return GestureDetector(
      onTap: () {
        _showImagePicker(context);
      },
      child: Consumer<DriverProvider>( // ✅ Listens for changes
        builder: (context, driverProvider, child) {
          return Column(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0XFF661AFD), // ✅ Change border color here
                    width: 3, // Border width
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey,
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
          );
        },
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
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
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("اختيار من المعرض"),
                onTap: () {
                  _pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      var provider = Provider.of<DriverProvider>(context, listen: false);
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
      }    }

    // Close bottom sheet
    Navigator.of(context).pop();
  }
}
