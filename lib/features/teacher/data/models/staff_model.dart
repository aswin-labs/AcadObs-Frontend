import 'dart:convert';

import 'package:acadobs/shared/models/user_model.dart';

StaffModelProfile staffModelFromJson(String str) =>
    StaffModelProfile.fromJson(json.decode(str));

String staffModelToJson(StaffModelProfile data) => json.encode(data.toJson());

class StaffModelProfile {
  int? id;
  String? qualification;
  String? address;
  UserModel? user;

  StaffModelProfile({this.id, this.qualification, this.address, this.user});

  factory StaffModelProfile.fromJson(Map<String, dynamic> json) =>
      StaffModelProfile(
        id: json["id"],
        qualification: json["qualification"],
        address: json["address"],
        user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "qualification": qualification,
    "address": address,
  };
}
