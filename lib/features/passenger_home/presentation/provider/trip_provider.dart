// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:free_map/free_map.dart';
// import 'package:http/http.dart' as http;

// class TripProvider with ChangeNotifier {
//   TextEditingController toController = TextEditingController();
//   TextEditingController priceController = TextEditingController();

//   String _from = '';
//   LatLng _dest = LatLng(0, 0);
//   String _price = '';
//   List<LatLng> _points = [];

//   LatLng? currentLocation;
//   LatLng? lastDest;

//   // Getters
//   String get from => _from;
//   LatLng get dest => _dest;
//   String get price => _price;
//   List<LatLng> get points => _points;

//   // Setters
//   void setFrom(String value) {
//     if (_from != value) {
//       _from = value;
//       notifyListeners();
//     }
//   }

//   void setDest(LatLng value) {
//     if (_dest != value) {
//       _dest = value;
//       notifyListeners();
//     }
//   }

//   void setPrice(String value) {
//     if (_price != value) {
//       _price = value;
//       notifyListeners();
//     }
//   }

//   void updateCurrentLocation(LatLng newLocation) {
//     if (currentLocation == null ||
//         currentLocation!.latitude != newLocation.latitude ||
//         currentLocation!.longitude != newLocation.longitude) {
//       currentLocation = newLocation;
//       notifyListeners();
//     }
//   }

//   bool checkChange(LatLng currentLocation) {
//     if (_points.isEmpty) return true;
//     return (currentLocation.latitude - _points.last.latitude).abs() > 0.5 ||
//         (currentLocation.longitude - _points.last.longitude).abs() > 0.5;
//   }

//   Future<void> setCoordinatesPoint(LatLng location) async {
//     if (lastDest != location) {
//       lastDest = location;

//       setDest(location);
//       await fetchRoute();
//     }
//   }

//   Future<void> fetchRoute() async {
//     if (currentLocation == null || _dest == LatLng(0, 0)) return;

//     _points.clear(); // ✅ Clears previous points before fetching a new route

//     final url = Uri.parse(
//         'https://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${_dest.longitude},${_dest.latitude}?overview=full&geometries=polyline&steps=true');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final geometry = data['routes'][0]['geometry'];
//       _decodePolyline(geometry);
//     } else {
//       print('Error fetching route');
//     }
//   }

//   void _decodePolyline(String geometry) {
//     PolylinePoints polylinePoints = PolylinePoints();
//     List<PointLatLng> result = polylinePoints.decodePolyline(geometry);

//     setDestinations(result.map((e) => LatLng(e.latitude, e.longitude)).toList());
//   }

//   void setDestinations(List<LatLng> newPoints) {
//     if (currentLocation != null) {
//       _points = [currentLocation!, ...newPoints]; // ✅ Starts from current location
//     } else {
//       _points = newPoints; // Fallback if location is null
//     }
//     notifyListeners();
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:free_map/free_map.dart';

class TripProvider with ChangeNotifier {
  TextEditingController toController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String _from = '';
  LatLng _dest = LatLng(0, 0);
  String _price = '';
  List<LatLng> _points = [];
  LatLng? currentLocation;
  LatLng? lastDest;

  // Getters
  String get from => _from;
  LatLng get dest => _dest;
  String get price => _price;
  List<LatLng> get points => _points;

  // Setters
  void setFrom(String value) {
    _from = value;
    print('in setttttttttttttttttttttttttt');
    print(_from);
    notifyListeners();
  }

  bool checkChange(LatLng currentLocation) {
    if (_points.isEmpty) {
      return true;
    }
    if (_points.last.latitude - currentLocation.latitude > .5 &&
        _points.last.longitude - currentLocation.longitude > .5) {
      return true;
    }
    return false;
  }

  void setDest(LatLng value) {
    _dest = value;
    notifyListeners();
  }

  void setPrice(String value) {
    _price = value;
    // notifyListeners();
  }

  void setCurrentPoints(LatLng newPoints) async{
    if (_points.isEmpty) {
      _points.add(newPoints);
    } else {
      _points[0] = newPoints;
    }
    await updatePoints();
    notifyListeners();
  }

  void setDestinations(List<LatLng> newPoints) {
    if (currentLocation != null) {
      _points = [
        currentLocation!,
        ...newPoints
      ]; // ✅ Always starts from current location
    } else {
      _points = [...newPoints]; // Fallback if location is null
    }
    notifyListeners();
  }

  Future<void> setCoordinatesPoint(LatLng location) async {
    if (lastDest != location) {
      lastDest = location;
      setDest(location);
      await fetchRoute();
    }
  }

  Future<void> updatePoints() async {
    if (_dest != LatLng(0, 0)) {
      await fetchRoute();
    }
    // await fetchRoute();
  }

  // Future<void> _fetchRoute() async {
  //   if (currentLocation == null || dest == LatLng(0, 0)) return;
  //   final url = Uri.parse(
  //       'https://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${dest!.longitude},${dest!.latitude}?overview=full&geometries=polyline&steps=true');
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final geometry = data['routes'][0]['geometry'];
  //     _decodePolyline(geometry);
  //   } else {
  //     print('error in fetch route');
  //   }
  // }

  Future<void> fetchRoute() async {
    if (currentLocation == null || dest == LatLng(0, 0)) return;

    _points.clear(); // ✅ Clears previous points before fetching a new route

    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${dest.longitude},${dest.latitude}?overview=full&geometries=polyline&steps=true');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];

      // ✅ Reset polyline to only show from current location to destination
      _decodePolyline(geometry);
    } else {
      print('Error in fetch route');
    }
  }

  void _decodePolyline(String geometry) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(geometry);
    print('ressssssssssssssssssssssssssssult $result');
    setDestinations(
        result.map((e) => LatLng(e.latitude, e.longitude)).toList());
  }
}