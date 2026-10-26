/// Service category model — admin configurable, no app code change needed.
class CategoryModel {
  final String id;
  final String name;
  final String nameUrdu;
  final String description;
  final String iconName; // Maps to material icon name string
  final bool isEnabled;
  final int sortOrder;
  final List<String> subCategories;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameUrdu = '',
    this.description = '',
    this.iconName = 'handyman',
    this.isEnabled = true,
    this.sortOrder = 0,
    this.subCategories = const [],
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      nameUrdu: map['nameUrdu'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'handyman',
      isEnabled: map['isEnabled'] as bool? ?? true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      subCategories: List<String>.from(map['subCategories'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameUrdu': nameUrdu,
        'description': description,
        'iconName': iconName,
        'isEnabled': isEnabled,
        'sortOrder': sortOrder,
        'subCategories': subCategories,
      };

  CategoryModel copyWith({
    String? name,
    String? nameUrdu,
    String? description,
    String? iconName,
    bool? isEnabled,
    int? sortOrder,
    List<String>? subCategories,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      nameUrdu: nameUrdu ?? this.nameUrdu,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}

/// City/area model — admin configurable.
class CityModel {
  final String id;
  final String name;
  final String nameUrdu;
  final bool isEnabled;
  final List<String> areas;
  final double? lat;
  final double? lng;

  const CityModel({
    required this.id,
    required this.name,
    this.nameUrdu = '',
    this.isEnabled = true,
    this.areas = const [],
    this.lat,
    this.lng,
  });

  factory CityModel.fromMap(Map<String, dynamic> map, String id) {
    return CityModel(
      id: id,
      name: map['name'] as String? ?? '',
      nameUrdu: map['nameUrdu'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? true,
      areas: List<String>.from(map['areas'] as List? ?? []),
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameUrdu': nameUrdu,
        'isEnabled': isEnabled,
        'areas': areas,
        'lat': lat,
        'lng': lng,
      };

  CityModel copyWith({bool? isEnabled, String? nameUrdu, List<String>? areas}) {
    return CityModel(
      id: id,
      name: name,
      nameUrdu: nameUrdu ?? this.nameUrdu,
      isEnabled: isEnabled ?? this.isEnabled,
      areas: areas ?? this.areas,
      lat: lat,
      lng: lng,
    );
  }
}
