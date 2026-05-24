import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/profile_repository.dart';
import '../../domain/user_model.dart';
import '../../../../core/local_storage/secure_storage_service.dart';
import '../../../../core/routing/app_router.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<UserModel?>>((ref) {
  return ProfileController(ref.watch(profileRepositoryProvider), SecureStorageService(), ref);
});

/// Mengelola pemuatan, pembaruan, dan sesi profil pengguna.
///
/// Class ini menghubungkan repository profil dengan tampilan.
class ProfileController extends StateNotifier<AsyncValue<UserModel?>> {
  final ProfileRepository _repository;
  final SecureStorageService _storage;
  final Ref _ref;

  ProfileController(this._repository, this._storage, this._ref) : super(const AsyncValue.data(null)) {
    _ref.listen<bool>(authStateProvider, (previous, next) {
      if (next == true) {
        fetchProfile();
      } else {
        state = const AsyncValue.data(null);
      }
    });

    if (_ref.read(authStateProvider)) {
      fetchProfile();
    }
  }

  /// Memuat profil pengguna dan memperbarui state halaman.
  ///
  /// Method ini dipanggil sebelum data profil ditampilkan.
  Future<void> fetchProfile() async {
    if (!_ref.read(authStateProvider)) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final response = await _repository.getProfile();
      state = AsyncValue.data(UserModel.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error('Gagal memuat profil: $e', st);
    }
  }

  /// Mengirim perubahan data profil pengguna ke server.
  ///
  /// Method ini digunakan saat pengguna menyimpan edit profil.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.updateProfile(data);
      final responseData = response.data['data'] ?? response.data;
      state = AsyncValue.data(UserModel.fromJson(responseData));
      return true;
    } catch (e, st) {
      state = AsyncValue.error('Gagal memperbarui profil: $e', st);
      return false;
    }
  }

  /// Menghapus sesi pengguna dari aplikasi.
  ///
  /// Method ini membersihkan data lokal yang berkaitan dengan akun.
  Future<void> logout() async {
    await _storage.clearAll();
    state = const AsyncValue.data(null);
    _ref.read(authStateProvider.notifier).state = false;
  }
}