class UserModel {
  final String email;
  final String name;
  final String phone;
  final String pic;

  UserModel({
    required this.email,
    required this.name,
    required this.phone,
    required this.pic,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      pic: json['pic'] ?? '',
    );
  }
}
