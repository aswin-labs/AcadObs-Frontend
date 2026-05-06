// import 'package:cookie_jar/cookie_jar.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class CookieService {
//   static PersistCookieJar? _cookieJar;

//   static Future<PersistCookieJar> getCookieJar() async {
//     if (_cookieJar != null) {
//       return _cookieJar!;
//     }

//     final appDocDir = await getApplicationDocumentsDirectory();

//     final storage = FileStorage(join(appDocDir.path, '.cookies'));

//     _cookieJar = PersistCookieJar(storage: storage, ignoreExpires: false);

//     return _cookieJar!;
//   }
// }
