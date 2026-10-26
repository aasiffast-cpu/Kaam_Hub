import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/city_location.dart';

/// Central reactive location service for KaamHub.
/// Automatically detects user's GPS position in Pakistan, matches to nearest city/corridor,
/// and provides robust fallback for denied permissions or manual map selection.
class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  LocationService._internal() {
    _selectedCity = CorridorCities.defaultCity; // Sahiwal
    _currentPin = _selectedCity.center;
    _streetAddress = '${_selectedCity.popularAreas.first}, ${_selectedCity.name}';
  }

  late CityLocation _selectedCity;
  late LatLng _currentPin;
  LatLng? _deviceGpsLocation;
  String _streetAddress = '';
  bool _isDetecting = false;
  bool _isAutoDetected = false;
  String? _statusMessage;
  LocationPermission _permission = LocationPermission.denied;

  CityLocation get selectedCity => _selectedCity;
  LatLng get currentPin => _currentPin;
  LatLng? get deviceGpsLocation => _deviceGpsLocation;
  String get streetAddress => _streetAddress;
  bool get isDetecting => _isDetecting;
  bool get isAutoDetected => _isAutoDetected;
  String? get statusMessage => _statusMessage;
  LocationPermission get permission => _permission;

  /// Automatically detects device location via GPS and matches to the nearest Pakistan city/corridor.
  Future<bool> autoDetectLocation({bool requestIfDenied = true}) async {
    _isDetecting = true;
    _statusMessage = 'Detecting current location in Pakistan...';
    notifyListeners();

    try {
      // 1. Check if location services are enabled on the device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _statusMessage = 'Device GPS is turned off. Using corridor default.';
        _isDetecting = false;
        notifyListeners();
        return false;
      }

      // 2. Check and request location permissions
      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied && requestIfDenied) {
        _permission = await Geolocator.requestPermission();
      }

      if (_permission == LocationPermission.denied ||
          _permission == LocationPermission.deniedForever) {
        _statusMessage =
            'Location permission denied. You can manually pick your area on the map.';
        _isDetecting = false;
        notifyListeners();
        return false;
      }

      // 3. Get current position with balanced accuracy and timeout
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final LatLng deviceCoords = LatLng(position.latitude, position.longitude);
      _deviceGpsLocation = deviceCoords;

      // 4. Identify nearest Pakistan city and area
      final nearestCity = CorridorCities.findClosestCity(deviceCoords);
      _selectedCity = nearestCity;
      _currentPin = deviceCoords;
      _isAutoDetected = true;

      // Determine nearest area name if within city proximity
      final distanceToCityCenterKm = nearestCity.distanceTo(deviceCoords);
      if (distanceToCityCenterKm < 15.0 && nearestCity.popularAreas.isNotEmpty) {
        _streetAddress =
            '${nearestCity.popularAreas.first}, ${nearestCity.name}';
      } else {
        _streetAddress =
            '${nearestCity.name} (${deviceCoords.latitude.toStringAsFixed(4)}, ${deviceCoords.longitude.toStringAsFixed(4)})';
      }

      _statusMessage = 'Location detected: $_streetAddress';
      _isDetecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('KaamHub Location detection note: $e');
      _statusMessage =
          'Auto-detection unavailable. Defaulted to ${_selectedCity.name}.';
      _isDetecting = false;
      notifyListeners();
      return false;
    }
  }

  /// Manually selects a city from the corridor.
  void selectCity(CityLocation city, {String? customArea}) {
    _selectedCity = city;
    _currentPin = city.center;
    _isAutoDetected = false;
    _streetAddress = customArea != null
        ? '$customArea, ${city.name}'
        : '${city.popularAreas.isNotEmpty ? city.popularAreas.first : 'Center'}, ${city.name}';
    _statusMessage = 'Selected: $_streetAddress';
    notifyListeners();
  }

  /// Sets manual pin coordinates from map tapping.
  void setManualPin(LatLng point, {String? customAddress}) {
    _currentPin = point;
    final nearestCity = CorridorCities.findClosestCity(point);
    _selectedCity = nearestCity;
    _isAutoDetected = false;

    if (customAddress != null && customAddress.isNotEmpty) {
      _streetAddress = customAddress;
    } else {
      _streetAddress =
          '${nearestCity.name} • ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
    }
    _statusMessage = 'Pin placed: $_streetAddress';
    notifyListeners();
  }
}
