import 'dart:convert';
SchoolModel schoolModelFromJson(String str) => SchoolModel.fromJson(json.decode(str));


class SchoolModel {
    int? schoolId;
    School? school;

    SchoolModel({
        this.schoolId,
        this.school,
    });

    factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
        schoolId: json["school_id"],
        school: json["School"] == null ? null : School.fromJson(json["School"]),
    );
}

class School {
    int? id;
    String? name;
    String? address;
    String? phone;
    String? email;
    String? logo;

    School({
        this.id,
        this.name,
        this.address,
        this.phone,
        this.email,
        this.logo,
    });

    factory School.fromJson(Map<String, dynamic> json) => School(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        phone: json["phone"],
        email: json["email"],
        logo: json["logo"],
    );
}
