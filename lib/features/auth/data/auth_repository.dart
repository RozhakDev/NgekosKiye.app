import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Response> login(String username, String password) async {
    return await _dio.post('/users/auth/login/', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/users/auth/register/', data: data);
  }

  Future<Response> verifyOtp(String email, String otp) async {
    return await _dio.post('/users/auth/verify-otp/', data: {
      'email': email,
      'otp': otp,
    });
  }

  Future<Response> resendOtp(String email) async {
    return await _dio.post('/users/auth/resend-otp/', data: {
      'email': email,
    });
  }

  Future<Response> forgotPassword(String email) async {
    return await _dio.post('/users/auth/forgot-password/', data: {
      'email': email,
    });
  }

  Future<Response> resetPassword(String email, String otp, String password) async {
    return await _dio.post('/users/auth/reset-password/', data: {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirm': password,
    });
  }
}