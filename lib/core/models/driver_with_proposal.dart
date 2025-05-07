import 'package:dirver/core/models/driver.dart';
import 'package:dirver/core/models/trip.dart';

class DriverWithProposal {
  final Driver driver;
  final DriverProposal proposal;

  DriverWithProposal({required this.driver, required this.proposal});
}
