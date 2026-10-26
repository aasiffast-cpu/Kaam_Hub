import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Represents a city, town, or area in Pakistan.
class CityLocation {
  final String id;
  final String name;
  final String district;
  final LatLng center;
  final double defaultZoom;
  final List<String> popularAreas;

  const CityLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.center,
    this.defaultZoom = 13.5,
    required this.popularAreas,
  });

  /// Computes approximate straight-line distance in kilometers from this city's center.
  double distanceTo(LatLng point) {
    const double earthRadiusKm = 6371.0;
    final dLat = (point.latitude - center.latitude) * math.pi / 180.0;
    final dLon = (point.longitude - center.longitude) * math.pi / 180.0;

    final lat1 = center.latitude * math.pi / 180.0;
    final lat2 = point.latitude * math.pi / 180.0;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1) *
            math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}

/// Sahiwal to Lahore corridor cities, plus candidate pilot cities across Pakistan.
class CorridorCities {
  CorridorCities._();

  static const List<CityLocation> all = [
    // 1. Sahiwal (Pilot Hub)
    CityLocation(
      id: 'sahiwal',
      name: 'Sahiwal',
      district: 'Sahiwal',
      center: LatLng(30.6682, 73.1114),
      defaultZoom: 14.0,
      popularAreas: [
        'Farid Town',
        'Fateh Sher Colony',
        'High Street',
        'Tariq Bin Ziad Colony',
        'Scheme No. 2',
        'Civil Lines',
        'Sahiwal Bypass',
      ],
    ),

    // 2. Chichawatni
    CityLocation(
      id: 'chichawatni',
      name: 'Chichawatni',
      district: 'Sahiwal',
      center: LatLng(30.5333, 72.7000),
      defaultZoom: 14.0,
      popularAreas: [
        'Main Bazaar',
        'Block 1 to 12',
        'Railway Road',
        'Bypass Chowk',
      ],
    ),

    // 3. Harappa
    CityLocation(
      id: 'harappa',
      name: 'Harappa',
      district: 'Sahiwal',
      center: LatLng(30.6300, 72.8647),
      defaultZoom: 14.0,
      popularAreas: ['Harappa City', 'Station Road', 'Museum Area'],
    ),

    // 4. Okara
    CityLocation(
      id: 'okara',
      name: 'Okara',
      district: 'Okara',
      center: LatLng(30.8081, 73.4458),
      defaultZoom: 14.0,
      popularAreas: [
        'Depalpur Chowk',
        'Kachehri Bazaar',
        'Mandi Road',
        'Faisalabad Road',
        'Ravi Road',
        'Housing Colony 1 & 2',
      ],
    ),

    // 5. Renala Khurd
    CityLocation(
      id: 'renala_khurd',
      name: 'Renala Khurd',
      district: 'Okara',
      center: LatLng(30.8833, 73.5972),
      defaultZoom: 14.5,
      popularAreas: [
        'G.T. Road Main',
        'Canal Colony',
        'GPO Chowk',
        'Railway Road',
      ],
    ),

    // 6. Depalpur
    CityLocation(
      id: 'depalpur',
      name: 'Depalpur',
      district: 'Okara',
      center: LatLng(30.6706, 73.6533),
      defaultZoom: 14.0,
      popularAreas: [
        'Kachehri Road',
        'Hujra Road',
        'Model Town Depalpur',
        'Main Market',
      ],
    ),

    // 7. Pakpattan
    CityLocation(
      id: 'pakpattan',
      name: 'Pakpattan',
      district: 'Pakpattan',
      center: LatLng(30.3410, 73.3867),
      defaultZoom: 14.0,
      popularAreas: [
        'Faridkot Road',
        'Shrine Complex Area',
        'City Center',
        'College Road',
      ],
    ),

    // 8. Arifwala
    CityLocation(
      id: 'arifwala',
      name: 'Arifwala',
      district: 'Pakpattan',
      center: LatLng(30.2917, 73.0644),
      defaultZoom: 14.0,
      popularAreas: [
        'Thana Road',
        'College Road',
        'Block B',
        'Railway Road',
      ],
    ),

    // 9. Pattoki
    CityLocation(
      id: 'pattoki',
      name: 'Pattoki',
      district: 'Kasur',
      center: LatLng(31.0214, 73.8472),
      defaultZoom: 14.0,
      popularAreas: [
        'Allama Iqbal Road',
        'Multan Road Bypass',
        'Nursery Market Area',
        'Main Bazaar',
      ],
    ),

    // 10. Phool Nagar (Bhai Pheru)
    CityLocation(
      id: 'phool_nagar',
      name: 'Phool Nagar (Bhai Pheru)',
      district: 'Kasur',
      center: LatLng(31.1394, 73.9653),
      defaultZoom: 14.0,
      popularAreas: [
        'Main Multan Road',
        'Din Garh',
        'Chowk Phool Nagar',
      ],
    ),

    // 11. Manga Mandi
    CityLocation(
      id: 'manga_mandi',
      name: 'Manga Mandi',
      district: 'Lahore',
      center: LatLng(31.3061, 74.0706),
      defaultZoom: 14.5,
      popularAreas: [
        'Multan Road Bypass',
        'Main Adda',
        'Raiwind Road Junction',
      ],
    ),

    // 12. Chung & Mohlanwal
    CityLocation(
      id: 'chung',
      name: 'Chung / Mohlanwal',
      district: 'Lahore',
      center: LatLng(31.4089, 74.1750),
      defaultZoom: 14.0,
      popularAreas: [
        'Chung Main Bazaar',
        'Mohlanwal Road',
        'Multan Road Corridor',
      ],
    ),

    // 13. Lahore (Provincial Hub)
    CityLocation(
      id: 'lahore',
      name: 'Lahore',
      district: 'Lahore',
      center: LatLng(31.5204, 74.3587),
      defaultZoom: 13.0,
      popularAreas: [
        'Gulberg (I, II, III)',
        'DHA (Phase 1 to 9)',
        'Johar Town',
        'Model Town',
        'Faisal Town',
        'Bahria Town Lahore',
        'Thokar Niaz Baig',
        'Wapda Town',
        'Allama Iqbal Town',
        'Walled City & Anarkali',
      ],
    ),

    // 14. Faisalabad
    CityLocation(
      id: 'faisalabad',
      name: 'Faisalabad',
      district: 'Faisalabad',
      center: LatLng(31.4504, 73.1350),
      defaultZoom: 13.0,
      popularAreas: [
        'Clock Tower Bazaar',
        'D Ground Peoples Colony',
        'Madina Town',
        'Jaranwala Road',
        'Susan Road',
      ],
    ),

    // 15. Multan
    CityLocation(
      id: 'multan',
      name: 'Multan',
      district: 'Multan',
      center: LatLng(30.1575, 71.5249),
      defaultZoom: 13.0,
      popularAreas: [
        'Cantt Area',
        'Bosan Road',
        'Gulgasht Colony',
        'Shah Rukn-e-Alam',
      ],
    ),

    // 16. Islamabad & Rawalpindi
    CityLocation(
      id: 'islamabad',
      name: 'Islamabad / Rawalpindi',
      district: 'Islamabad',
      center: LatLng(33.6844, 73.0479),
      defaultZoom: 13.0,
      popularAreas: [
        'Blue Area',
        'F-6 / F-7 / F-8',
        'G-9 / G-10 / G-11',
        'Bahria Town Rawalpindi',
        'Saddar Rawalpindi',
      ],
    ),

    // 17. Karachi
    CityLocation(
      id: 'karachi',
      name: 'Karachi',
      district: 'Karachi',
      center: LatLng(24.8607, 67.0011),
      defaultZoom: 12.5,
      popularAreas: [
        'Clifton',
        'DHA Karachi',
        'Gulshan-e-Iqbal',
        'North Nazimabad',
        'PECHS',
      ],
    ),
  ];

  static CityLocation get defaultCity => all.first; // Sahiwal by default

  static CityLocation findById(String id) {
    return all.firstWhere((c) => c.id == id, orElse: () => defaultCity);
  }

  /// Finds the closest Pakistan city based on coordinates.
  static CityLocation findClosestCity(LatLng coords) {
    CityLocation closest = all.first;
    double minDistance = double.infinity;

    for (final city in all) {
      final distance = city.distanceTo(coords);
      if (distance < minDistance) {
        minDistance = distance;
        closest = city;
      }
    }
    return closest;
  }
}
