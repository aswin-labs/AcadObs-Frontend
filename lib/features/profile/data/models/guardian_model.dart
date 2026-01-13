import 'package:acadobs/shared/models/user_model.dart';

class GuardianModel {
  String? message;
  String? guardianName;
  String? guardianContact;
  String? guardianEmail;
  String? guardianJob;
  String? guardianRelation;
  String? guardian2Name;
  String? guardian2Contact;
  String? guardian2Job;
  String? guardian2Relation;
  String? fatherName;
  String? motherName;
  String? houseName;
  String? street;
  String? city;
  String? landmark;
  String? district;
  String? state;
  String? country;
  String? post;
  String? pincode;
  UserModel? user;

  GuardianModel({
    this.message,
    this.guardianName,
    this.guardianContact,
    this.guardianEmail,
    this.guardianJob,
    this.guardianRelation,
    this.guardian2Name,
    this.guardian2Contact,
    this.guardian2Job,
    this.guardian2Relation,
    this.fatherName,
    this.motherName,
    this.user,
    this.houseName,
    this.street,
    this.city,
    this.landmark,
    this.district,
    this.state,
    this.country,
    this.post,
    this.pincode,
  });

  factory GuardianModel.fromJson(Map<String, dynamic> json) => GuardianModel(
    message: json["message"],
    guardianName: json["guardian_name"],
    guardianContact: json["guardian_contact"],
    guardianEmail: json["guardian_email"],
    guardianJob: json["guardian_job"],
    guardianRelation: json["guardian_relation"],
    guardian2Name: json["guardian2_name"],
    guardian2Contact: json["guardian2_contact"],
    guardian2Job: json["guardian2_job"],
    guardian2Relation: json["guardian2_relation"],
    fatherName: json["father_name"],
    motherName: json["mother_name"],
    houseName: json["house_name"],
    street: json["street"],
    city: json["city"],
    landmark: json["landmark"],
    district: json["district"],
    state: json["state"],
    country: json["country"],
    post: json["post"],
    pincode: json["pincode"],
    user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
  );
}
