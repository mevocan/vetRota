import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../auth/auth_storage.dart';

// Dio: JWT'yi Authorization header'ina, device_id'yi X-Device-Id'ye
// otomatik ekler. 401 alirsa session'i temizler. Sync endpoint'lerinde
// retry mantigi PushQueue/PullQueue tarafinda; burada agir uygulama
// retry'i yok (sync'in kendi logic'i daha bilgili karar verir).
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _dio.post<T>(path, data: data);
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._onUnauthorized);

  final AuthStorage _storage;
  final Future<void> Function() _onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    final deviceId = await _storage.ensureDeviceId();
    options.headers['X-Device-Id'] = deviceId;
    options.headers[HttpHeaders.acceptHeader] = 'application/json';

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _onUnauthorized();
    }
    handler.next(err);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(authStorageProvider);

  final dio = Dio(BaseOptions(
    baseUrl: '${Env.apiBaseUrl}/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  dio.interceptors.add(_AuthInterceptor(storage, () async {
    await storage.clearSession();
  }));

  return ApiClient(dio);
});
