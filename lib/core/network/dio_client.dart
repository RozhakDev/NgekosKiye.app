import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_interceptor.dart';
import '../local_storage/secure_storage_service.dart';

const String baseUrl = 'https://api.ngekost.my.id/api/v1';

final dioProvider = Provider<Dio>((ref) {
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