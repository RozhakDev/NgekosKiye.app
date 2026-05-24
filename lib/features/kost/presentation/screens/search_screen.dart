import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/search_controller.dart' as search_ctrl;
import '../../domain/kost_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Menampilkan halaman pencarian kos.
///
/// Widget ini digunakan untuk menemukan kos berdasarkan kata kunci.
class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

/// Mengelola input pencarian, scroll, dan daftar hasil.
///
/// State ini memuat hasil baru saat kata kunci atau halaman berubah.
class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  /// Menyiapkan state awal saat widget pertama kali dibuat.
  ///
  /// Method ini dipakai untuk memulai listener, timer, atau pemuatan data awal.
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        ref.read(search_ctrl.searchControllerProvider.notifier).search(widget.initialQuery!);
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  /// Membersihkan controller dan resource saat halaman tidak digunakan.
  ///
  /// Method ini mencegah resource tetap aktif setelah widget ditutup.
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  /// Memantau posisi scroll untuk memuat data tambahan.
  ///
  /// Method ini membantu pagination berjalan otomatis.
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(search_ctrl.searchControllerProvider.notifier).loadMore();
    }
  }

  /// Menangani perubahan kata kunci pencarian dari pengguna.
  ///
  /// Method ini memicu pencarian baru sesuai input terakhir.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(search_ctrl.searchControllerProvider.notifier).search(query);
    });
  }

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(search_ctrl.searchControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textAlignVertical: TextAlignVertical.center,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Cari kost di daerah mana?',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
      body: _buildBody(state),
    );
  }

  /// Membangun isi halaman sesuai state pemuatan dan data.
  ///
  /// Method ini memilih tampilan kosong, loading, error, atau daftar data.
  Widget _buildBody(state) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState('Ketikkan sesuatu untuk mulai mencari.', Icons.search);
    }

    if (state.isLoading && state.kosts.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.error != null && state.kosts.isEmpty) {
      return _buildEmptyState(state.error!, Icons.error_outline);
    }

    if (state.kosts.isEmpty && !state.isLoading) {
      return _buildEmptyState('Tidak ada kost yang cocok dengan pencarian Anda.', Icons.location_city_outlined);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.kosts.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.kosts.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return _SearchKostItemCard(kost: state.kosts[index]);
      },
    );
  }

  /// Menampilkan tampilan kosong dengan pesan yang sesuai.
  ///
  /// Method ini digunakan saat pencarian atau daftar tidak memiliki hasil.
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan ringkasan kos pada hasil pencarian.
///
/// Widget ini memudahkan pengguna membandingkan hasil secara cepat.
class _SearchKostItemCard extends StatelessWidget {
  final KostModel kost;

  const _SearchKostItemCard({required this.kost});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/kost/${kost.id}'),
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 120,
                height: 120,
                child: kost.images.isNotEmpty
                    ? Image.network(
                        kost.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                      )
                    : Container(color: Colors.grey[300]),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kost.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            kost.address,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      CurrencyFormatter.toShortIDR(kost.minPrice),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}