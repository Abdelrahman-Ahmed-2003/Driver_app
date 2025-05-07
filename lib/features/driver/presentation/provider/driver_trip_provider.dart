import 'package:dirver/core/sharedProvider/trip_provider.dart';
class DriverTripProvider extends TripProvider {
  Future<void> acceptTrip(String tripId, String driverEmail) async {
    currentDocumentTrip = firestore.collection('trips').doc(tripId);
    await currentDocumentTrip!.update({
      'selectedDriver': driverEmail,
      'driverDistination': 'toUser',
      'status': 'accepted',
    });
  }

  Future<void> updateTripStatus(String newStatus) async {
    if (currentDocumentTrip != null) {
      await currentDocumentTrip!.update({'status': newStatus});
    }
  }
}
