import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/primary_button.dart';
import '../../models/city_location.dart';

/// Interactive Street-Level Map Picker covering Sahiwal to Lahore corridor.
class AppMapPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialCityId;
  final void Function(LatLng location, String addressDescription)?
  onLocationConfirmed;

  const AppMapPicker({
    super.key,
    this.initialLocation,
    this.initialCityId,
    this.onLocationConfirmed,
  });

  @override
  State<AppMapPicker> createState() => _AppMapPickerState();
}

class _AppMapPickerState extends State<AppMapPicker> {
  late final MapController _mapController;
  late CityLocation _selectedCity;
  late LatLng _currentPin;
  String _addressDetails = '';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.initialCityId != null) {
      _selectedCity = CorridorCities.findById(widget.initialCityId!);
    } else {
      _selectedCity = CorridorCities.defaultCity; // Sahiwal
    }

    _currentPin = widget.initialLocation ?? _selectedCity.center;
    _addressDetails = '${_selectedCity.name}, Main Road / Street';
  }

  void _onCitySelected(CityLocation city) {
    setState(() {
      _selectedCity = city;
      _currentPin = city.center;
      _addressDetails = '${city.name}, Central Area';
    });
    _mapController.move(city.center, city.defaultZoom);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _currentPin = point;
      _addressDetails =
          '${_selectedCity.name} • Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
    });
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_currentPin, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_currentPin, currentZoom - 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. City Corridor Selector (Sahiwal to Lahore)
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.route_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Corridor (Sahiwal ➔ Okara ➔ Pattoki ➔ Lahore):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: CorridorCities.all.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final city = CorridorCities.all[index];
                    final isSelected = city.id == _selectedCity.id;
                    return ChoiceChip(
                      label: Text(city.name),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      onSelected: (_) => _onCitySelected(city),
                    );
                  },
                ),
              ),
              // Popular Sector / Street chips for selected city
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Popular Areas: ',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    ..._selectedCity.popularAreas.map(
                      (area) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          label: Text(
                            area,
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () {
                            setState(() {
                              _addressDetails = '$area, ${_selectedCity.name}';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Interactive Map View with OpenStreetMap Tiles
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPin,
                  initialZoom: _selectedCity.defaultZoom,
                  minZoom: 6.0,
                  maxZoom: 18.0,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kaamhub.kaamhub',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPin,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.error,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Zoom In / Out Floating Controls
              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'map_zoom_in',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: _zoomIn,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'map_zoom_out',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: _zoomOut,
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'map_reset_center',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      onPressed: () {
                        _mapController.move(
                          _selectedCity.center,
                          _selectedCity.defaultZoom,
                        );
                      },
                      child: const Icon(Icons.my_location_rounded),
                    ),
                  ],
                ),
              ),

              // Help badge
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tap on map to set street pin',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Bottom Address Preview & Confirmation
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppConstants.spaceS),
                    Expanded(
                      child: Text(
                        _addressDetails,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceM),
                PrimaryButton(
                  text: 'Confirm Service Location',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () {
                    widget.onLocationConfirmed?.call(
                      _currentPin,
                      _addressDetails,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
