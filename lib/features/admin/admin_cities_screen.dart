import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/category_model.dart';
import '../../services/mock_category_service.dart';

/// Admin screen for managing cities and their enabled/disabled status.
class AdminCitiesScreen extends StatefulWidget {
  const AdminCitiesScreen({super.key});

  @override
  State<AdminCitiesScreen> createState() => _AdminCitiesScreenState();
}

class _AdminCitiesScreenState extends State<AdminCitiesScreen> {
  final MockCategoryService _service = MockCategoryService();
  List<CityModel> _cities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => _isLoading = true);
    final cities = await _service.getAllCities();
    if (mounted) {
      setState(() {
        _cities = cities;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCity(CityModel city) async {
    await _service.toggleCity(city.id, !city.isEnabled);
    _loadCities();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            city.isEnabled ? AppColors.warning : AppColors.success,
        content: Text(
          city.isEnabled
              ? '${city.name} disabled. Workers from this city will be hidden.'
              : '${city.name} enabled. Workers from this city are now visible.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabledCount = _cities.where((c) => c.isEnabled).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cities & Areas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadCities,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary banner
                Container(
                  margin: AppConstants.paddingScreen,
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                        color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city_rounded,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$enabledCount / ${_cities.length} Cities Active',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                          const Text(
                            'Toggle cities to control service availability.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM),
                    itemCount: _cities.length,
                    separatorBuilder: (_, r) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: city.isEnabled
                              ? AppColors.surface
                              : AppColors.background,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: city.isEnabled
                                ? AppColors.cardBorder
                                : AppColors.cardBorder.withAlpha(100),
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: city.isEnabled
                                  ? AppColors.primary.withAlpha(20)
                                  : AppColors.cardBorder,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.location_on_rounded,
                                color: city.isEnabled
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 22),
                          ),
                          title: Row(
                            children: [
                              Text(city.name,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: city.isEnabled
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted)),
                              const SizedBox(width: 8),
                              if (city.nameUrdu.isNotEmpty)
                                Text(city.nameUrdu,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                            ],
                          ),
                          subtitle: city.areas.isNotEmpty
                              ? Text(
                                  '${city.areas.length} areas: ${city.areas.take(3).join(', ')}${city.areas.length > 3 ? '...' : ''}',
                                  style: const TextStyle(fontSize: 12),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: city.isEnabled
                                      ? AppColors.badgeApprovedBg
                                      : AppColors.badgeRejectedBg,
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusFull),
                                ),
                                child: Text(
                                  city.isEnabled ? 'LIVE' : 'OFF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: city.isEnabled
                                        ? AppColors.badgeApprovedText
                                        : AppColors.badgeRejectedText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: city.isEnabled,
                                onChanged: (_) => _toggleCity(city),
                                activeThumbColor: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(AppConstants.spaceM),
                  child: Text(
                    '⚠️ Disabling a city hides all workers from that city and prevents new bookings.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
