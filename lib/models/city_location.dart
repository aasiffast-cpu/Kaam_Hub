import 'package:latlong2/latlong.dart';

/// Represents a city, town, or area along the Sahiwal to Lahore corridor.
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
}

/// Sahiwal to Lahore corridor cities, towns, and popular areas with street-level coordinates.
class CorridorCities {
  CorridorCities._();

  static const List<CityLocation> all = [
    // 1. Sahiwal
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
        'G.T. Road By-pass',
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

    // 6. Pattoki
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
        'Habibabad',
      ],
    ),

    // 7. Phool Nagar (Bhai Pheru)
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
        'Adda Bhai Pheru',
      ],
    ),

    // 8. Manga Mandi
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

    // 9. Chung & Mohlanwal
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

    // 10. Lahore
    CityLocation(
      id: 'lahore',
      name: 'Lahore',
      district: 'Lahore',
      center: LatLng(31.5204, 74.3587),
      defaultZoom: 13.0,
      popularAreas: [
        'Thokar Niaz Baig',
        'Johar Town',
        'Gulberg (I, II, III)',
        'DHA (Phase 1 to 9)',
        'Model Town',
        'Bahria Town Lahore',
        'Allama Iqbal Town',
        'Faisal Town',
        'Wapda Town',
        'Walled City & Anarkali',
      ],
    ),
  ];

  static CityLocation get defaultCity => all.first; // Sahiwal by default

  static CityLocation findById(String id) {
    return all.firstWhere((c) => c.id == id, orElse: () => defaultCity);
  }
}
