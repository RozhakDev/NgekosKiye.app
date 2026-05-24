import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mengelola penyimpanan token secara aman di perangkat.
///
/// Class ini digunakan untuk menyimpan dan membaca sesi pengguna.
class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  /// Menyimpan access token dan refresh token secara aman.
  ///
  /// Method ini digunakan setelah pengguna berhasil masuk.
  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _keyAccessToken, value: access);
    await _storage.write(key: _keyRefreshToken, value: refresh);
  }

  /// Mengambil access token yang tersimpan di perangkat.
  ///
  /// Token ini digunakan untuk request API yang membutuhkan autentikasi.
  Future<String?> getAccessToken() async => await _storage.read(key: _keyAccessToken);
  /// Mengambil refresh token yang tersimpan di perangkat.
  ///
  /// Token ini digunakan untuk memperbarui sesi saat access token berakhir.
  Future<String?> getRefreshToken() async => await _storage.read(key: _keyRefreshToken);

  /// Menghapus seluruh data yang tersimpan di secure storage.
  ///
  /// Method ini digunakan saat sesi pengguna perlu dibersihkan.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}