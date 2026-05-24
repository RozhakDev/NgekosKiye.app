import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/kost_repository.dart';
import '../../domain/kost_model.dart';

/// Menyimpan state daftar kos, pagination, dan status pemuatan data.
///
/// Class ini membantu controller memperbarui UI secara konsisten.
class KostListState {
  final List<KostModel> kosts;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  KostListState({required this.kosts, required this.isLoading, required this.hasMore, required this.page, this.error});

  /// Membuat salinan state dengan nilai tertentu yang diperbarui.
  ///
  /// Method ini membantu perubahan state tetap eksplisit dan aman.
  KostListState copyWith({List<KostModel>? kosts, bool? isLoading, bool? hasMore, int? page, String? error}) {
    return KostListState(
      kosts: kosts ?? this.kosts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

final kostListControllerProvider = StateNotifierProvider<KostListController, KostListState>((ref) {
  return KostListController(ref.watch(kostRepositoryProvider));
});

/// Mengelola pemuatan daftar kos dari repository.
///
/// Class ini menangani refresh dan pagination daftar kos.
class KostListController extends StateNotifier<KostListState> {
  final KostRepository _repository;

  KostListController(this._repository)
      : super(KostListState(kosts: [], isLoading: false, hasMore: true, page: 1)) {
    fetchKosts();
  }

  /// Memuat daftar kos dan memperbarui state pagination.
  ///
  /// Method ini digunakan untuk refresh dan pemuatan halaman berikutnya.
  Future<void> fetchKosts({bool isRefresh = false}) async {
    if (state.isLoading || (!state.hasMore && !isRefresh)) return;

    if (isRefresh) {
      state = state.copyWith(page: 1, hasMore: true, isLoading: true, error: null, kosts: []);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _repository.getKosts(page: state.page);
      
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
      state = state.copyWith(isLoading: false, error: 'Gagal memuat katalog kost. Periksa koneksi Anda.');
    }
  }
}

final kostDetailProvider = FutureProvider.family<KostModel, int>((ref, id) async {
  final repo = ref.watch(kostRepositoryProvider);
  final res = await repo.getKostDetail(id);
  return KostModel.fromJson(res.data);
});