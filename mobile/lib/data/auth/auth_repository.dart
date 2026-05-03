import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'auth_storage.dart';

class LoginResult {
  LoginResult({required this.token, required this.clinicId});
  final String token;
  final String clinicId;
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final AuthStorage _storage;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final deviceId = await _storage.ensureDeviceId();

    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_id': deviceId,
        },
      );

      final token = response.data?['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw AuthException('Sunucudan token alinamadi.');
      }

      // /me cagirip clinic_id'yi alalim — JWT decode etmek yerine
      // sunucuya soruyoruz, daha az kuplanmis.
      final me = await _api.get<Map<String, dynamic>>('/auth/me');
      final clinicId = me.data?['clinic_id'] as String?;
      if (clinicId == null) {
        throw AuthException('Klinik bilgisi alinamadi.');
      }

      await _storage.persistSession(
        token: token,
        clinicId: clinicId,
        email: email,
      );

      return LoginResult(token: token, clinicId: clinicId);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        throw AuthException('E-posta veya parola hatali.');
      }
      throw AuthException(
        'Baglanti hatasi: ${e.message ?? 'bilinmeyen'}',
      );
    }
  }

  Future<void> logout() => _storage.clearSession();

  Future<bool> hasSession() async {
    final token = await _storage.readToken();
    return token != null && token.isNotEmpty;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authStorageProvider),
  );
});

// Boot'ta okunacak sessión durumu.
final sessionPresentProvider = FutureProvider<bool>((ref) async {
  return ref.watch(authRepositoryProvider).hasSession();
});
