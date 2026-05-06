// lib/services/auth_storage_service.dart
import 'dart:convert';
import 'dart:developer';

import 'package:acadobs/shared/models/user_permission_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  AuthStorageService._internal();
  static final AuthStorageService _instance = AuthStorageService._internal();
  factory AuthStorageService() => _instance;

  static const _kToken = 'auth_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUser = 'user_data';
  static const _kSchoolId = 'school_id';
  static const _kSchoolName = 'school_name';
  static const _kSchoolDetailsForTeacher = 'school_details_for_teacher';
  static const _kFcmToken = 'fcm_token';
  static const _kUserPermissions = 'user_permissions';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ***********Save*****************

  /// Save token and user data
  Future<void> saveUserCredentials({
    required String token,
    // required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await _storage.write(key: _kToken, value: token);
    // await _storage.write(key: _kRefreshToken, value: refreshToken);
    await _storage.write(key: _kUser, value: jsonEncode(userData));
  }

  // Save school Id
  Future<void> saveSchoolIdForParent({required String schoolId}) async {
    await _storage.write(key: _kSchoolId, value: schoolId);
  }

  // Save school Name
  Future<void> saveSchoolNameForParent({required String schoolName}) async {
    await _storage.write(key: _kSchoolName, value: schoolName);
  }

  // Save school details for teacher
  Future<void> saveSchoolDetailsForTeacher({
    required Map<String, dynamic> schoolData,
  }) async {
    await _storage.write(
      key: _kSchoolDetailsForTeacher,
      value: jsonEncode(schoolData),
    );
  }

  // Save fcm token
  Future<void> saveFcmToken({required String fcmToken}) async {
    await _storage.write(key: _kFcmToken, value: fcmToken);
  }

  // Save user permissions
  Future<void> saveUserPermissions({
    required UserPermissionModel permissions,
  }) async {
    await _storage.write(
      key: _kUserPermissions,
      value: jsonEncode(permissions.toJson()),
    );
  }

  //****************Access&Refresh Token*****************
 Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    log('SAVING ACCESS TOKEN => $accessToken', name: 'STORAGE_SERVICE');

    await _storage.write(key: _kToken, value: accessToken);

    log('SAVING REFRESH TOKEN => $refreshToken', name: 'STORAGE_SERVICE');

    await _storage.write(key: _kRefreshToken, value: refreshToken);

    final savedAccess = await _storage.read(key: _kToken);

    final savedRefresh = await _storage.read(key: _kRefreshToken);

    log('SAVED ACCESS TOKEN => $savedAccess', name: 'STORAGE_SERVICE');

    log('SAVED REFRESH TOKEN => $savedRefresh', name: 'STORAGE_SERVICE');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _kToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _kRefreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  // Get stored school id
  Future<String?> getSchoolIdForParent() async {
    return await _storage.read(key: _kSchoolId);
  }

  // **********Retrieve*****************

  // Get stored school name
  Future<String?> getSchoolNameForParent() async {
    return await _storage.read(key: _kSchoolName);
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

  /// Get user photo only
  Future<String?> getUserPhoto() async {
    final data = await getUserData();
    if (data == null) return null;
    return data['dp'] as String?;
  }

  // Get school details for teacher
  Future<Map<String, dynamic>?> getSchoolDetailsForTeacher() async {
    final raw = await _storage.read(key: _kSchoolDetailsForTeacher);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  // Get fcm token
  Future<String?> getFcmToken() async {
    return await _storage.read(key: _kFcmToken);
  }

  // Get permissions
  Future<UserPermissionModel?> getUserPermissions() async {
    final jsonString = await _storage.read(key: _kUserPermissions);

    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    return UserPermissionModel.fromJson(jsonMap);
  }

  /// Clear everything (on logout)
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// Logout helper
  Future<void> logout() async {
    await clear();
  }
}
