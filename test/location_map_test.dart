import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:kaamhub/core/widgets/app_map_picker.dart';
import 'package:kaamhub/models/city_location.dart';
import 'package:kaamhub/services/location_service.dart';

void main() {
  setUp(() {
    final service = LocationService();
    final sahiwal = CorridorCities.findById('sahiwal');
    service.selectCity(sahiwal, customArea: 'Farid Town');
  });

  group('Pakistan Geolocation & Corridor Matching Tests', () {
    test('CorridorCities matches coordinates to the closest Pakistani city', () {
      // 1. Lahore coordinates
      final lahoreCoords = const LatLng(31.5204, 74.3587);
      final closestLahore = CorridorCities.findClosestCity(lahoreCoords);
      expect(closestLahore.id, 'lahore');
      expect(closestLahore.name, 'Lahore');

      // 2. Sahiwal coordinates
      final sahiwalCoords = const LatLng(30.6682, 73.1114);
      final closestSahiwal = CorridorCities.findClosestCity(sahiwalCoords);
      expect(closestSahiwal.id, 'sahiwal');
      expect(closestSahiwal.name, 'Sahiwal');

      // 3. Okara coordinates
      final okaraCoords = const LatLng(30.8081, 73.4458);
      final closestOkara = CorridorCities.findClosestCity(okaraCoords);
      expect(closestOkara.id, 'okara');

      // 4. Faisalabad coordinates
      final fsdCoords = const LatLng(31.4504, 73.1350);
      final closestFsd = CorridorCities.findClosestCity(fsdCoords);
      expect(closestFsd.id, 'faisalabad');
    });

    test('LocationService manual pin & city selection updates address reactively', () {
      final service = LocationService();

      // Test city selection
      final okara = CorridorCities.findById('okara');
      service.selectCity(okara, customArea: 'Depalpur Chowk');
      expect(service.selectedCity.id, 'okara');
      expect(service.streetAddress, 'Depalpur Chowk, Okara');

      // Test manual pin placement near Lahore
      service.setManualPin(const LatLng(31.53, 74.36), customAddress: 'Gulberg III, Lahore');
      expect(service.streetAddress, 'Gulberg III, Lahore');
      expect(service.selectedCity.id, 'lahore');
    });
  });

  group('Interactive AppMapPicker Widget Tests', () {
    testWidgets('AppMapPicker renders corridor chips, auto-detect button, and confirm CTA', (
      WidgetTester tester,
    ) async {
      final service = LocationService();
      final sahiwal = CorridorCities.findById('sahiwal');
      service.selectCity(sahiwal, customArea: 'Farid Town');

      LatLng? confirmedPoint;
      String? confirmedAddress;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppMapPicker(
              initialCityId: 'sahiwal',
              autoDetectOnOpen: false, // disable async GPS trigger during widget test
              onLocationConfirmed: (point, address) {
                confirmedPoint = point;
                confirmedAddress = address;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify city choices & controls exist in initial viewport
      expect(find.text('Sahiwal'), findsWidgets);
      expect(find.text('Okara'), findsOneWidget);
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
      expect(find.text('Confirm Service Location'), findsOneWidget);

      // 2. Tap Confirm Service Location
      await tester.tap(find.text('Confirm Service Location'));
      await tester.pumpAndSettle();

      expect(confirmedPoint, isNotNull);
      expect(confirmedAddress, isNotNull);
      expect(confirmedAddress, contains('Sahiwal'));
    });
  });
}
