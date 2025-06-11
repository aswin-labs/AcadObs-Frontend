/// Base URLs for API and Media
class BaseUrls {
  static const String api = 'https://acadobs.altezzai.com/api/s1';
  static const String media = 'https://acadobs.altezzai.com';
}

/// API Endpoints (relative paths only)
class ApiEndpoints {
  // SUPER ADMIN
  static const String schools = "/superadmin/schools";
  static const String classes = "/superadmin/classes";
  static const String subjects = "/superadmin/subjects";
}

/// Media/Image Endpoints (relative paths only)
class MediaEndpoints {
  static const String schoolLogos = "/uploads/school_logos/";
}
