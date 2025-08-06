import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StoreProposedTrips {
  static const String _storageKey = 'proposedTrips';

  /// Load the Map<String, String> from SharedPreferences
  static Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded != null) {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } else {
      return {};
    }
  }

  /// Save the Map<String, String> to SharedPreferences
  static Future<void> save(Map<String, String> proposedTrips) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(proposedTrips);
    await prefs.setString(_storageKey, encoded);
  }

  /// Add or update a single trip proposal and save
  static Future<void> addProposal(String tripId, String price) async {
    final proposedTrips = await load();
    proposedTrips[tripId] = price;
    await save(proposedTrips);
  }

  /// Remove a single trip proposal and save
  static Future<void> removeProposal(String tripId) async {
    final proposedTrips = await load();
    proposedTrips.remove(tripId);
    await save(proposedTrips);
  }

  /// Clear all proposals
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
