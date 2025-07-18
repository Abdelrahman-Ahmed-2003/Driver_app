
  import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> searchAboutUserOnline({
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
        return result.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

