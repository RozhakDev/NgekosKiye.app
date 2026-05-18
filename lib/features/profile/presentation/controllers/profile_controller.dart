import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/profile_repository.dart';
import '../../domain/user_model.dart';
import '../../../../core/local_storage/secure_storage_service.dart';
import '../../../../core/routing/app_router.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<UserModel?>>((ref) {
  return ProfileController(ref.watch(profileRepositoryProvider), SecureStorageService(), ref);
});

class ProfileController extends StateNotifier<AsyncValue<UserModel?>> {
  final ProfileRepository _repository;
  final SecureStorageService _storage;
  final Ref _ref;

  ProfileController(this._repository, this._storage, this._ref) : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _repository.getProfile();
      state = AsyncValue.data(UserModel.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error('Gagal memuat profil: $e', st);
    }
  }

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

  Future<void> logout() async {
    await _storage.clearAll();
    _ref.read(authStateProvider.notifier).state = false;
  }
}