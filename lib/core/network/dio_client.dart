import 'package:dio/dio.dart';

import '../services/token_storage.dart';

class DioClient {
  DioClient({
    String baseUrl = 'https://bankapi.veegil.com/api/v1',
    bool enableLogging = false,
    void Function()? onUnauthorized,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    // Full request/response logging (including auth payloads/tokens) is only
    // ever wired up for dev/staging — see appFlavorProvider in
    // core/config/app_flavor.dart. Never enabled in prod.
    if (enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
      );
    }

    // Attach auth token (if present) to every request.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
      ),
    );

    // A 401 means the token is dead (expired/invalid) — not the same as a
    // 403, which the API also uses for business-rule rejections (e.g.
    // "cannot deposit to another account") that have nothing to do with the
    // session being invalid. Only 401 should force a logout.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
