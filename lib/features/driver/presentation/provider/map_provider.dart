import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location_package;
import 'package:http/http.dart' as http;

class MapProvider extends ChangeNotifier {
  bool isLoading = true;
  final Distance _distanceCalculator = Distance();
  final location_package.Location _location = location_package.Location();
  StreamSubscription<location_package.LocationData>? _locationSubscription;

  bool _canSearch = false;
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  bool get canSearch => _canSearch;

  String stringDestination = '';
  LatLng anotherLocation = const LatLng(0, 0);
  List<LatLng> _points = []; //to destination
  List<LatLng> _toUserPoints = [];
  List<LatLng> get toUserPoints => _toUserPoints;
  LatLng _destination = const LatLng(0, 0);
  LatLng get destination => _destination;
  List<LatLng> get points => _points;
  LatLng _passengerLocation = const LatLng(0, 0);
  LatLng _driverLocation = const LatLng(0, 0);
  LatLng get driverLocation => _driverLocation;
  LatLng get passengerLocation => _passengerLocation;

  set canSearch(bool value) {
    if (_canSearch == value) return; // Avoid unnecessary updates
    _canSearch = value;
    notifyListeners();
  }

  set isSearching(bool value) {
    if (_isSearching == value) return; // Avoid unnecessary updates
    _isSearching = value;
    notifyListeners();
  }

  set passengerLocation(LatLng location) {
    _passengerLocation = location;
    // notifyListeners(); // Notify listeners of the update
  }

  set driverLocation(LatLng location) {
    _driverLocation = location;
    // notifyListeners(); // Notify listeners of the update
  }

  set destination(LatLng location) {
    _destination = location;
    // notifyListeners(); // Notify listeners of the update
  }

  // List<LatLng> get currentPoints => _isToUserMode ? _toUserPoints : _points;

  Future<void> initialize3MarkersRoute() async {
    isLoading = true;
    notifyListeners();
    Position driverPosition = await Geolocator.getCurrentPosition();
    _driverLocation = LatLng(driverPosition.latitude, driverPosition.longitude);
    await fetchRoute(_driverLocation, _passengerLocation, 'toUser');
    isLoading = false;
    await setCurrentPoints(
      from: _passengerLocation,
    );
  }

  Future<void> pointsFromDriverToUser() async {
    await setCurrentPoints(
        from: _driverLocation, to: passengerLocation, type: 'toUser');
  }

  Future<void> pointsFromUserToDestination() async {
    await setCurrentPoints(from: _passengerLocation);
  }

  Future<void> pointsFromDriverToDestination() async {
    await setCurrentPoints(from: _driverLocation);
  }

  Future<void> setCurrentPoints(
      {LatLng from = const LatLng(0, 0),
      LatLng to = const LatLng(0, 0),
      
      String type = 'toDest'}) async {
        debugPrint('destination is in listen to notificaiton $_destination');
        if(_destination == const LatLng(0, 0)) return;
    if (to == const LatLng(0, 0)) {
      to = _destination;
    }

    await fetchRoute(from, to, type);
    notifyListeners();
  }

  /// Fetch route for any two points
  Future<void> fetchRoute(LatLng from, LatLng to, String type) async {
    try {
      debugPrint('fetchRoute called');
      debugPrint('from: $from, to: $to'  'type: $type');
      final url = Uri.parse(
        'https://routing.openstreetmap.de/routed-car/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=polyline&steps=true',
      );

      debugPrint('fetchRoute: $url');
      final response = await http.get(url);
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry'];
        debugPrint('geometry: $geometry');
        decodePolyline(geometry, type, from);
      } else {
        debugPrint('fetchRoute failed: HTTP ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('fetchRoute exception: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Decode polyline and set new route points based on type
  void decodePolyline(String geometry, String type, LatLng from) {
    final polylinePoints = PolylinePoints();
    final result = polylinePoints.decodePolyline(geometry);
    final List<LatLng> newPoints =
        result.map((e) => LatLng(e.latitude, e.longitude)).toList();

    setPoints(newPoints, type, from);
  }

  /// Set route points to the correct list (_points or _toUserPoints)
  void setPoints(List<LatLng> newPoints, String type, LatLng from) {
    if (type == 'toUser') {
      _toUserPoints = [from, ...newPoints];
      debugPrint('Updated _toUserPoints: ${_toUserPoints.length} points');
    } else {
      _points = [from, ...newPoints];
      debugPrint('Updated _points: ${_points.length} points');
    }
  }

  Future<void> listenLocation(bool isDriver) async {
    if (!await checkPermissions()) return;
    isLoading = true;
    notifyListeners();
    _locationSubscription =
        _location.onLocationChanged.listen((passengerLocation) async {
      if (passengerLocation.latitude != null &&
          passengerLocation.longitude != null) {
        final newLocation = LatLng(
          passengerLocation.latitude!,
          passengerLocation.longitude!,
        );

        if (shouldUpdateLocation(newLocation)) {
          if (isDriver) {
            _driverLocation = newLocation;
          } else {
            _passengerLocation = newLocation;
          }
          await setCurrentPoints(from: newLocation);
          debugPrint('Location updated: $newLocation');

          // mapProvider.setCurrentPoints(newLocation);
          // _lastUpdatedLocation = newLocation;
        }
      }
    });
    isLoading = false;
    notifyListeners();
  }

  bool shouldUpdateLocation(LatLng newLocation) {
    final distance = _distanceCalculator(_passengerLocation, newLocation);
    return distance > 5;
  }

  Future<bool> checkPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    final permissionStatus = await _location.requestPermission();
    return permissionStatus == location_package.PermissionStatus.granted;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void cancelLocationSubscription() {
    if (_locationSubscription == null) return;
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void clear() {
    _points.clear();
    _passengerLocation = const LatLng(0, 0);
    anotherLocation = const LatLng(0, 0);
    _destination = const LatLng(0, 0);
    _locationSubscription?.cancel();
    _locationSubscription = null;
    stringDestination = '';
    canSearch = true;
    isSearching = false;
    _points.clear();
    _destination = const LatLng(0, 0);
  }

  void clearSearch() {
    stringDestination = '';
    canSearch = true;
    isSearching = false;
    _points.clear();
    _destination = const LatLng(0, 0);
    notifyListeners();
  }
}
