class UserModel {
    int id;
    String name;
    String role;

    UserModel({
        required this.id,
        required this.name,
        required this.role,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        role: json["role"],
    );
}