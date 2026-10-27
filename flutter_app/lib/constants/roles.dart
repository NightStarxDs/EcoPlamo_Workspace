/// Define all valid user roles in the system
enum UserRole {
  warga('warga'),
  pengurus('pengurus'),
  dlh('dlh');

  final String value;
  const UserRole(this.value);

  /// Get user role from string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.warga,
    );
  }
}