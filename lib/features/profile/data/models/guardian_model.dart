class GuardianModel {
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
  String? photoUrl;

  GuardianModel({
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
    this.photoUrl,
  });

  factory GuardianModel.fromJson(Map<String, dynamic> json) => GuardianModel(
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
    photoUrl: json['dp'],
  );
}
