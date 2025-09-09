// lib/services/auth_storage_service.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const _kToken = 'auth_token';
  static const _kUser = 'user_data';
  static const _kSchoolId = 'school_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Save token and user data
  Future<void> saveUserCredentials({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUser, value: jsonEncode(userData));
  }

  // Save school Id
  Future<void> saveSchoolIdForParent({required String schoolId}) async {
    await _storage.write(key: _kSchoolId, value: schoolId);
  }

  // Get stored school id
  Future<String?> getSchoolIdForParent() async {
    return await _storage.read(key: _kSchoolId);
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _kToken);
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  /// Get user id
  Future<int?> getUserId() async {
    final data = await getUserData();
    if (data == null) return null;
    return data['user_id'] as int?;
  }

  /// Get user role only
  Future<String?> getUserRole() async {
    final data = await getUserData();
    if (data == null) return null;
    return data['role'] as String?;
  }

  /// Clear everything (on logout)
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
