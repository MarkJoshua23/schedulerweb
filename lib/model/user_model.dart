

class UserModel {
  late final String firstName;
  late final String lastName;
  late final String email;
  late final String? section;
  late final String birthday;
  late final String userType;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.section,
    required this.birthday,
    required this.userType,
  });
}