class UserModel {
  int? id;
  String? name;
  String role;
  String? email;
  String? phone;
  String? dp;

  UserModel({
    this.id,
    this.name,
    required this.role,
    this.email,
    this.phone,
    this.dp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    role: json["role"] ?? "",
    email: json["email"],
    phone: json["phone"],
    dp: json["dp"],
  );
}
