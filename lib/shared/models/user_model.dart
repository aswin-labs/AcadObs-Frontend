import 'package:acadobs/features/profile/data/models/guardian_model.dart';

class UserModel {
  int? id;
  String? name;
  String role;
  String? email;
  String? phone;
  String? dp;
  GuardianModel? guardian;

  UserModel({
    this.id,
    this.name,
    required this.role,
    this.email,
    this.phone,
    this.dp,
    this.guardian,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    role: json["role"] ?? "",
    email: json["email"],
    phone: json["phone"],
    dp: json["dp"],
    guardian: json["Guardian"] != null ? GuardianModel.fromJson(json["Guardian"]) : null,
  );
}
