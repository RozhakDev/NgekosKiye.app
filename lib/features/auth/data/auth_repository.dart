import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// Menghubungkan fitur autentikasi dengan endpoint API.
///
/// Class ini menjadi pintu akses data untuk login, register, dan pemulihan akun.
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Memproses autentikasi pengguna dengan kredensial yang diberikan.
  ///
  /// Method ini digunakan saat pengguna masuk ke aplikasi.
  Future<Response> login(String username, String password) async {
    return await _dio.post('/users/auth/login/', data: {
      'username': username,
      'password': password,
    });
  }

  /// Mengirim data pendaftaran akun baru ke server.
  ///
  /// Method ini digunakan saat pengguna membuat akun.
  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/users/auth/register/', data: data);
  }

  /// Memverifikasi kode OTP yang dikirim ke email pengguna.
  ///
  /// Method ini menyelesaikan proses verifikasi akun.
  Future<Response> verifyOtp(String email, String otp) async {
    return await _dio.post('/users/auth/verify-otp/', data: {
      'email': email,
      'otp': otp,
    });
  }

  /// Meminta pengiriman ulang kode OTP ke email pengguna.
  ///
  /// Method ini digunakan saat pengguna belum menerima atau melewatkan kode.
  Future<Response> resendOtp(String email) async {
    return await _dio.post('/users/auth/resend-otp/', data: {
      'email': email,
    });
  }

  /// Memulai proses pemulihan kata sandi melalui email.
  ///
  /// Method ini mengirim permintaan reset ke server.
  Future<Response> forgotPassword(String email) async {
    return await _dio.post('/users/auth/forgot-password/', data: {
      'email': email,
    });
  }

  /// Mengirim OTP dan kata sandi baru untuk menyelesaikan reset akun.
  ///
  /// Method ini digunakan setelah pengguna menerima kode pemulihan.
  Future<Response> resetPassword(String email, String otp, String password) async {
    return await _dio.post('/users/auth/reset-password/', data: {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirm': password,
    });
  }
}