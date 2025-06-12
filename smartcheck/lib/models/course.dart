class Course {
  final String id;
  final String code;
  final String name;
  final String status;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'status': status,
    };
  }
}
