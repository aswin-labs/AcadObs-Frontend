enum UserType { teacher, parent, nonTeachingStaff }

extension UserTypeExtension on UserType {
  String get label {
    switch (this) {
      case UserType.teacher:
        return 'Teacher';
      case UserType.parent:
        return 'Parent';
      case UserType.nonTeachingStaff:
        return 'Non-Teaching Staff';
    }
  }
}
