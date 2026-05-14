import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<Response> getProfile() async {
    return await _dio.get('/users/profile/');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.patch('/users/profile/', data: data);
  }
}