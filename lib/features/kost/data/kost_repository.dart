import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final kostRepositoryProvider = Provider<KostRepository>((ref) {
  return KostRepository(ref.watch(dioProvider));
});

class KostRepository {
  final Dio _dio;

  KostRepository(this._dio);

  Future<Response> getKosts({int page = 1}) async {
    return await _dio.get('/kosts/', queryParameters: {'page': page});
  }

  Future<Response> getKostDetail(int id) async {
    return await _dio.get('/kosts/$id/');
  }
}