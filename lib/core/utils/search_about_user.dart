
  import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool?> searchAboutUserOnline({
    required String type, // "drivers" or "passengers"
    required String email,
  }) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final result = await firestore
          .collection(type)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return null;
    }
  }

