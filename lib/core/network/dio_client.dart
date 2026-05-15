import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_interceptor.dart';
import '../local_storage/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api/v1';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));
  
  final secureStorage = SecureStorageService();
  dio.interceptors.add(AuthInterceptor(dio, secureStorage));

  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});