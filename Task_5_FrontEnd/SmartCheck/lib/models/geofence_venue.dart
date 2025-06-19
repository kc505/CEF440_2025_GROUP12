class GeofenceVenue {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GeofenceVenue({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  GeofenceVenue copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeofenceVenue(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory GeofenceVenue.fromJson(Map<String, dynamic> json) {
    return GeofenceVenue(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      radius: json['radius'].toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}
