import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/primary_button.dart';
import '../../models/city_location.dart';
import '../../services/location_service.dart';

/// Interactive Street-Level Map Picker for Pakistan.
/// Automatically detects device location upon opening, centers on user's coordinates,
/// and allows fine-tuning with manual pin placement or city corridor selection.
class AppMapPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialCityId;
  final bool autoDetectOnOpen;
  final void Function(LatLng location, String addressDescription)?
  onLocationConfirmed;

  const AppMapPicker({
    super.key,
    this.initialLocation,
    this.initialCityId,
    this.autoDetectOnOpen = true,
    this.onLocationConfirmed,
  });

  @override
  State<AppMapPicker> createState() => _AppMapPickerState();
}

class _AppMapPickerState extends State<AppMapPicker> {
  late final MapController _mapController;
  final LocationService _locationService = LocationService();
  late CityLocation _selectedCity;
  late LatLng _currentPin;
  LatLng? _detectedGpsCoords;
  String _addressDetails = '';
  bool _isAutoLocating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.initialCityId != null) {
      _selectedCity = CorridorCities.findById(widget.initialCityId!);
    } else {
      _selectedCity = _locationService.selectedCity;
    }

    _currentPin =
        widget.initialLocation ??
        _locationService.deviceGpsLocation ??
        _selectedCity.center;
    _detectedGpsCoords = _locationService.deviceGpsLocation;
    _addressDetails = _locationService.streetAddress.isNotEmpty
        ? _locationService.streetAddress
        : '${_selectedCity.popularAreas.first}, ${_selectedCity.name}';

    if (widget.autoDetectOnOpen && widget.initialLocation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _detectAndCenterLocation();
      });
    }
  }

  Future<void> _detectAndCenterLocation() async {
    if (!mounted) return;
    setState(() => _isAutoLocating = true);

    final success = await _locationService.autoDetectLocation();
    if (!mounted) return;

    if (success && _locationService.deviceGpsLocation != null) {
      final gpsPoint = _locationService.deviceGpsLocation!;
      setState(() {
        _detectedGpsCoords = gpsPoint;
        _currentPin = gpsPoint;
        _selectedCity = _locationService.selectedCity;
        _addressDetails = _locationService.streetAddress;
        _isAutoLocating = false;
      });
      _mapController.move(gpsPoint, 15.0);
    } else {
      setState(() {
        _isAutoLocating = false;
      });
    }
  }

  void _onCitySelected(CityLocation city) {
    setState(() {
      _selectedCity = city;
      _currentPin = city.center;
      _addressDetails =
          '${city.popularAreas.isNotEmpty ? city.popularAreas.first : 'Center'}, ${city.name}';
    });
    _locationService.selectCity(city);
    _mapController.move(city.center, city.defaultZoom);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    final nearest = CorridorCities.findClosestCity(point);
    setState(() {
      _currentPin = point;
      _selectedCity = nearest;
      _addressDetails =
          '${nearest.name} • ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
    });
    _locationService.setManualPin(point, customAddress: _addressDetails);
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
        // 1. Auto-Detection Status & City Corridor Selector
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auto-detection status badge
              Row(
                children: [
                  if (_isAutoLocating) ...[
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Detecting your GPS location in Pakistan...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else if (_locationService.isAutoDetected) ...[
                    const Icon(
                      Icons.gps_fixed_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'GPS Location Detected: ${_selectedCity.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.location_city_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Select City Corridor or Tap "Auto-Detect":',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Horizontal City selector chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: CorridorCities.all.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
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

              // Popular Area chips for selected city
              if (_selectedCity.popularAreas.isNotEmpty) ...[
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
                                _addressDetails =
                                    '$area, ${_selectedCity.name}';
                              });
                              _locationService.selectCity(
                                _selectedCity,
                                customArea: area,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // 2. Interactive Map View with OpenStreetMap Tiles & GPS Marker
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPin,
                  initialZoom: _selectedCity.defaultZoom,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kaamhub.kaamhub',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      // Active Selected Service Pin
                      Marker(
                        point: _currentPin,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                      // If GPS detected, show blue/emerald user dot
                      if (_detectedGpsCoords != null)
                        Marker(
                          point: _detectedGpsCoords!,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.info.withAlpha(100),
                                  blurRadius: 8,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Zoom Controls & GPS Auto-Locate Button
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
                    FloatingActionButton(
                      heroTag: 'map_auto_detect_btn',
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      onPressed: _detectAndCenterLocation,
                      tooltip: 'Auto-detect location in Pakistan',
                      child: _isAutoLocating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.my_location_rounded),
                    ),
                  ],
                ),
              ),

              // Map instruction badge
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
                        'Tap map to fine-tune pin',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _addressDetails,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (_locationService.isAutoDetected)
                            const Text(
                              '✓ Auto-detected via GPS',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
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
