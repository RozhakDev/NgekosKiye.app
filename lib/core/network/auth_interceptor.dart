import 'package:dio/dio.dart';

import '../local_storage/secure_storage_service.dart';

/// Menambahkan token autentikasi dan menangani kegagalan otorisasi pada request API.
///
/// Class ini bekerja bersama Dio sebelum dan sesudah request dikirim.
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService secureStorage;

  AuthInterceptor(this.dio, this.secureStorage);

  /// Menambahkan token akses ke header sebelum request dikirim.
  ///
  /// Method ini dipanggil otomatis oleh Dio pada setiap request.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    return super.onRequest(options, handler);
  }

  /// Menangani respons error dan membersihkan sesi saat token tidak valid.
  ///
  /// Method ini membantu menjaga alur autentikasi tetap aman.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthPath = err.requestOptions.path.contains('/auth/login') || 
                       err.requestOptions.path.contains('/auth/refresh') || 
                       err.requestOptions.path.contains('/auth/register') ||
                       err.requestOptions.path.contains('/auth/verify-otp') ||
                       err.requestOptions.path.contains('/auth/resend-otp');

    if (err.response?.statusCode == 401 && !isAuthPath) {
      if (err.requestOptions.extra['isRetry'] == true) {
        return super.onError(err, handler);
      }

      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
          final response = await refreshDio.post('/users/auth/refresh/', data: {'refresh': refreshToken});

          final newAccessToken = response.data['access'];
          await secureStorage.saveTokens(access: newAccessToken, refresh: refreshToken);
          
          final options = err.requestOptions;
          options.extra['isRetry'] = true;
          options.headers['Authorization'] = 'Bearer $newAccessToken';
          final cloneReq = await dio.fetch(options);
          return handler.resolve(cloneReq);
        } catch (e) {
          await secureStorage.clearAll();
        }
      }
    }
    return super.onError(err, handler);
  }
}