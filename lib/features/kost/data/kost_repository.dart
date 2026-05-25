import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final kostRepositoryProvider = Provider<KostRepository>((ref) {
  return KostRepository(ref.watch(dioProvider));
});

/// Menghubungkan daftar dan detail kos dengan endpoint API.
///
/// Class ini menjadi sumber data untuk fitur pencarian dan detail kos.
class KostRepository {
  final Dio _dio;

  KostRepository(this._dio);

  /// Mengambil daftar kos dengan dukungan halaman dan kata kunci pencarian.
  ///
  /// Method ini digunakan untuk dashboard dan pencarian kos.
  Future<Response> getKosts({int page = 1, String? search}) async {
    final Map<String, dynamic> query = {'page': page};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    return await _dio.get('/kosts/', queryParameters: query);
  }

  /// Mengambil detail kos berdasarkan ID.
  ///
  /// Method ini digunakan saat pengguna membuka halaman detail kos.
  Future<Response> getKostDetail(int id) async {
    return await _dio.get('/kosts/$id/');
  }

  Future<Response> getRoomDetail(int id) async {
    return await _dio.get('/rooms/$id/');
  }
}