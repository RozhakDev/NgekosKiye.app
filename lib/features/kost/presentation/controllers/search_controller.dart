import 'package:flutter_riverpod/legacy.dart';

import '../../data/kost_repository.dart';
import '../../domain/kost_model.dart';
import 'kost_list_controller.dart';

final searchControllerProvider = StateNotifierProvider.autoDispose<SearchController, KostListState>((ref) {
  return SearchController(ref.watch(kostRepositoryProvider));
});

/// Mengelola pencarian kos dan pagination hasil pencarian.
///
/// Class ini memperbarui daftar hasil berdasarkan kata kunci pengguna.
class SearchController extends StateNotifier<KostListState> {
  final KostRepository _repository;
  String _currentQuery = '';

  SearchController(this._repository)
      : super(KostListState(kosts: [], isLoading: false, hasMore: true, page: 1));

  /// Memulai pencarian kos berdasarkan kata kunci.
  ///
  /// Method ini mengatur ulang hasil sebelum data baru dimuat.
  void search(String query) {
    _currentQuery = query;
    _fetchResults(isRefresh: true);
  }

  /// Memuat halaman berikutnya jika masih tersedia.
  ///
  /// Method ini dipakai saat pengguna menggulir daftar hasil.
  void loadMore() {
    _fetchResults(isRefresh: false);
  }

  /// Mengambil hasil pencarian dan memperbarui state daftar.
  ///
  /// Method ini menjaga proses pencarian tetap terpusat.
  Future<void> _fetchResults({bool isRefresh = false}) async {
    if (_currentQuery.isEmpty) {
      state = state.copyWith(page: 1, hasMore: false, isLoading: false, error: null, kosts: []);
      return;
    }

    if (state.isLoading || (!state.hasMore && !isRefresh)) return;

    if (isRefresh) {
      state = state.copyWith(page: 1, hasMore: true, isLoading: true, error: null, kosts: []);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _repository.getKosts(page: state.page, search: _currentQuery);
      
      List<dynamic> results;
      dynamic next;
      if (response.data is Map<String, dynamic> && (response.data as Map<String, dynamic>).containsKey('results')) {
        results = response.data['results'] as List<dynamic>;
        next = response.data['next'];
      } else {
        results = response.data as List<dynamic>;
        next = null;
      }

      final List<KostModel> newKosts = results.map((json) => KostModel.fromJson(json)).toList();

      state = state.copyWith(
        kosts: isRefresh ? newKosts : [...state.kosts, ...newKosts],
        isLoading: false,
        hasMore: next != null,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal melakukan pencarian.');
    }
  }
}