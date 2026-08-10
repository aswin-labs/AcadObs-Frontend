class DetailScreenArgs {
  final int id;
  final bool forStaff;

  const DetailScreenArgs({
    required this.id,
    required this.forStaff,
  });

  Map<String, String> toQueryParameters() => {
    'id': id.toString(),
    'forStaff': forStaff.toString(),
  };

  factory DetailScreenArgs.fromQueryParameters(Map<String, String> params) {
    return DetailScreenArgs(
      id: int.tryParse(params['id'] ?? '') ?? 0,
      forStaff: params['forStaff'] == 'true',
    );
  }
}