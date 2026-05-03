import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

// flutter_secure_storage: Android'de EncryptedSharedPreferences, iOS'ta
// Keychain. JWT ve cihaz UUID'sini orada tutuyoruz.
class AuthStorage {
  AuthStorage(this._storage);

  static const _kAccessToken = 'access_token';
  static const _kDeviceId = 'device_id';
  static const _kClinicId = 'clinic_id';
  static const _kUserEmail = 'user_email';

  final FlutterSecureStorage _storage;

  Future<String> ensureDeviceId() async {
    final existing = await _storage.read(key: _kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final fresh = const Uuid().v4();
    await _storage.write(key: _kDeviceId, value: fresh);
    return fresh;
  }

  Future<String?> readToken() => _storage.read(key: _kAccessToken);
  Future<String?> readClinicId() => _storage.read(key: _kClinicId);
  Future<String?> readEmail() => _storage.read(key: _kUserEmail);

  Future<void> persistSession({
    required String token,
    required String clinicId,
    required String email,
  }) async {
    await _storage.write(key: _kAccessToken, value: token);
    await _storage.write(key: _kClinicId, value: clinicId);
    await _storage.write(key: _kUserEmail, value: email);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kClinicId);
    await _storage.delete(key: _kUserEmail);
    // device_id silinmez — cihaz kimligi kalici, sadece logout token'i siler.
  }
}

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage(const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ));
});
