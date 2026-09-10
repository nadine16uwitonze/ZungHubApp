enum UserRole { vendor, customer, government }

extension UserRoleCodec on UserRole {
  String get value => name;

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.customer,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    required this.role,
    required this.name,
  });

  final String id;
  final String phone;
  final UserRole role;
  final String name;
}
