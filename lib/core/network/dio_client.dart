import 'package:dio/dio.dart';

class DioClient {
  DioClient({String baseUrl = 'https://bankapi.veegil.com/api/v1'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
