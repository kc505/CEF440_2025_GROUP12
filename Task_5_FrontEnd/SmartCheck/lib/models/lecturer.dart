class Lecturer {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;

  Lecturer({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Lecturer.fromFirestore(Map<String, dynamic> data) {
    return Lecturer(
      userId: data['userID'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
    );
  }

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return 'Unnamed Lecturer';
    return '$firstName $lastName'.trim();
  }
}