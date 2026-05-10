import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/auth_repository.dart';
import '../../../../core/local_storage/secure_storage_service.dart';
import '../../../../core/routing/app_router.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    SecureStorageService(),
    ref,
  );
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final SecureStorageService _storage;
  final Ref _ref;

  AuthController(this._repository, this._storage, this._ref) : super(const AsyncValue.data(null));

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.login(username, password);

      final access = response.data['access'];
      final refresh = response.data['refresh'];
      await _storage.saveTokens(access: access, refresh: refresh);

      _ref.read(authStateProvider.notifier).state = true;
      state = const AsyncValue.data(null);
    } on DioException catch (e) {
      final errorMsg = e.response?.data['detail'] ?? 'Login gagal. Periksa kredensial Anda.';
      state = AsyncValue.error(errorMsg, e.stackTrace);
    } catch (e, st) {
      state = AsyncValue.error('Terjadi kesalahan yang tidak terduga', st);
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.register(data);
      state = const AsyncValue.data(null);
    } on DioException catch (e) {
      String errorMsg = 'Registrasi gagal.';
      if (e.response?.data != null && e.response?.data is Map) {
        final Map errors = e.response!.data;
        errorMsg = errors.values.first.first.toString();
      }
      state = AsyncValue.error(errorMsg, e.stackTrace);
    } catch (e, st) {
      state = AsyncValue.error('Terjadi kesalahan jaringan', st);
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    state = const AsyncValue.loading();
    try {
      await _repository.verifyOtp(email, otp);
      state = const AsyncValue.data(null);
    } on DioException catch (e) {
      final errorMsg = e.response?.data['pesan'] ?? 'OTP Salah.';
      state = AsyncValue.error(errorMsg, e.stackTrace);
    }
  }
}