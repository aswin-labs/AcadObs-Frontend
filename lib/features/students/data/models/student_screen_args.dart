class StudentScreenArgs {
  final int studentId;
  final bool forStaff;

  const StudentScreenArgs({required this.studentId, required this.forStaff});

  Map<String, String> toQueryParameters() => {
    'studentId': studentId.toString(),
    'forStaff': forStaff.toString(),
  };

  factory StudentScreenArgs.fromQueryParameters(Map<String, String> params) {
    return StudentScreenArgs(
      studentId: int.tryParse(params['studentId'] ?? '') ?? 0,
      forStaff: params['forStaff'] == 'true',
    );
  }
}
