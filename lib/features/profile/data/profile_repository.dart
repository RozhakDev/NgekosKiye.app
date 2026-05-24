import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

/// Menghubungkan data profil pengguna dengan endpoint API.
///
/// Class ini menangani proses ambil dan ubah profil.
class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  /// Mengambil data profil pengguna dari server.
  ///
  /// Method ini digunakan untuk mengisi halaman profil.
  Future<Response> getProfile() async {
    return await _dio.get('/users/profile/');
  }

  /// Mengirim perubahan data profil pengguna ke server.
  ///
  /// Method ini digunakan saat pengguna menyimpan edit profil.
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.patch('/users/profile/', data: data);
  }
}