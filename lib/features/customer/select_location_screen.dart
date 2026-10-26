import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/widgets/app_map_picker.dart';

/// Screen allowing customers to browse and select their street location on the map.
class SelectLocationScreen extends StatelessWidget {
  final String? initialCityId;
  final LatLng? initialLocation;

  const SelectLocationScreen({
    super.key,
    this.initialCityId,
    this.initialLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pakistan Service Map',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'Auto-detects location • Tap pin to confirm',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: AppMapPicker(
        initialCityId: initialCityId,
        initialLocation: initialLocation,
        onLocationConfirmed: (location, address) {
          Navigator.pop(context, {'location': location, 'address': address});
        },
      ),
    );
  }
}
