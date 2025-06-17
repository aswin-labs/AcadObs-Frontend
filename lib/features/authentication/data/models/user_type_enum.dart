enum UserType { superAdmin, schoolAdmin, teacher, parent }

extension UserTypeExtension on UserType {
  String get label {
    switch (this) {
      case UserType.superAdmin:
        return 'Super Admin';
      case UserType.schoolAdmin:
        return 'School Admin';
      case UserType.teacher:
        return 'Teacher';
      case UserType.parent:
        return 'Parent';
    }
  }
}
