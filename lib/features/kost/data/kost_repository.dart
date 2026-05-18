import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final kostRepositoryProvider = Provider<KostRepository>((ref) {
  return KostRepository(ref.watch(dioProvider));
});

class KostRepository {
  final Dio _dio;

  KostRepository(this._dio);

  Future<Response> getKosts({int page = 1, String? search}) async {
    final Map<String, dynamic> query = {'page': page};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    return await _dio.get('/kosts/', queryParameters: query);
  }

  Future<Response> getKostDetail(int id) async {
    return await _dio.get('/kosts/$id/');
  }
}