// A utility class that holds constant values
class AppConstants {
  static const double defaultBorderRadius = 30;
  static const int paginationLimit = 13;

  // ********Other Constants*******
  // classgrades
  static const List<String> classGrades = [
    'LKG',
    'UKG',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  // periods
  // static const List<String> periods = ['1', '2','3','4'];

  // attendance remarks
  static List<String> attendanceRemarks = [
    'Medical',
    'Personal',
    'Official',
    'Other',
  ];

  // leave types
  static List<String> leaveTypes = [
    "Sick",
    "Casual",
    "Emergency",
    "Vacation",
    "Other",
  ];

  // homework types
  static List<String> homeworkTypes = ["online", "offline"];

  // achievement categories
  static List<String> achievementCategories = [
    "academic",
    "sports",
    "arts",
    "other",
  ];

  // achievement levels
  static List<String> achievementLevels = [
    "class",
    "school",
    "district",
    "state",
    "national",
    "international",
  ];

  // achievement status
  static List<String> achievementStatuses = [
    "1st prize",
    "2nd prize",
    "3rd prize",
    "participant",
    "other",
  ];

  // term exams
  static List<String> termExams = [
    "Term 1",
    "Term 2",
  ];

  // term exam names
  static const Map<String, List<String>> examinationNames = {
  "Term 1": [
    "PT 1",
    "Internal 1",
    "Term 1",
  ],
  "Term 2": [
    "PT 2",
    "Internal 2",
    "Term 2",
  ],
};
}
