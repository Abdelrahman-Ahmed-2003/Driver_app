import 'package:flutter/material.dart';

class DriverProvider extends ChangeNotifier {
  String name = "";
  String birthDate = "";
  String? profileImagePath;
  String? frontLicenseDrivingImagePath;
  String? backLicenseDrivingImagePath;
  String selfieImageWithLicense = "";
  String numberOfLicense = "";
  String expirationDate = "";
  String IDImagePath = "";
  String backIDImagePath = "";
  String feshPath = "";
  String ID = '';
  String carLicense = "";
  String backCarLicense = "";
  String carModel = "";
  String carIcon = "";
  String carColor = "";
  String carYear = "";
  String carPlate = "";
  String carImagePath = "";

  // Setters for Text Fields
  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setBirthDate(String value) {
    birthDate = value;
    notifyListeners();
  }

  // ✅ Setters for Each Image Attribute
  void setProfileImagePath(String value) {
    profileImagePath = value;
    notifyListeners();
  }

  void setFrontLicenseImagePath(String value) {
    frontLicenseDrivingImagePath = value;
    notifyListeners();
  }

  void setBackLicenseImagePath(String value) {
    backLicenseDrivingImagePath = value;
    notifyListeners();
  }

  void setSelfieImageWithLicense(String value) {
    selfieImageWithLicense = value;
    notifyListeners();
  }

  void setIDImagePath(String value) {
    IDImagePath = value;
    notifyListeners();
  }

  void setBackIDImagePath(String value) {
    backIDImagePath = value;
    notifyListeners();
  }

  void setFeshPath(String value) {
    feshPath = value;
    notifyListeners();
  }

  void setLicensePlateImage(String value) {
    carLicense = value;
    notifyListeners();
  }

  void setBackLicensePlateImage(String value) {
    backCarLicense = value;
    notifyListeners();
  }

  void setCarImagePath(String value) {
    carImagePath = value;
    notifyListeners();
  }

  void setCarIcon(String value) {
    carIcon = value;
    notifyListeners();
  }

  void setCarColor(String value) {
    carColor = value;
    notifyListeners();
  }

  void setCarYear(String value) {
    carYear = value;
    notifyListeners();
  }

  void setCarPlate(String value) {
    carPlate = value;
    notifyListeners();
  }
}
