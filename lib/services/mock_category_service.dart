import '../models/category_model.dart';

/// Mock service providing pre-seeded categories and cities for KaamHub MVP.
/// Replace with Firestore implementation for production.
class MockCategoryService {
  static final MockCategoryService _instance = MockCategoryService._internal();
  factory MockCategoryService() => _instance;
  MockCategoryService._internal();

  final List<CategoryModel> _categories = [
    CategoryModel(
      id: 'cat_plumber',
      name: 'Plumber',
      nameUrdu: 'پلمبر',
      description: 'Pipe fitting, leakage repair, bathroom fixtures, water pump',
      iconName: 'plumbing',
      isEnabled: true,
      sortOrder: 1,
      subCategories: [
        'Pipe Repair',
        'Tap Fitting',
        'Water Pump',
        'Bathroom Fixtures',
        'Drain Cleaning',
      ],
    ),
    CategoryModel(
      id: 'cat_electrician',
      name: 'Electrician',
      nameUrdu: 'الیکٹریشن',
      description: 'Wiring, UPS, fans, AC installation, fuse box',
      iconName: 'bolt',
      isEnabled: true,
      sortOrder: 2,
      subCategories: [
        'House Wiring',
        'UPS & Inverter',
        'Fan Installation',
        'AC Service',
        'Switch & Socket',
      ],
    ),
    CategoryModel(
      id: 'cat_mistri',
      name: 'Mistri / Mason',
      nameUrdu: 'مستری',
      description: 'Construction, tile work, plastering, wall repair',
      iconName: 'foundation',
      isEnabled: true,
      sortOrder: 3,
      subCategories: [
        'Tile Fixing',
        'Plastering',
        'Wall Repair',
        'Roof Work',
        'Flooring',
      ],
    ),
    CategoryModel(
      id: 'cat_car_washer',
      name: 'Car Washer',
      nameUrdu: 'کار واشر',
      description: 'Car wash, interior cleaning, polishing at doorstep',
      iconName: 'local_car_wash',
      isEnabled: true,
      sortOrder: 4,
      subCategories: ['Exterior Wash', 'Interior Cleaning', 'Polish & Wax'],
    ),
    CategoryModel(
      id: 'cat_mechanic',
      name: 'Mechanic',
      nameUrdu: 'مکینک',
      description: 'Auto repair, oil change, bike/car servicing',
      iconName: 'car_repair',
      isEnabled: true,
      sortOrder: 5,
      subCategories: [
        'Oil Change',
        'Brake Repair',
        'Engine Service',
        'Bike Repair',
        'Battery',
      ],
    ),
    CategoryModel(
      id: 'cat_painter',
      name: 'Painter',
      nameUrdu: 'پینٹر',
      description: 'House painting, wall putty, waterproofing',
      iconName: 'format_paint',
      isEnabled: true,
      sortOrder: 6,
      subCategories: ['Interior Painting', 'Exterior Painting', 'Waterproofing'],
    ),
    CategoryModel(
      id: 'cat_carpenter',
      name: 'Carpenter',
      nameUrdu: 'ترکھان',
      description: 'Door/window fitting, furniture repair, woodwork',
      iconName: 'carpenter',
      isEnabled: true,
      sortOrder: 7,
      subCategories: ['Door Repair', 'Furniture Fix', 'Window Frame', 'Almirah'],
    ),
    CategoryModel(
      id: 'cat_cleaner',
      name: 'Cleaner / Sweeper',
      nameUrdu: 'صفائی والا',
      description: 'Deep cleaning, sofa cleaning, home sanitization',
      iconName: 'cleaning_services',
      isEnabled: true,
      sortOrder: 8,
      subCategories: ['Deep Clean', 'Sofa Clean', 'Tank Cleaning', 'Pest Control'],
    ),
  ];

  final List<CityModel> _cities = [
    CityModel(
      id: 'city_sahiwal',
      name: 'Sahiwal',
      nameUrdu: 'ساہیوال',
      isEnabled: true,
      areas: ['Farid Town', 'Block A', 'Block B', 'Model Town', 'Qasim Abad'],
      lat: 30.6706,
      lng: 73.1064,
    ),
    CityModel(
      id: 'city_okara',
      name: 'Okara',
      nameUrdu: 'اوکاڑہ',
      isEnabled: true,
      areas: ['Civil Lines', 'Old City', 'Renala Khurd', 'Deepalpur Road'],
      lat: 30.8100,
      lng: 73.4497,
    ),
    CityModel(
      id: 'city_lahore',
      name: 'Lahore',
      nameUrdu: 'لاہور',
      isEnabled: true,
      areas: [
        'Gulberg',
        'DHA',
        'Model Town',
        'Johar Town',
        'Cantt',
        'Pattoki',
      ],
      lat: 31.5204,
      lng: 74.3587,
    ),
    CityModel(
      id: 'city_chichawatni',
      name: 'Chichawatni',
      nameUrdu: 'چیچہ وطنی',
      isEnabled: false,
      areas: ['City Center', 'Near Canal'],
      lat: 30.5310,
      lng: 72.6907,
    ),
    CityModel(
      id: 'city_arifwala',
      name: 'Arifwala',
      nameUrdu: 'عارفوالہ',
      isEnabled: false,
      areas: ['Main Bazaar', 'Old City'],
      lat: 30.2905,
      lng: 73.0668,
    ),
    CityModel(
      id: 'city_pakpattan',
      name: 'Pakpattan',
      nameUrdu: 'پاکپتن',
      isEnabled: false,
      areas: ['Darbar Road', 'Main City'],
      lat: 30.3433,
      lng: 73.3875,
    ),
    CityModel(
      id: 'city_depalpur',
      name: 'Depalpur',
      nameUrdu: 'دیپالپور',
      isEnabled: false,
      areas: ['City Center'],
      lat: 30.9267,
      lng: 73.9843,
    ),
    CityModel(
      id: 'city_faisalabad',
      name: 'Faisalabad',
      nameUrdu: 'فیصل آباد',
      isEnabled: false,
      areas: ['Clock Tower', 'Jhang Road', 'Satiana Road'],
      lat: 31.4504,
      lng: 73.1350,
    ),
  ];

  Future<List<CategoryModel>> getEnabledCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _categories.where((c) => c.isEnabled).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<List<CategoryModel>> getAllCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> toggleCategory(String categoryId, bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(isEnabled: enabled);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _categories.add(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) _categories[index] = category;
  }

  Future<void> deleteCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _categories.removeWhere((c) => c.id == categoryId);
  }

  // Cities
  Future<List<CityModel>> getEnabledCities() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _cities.where((c) => c.isEnabled).toList();
  }

  Future<List<CityModel>> getAllCities() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_cities);
  }

  Future<void> toggleCity(String cityId, bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _cities.indexWhere((c) => c.id == cityId);
    if (index != -1) {
      _cities[index] = _cities[index].copyWith(isEnabled: enabled);
    }
  }
}
