import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/kost_list_controller.dart';
import '../../domain/kost_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_drawer.dart';
import '../widgets/animated_promo_slider.dart';

/// Menampilkan halaman utama berisi daftar dan rekomendasi kos.
///
/// Widget ini menjadi pusat navigasi utama pengguna.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

/// Mengelola scroll, refresh, dan navigasi pada halaman utama.
///
/// State ini memicu pemuatan data tambahan saat pengguna menggulir.
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  /// Menyiapkan state awal saat widget pertama kali dibuat.
  ///
  /// Method ini dipakai untuk memulai listener, timer, atau pemuatan data awal.
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  /// Membersihkan controller dan resource saat halaman tidak digunakan.
  ///
  /// Method ini mencegah resource tetap aktif setelah widget ditutup.
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Memantau posisi scroll untuk memuat data tambahan.
  ///
  /// Method ini membantu pagination berjalan otomatis.
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(kostListControllerProvider.notifier).fetchKosts();
    }
  }

  /// Menangani pilihan menu navigasi bawah.
  ///
  /// Method ini mengarahkan pengguna ke halaman sesuai tab yang dipilih.
  void _onBottomNavTapped(int index) {
    if (index == 1) {
      context.push('/search');
    } else if (index == 2) {
      context.push('/history');
    } else if (index == 3) {
      context.push('/profile');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Memuat ulang daftar kos dari halaman pertama.
  ///
  /// Method ini digunakan saat pengguna melakukan pull to refresh.
  Future<void> _onRefresh() async {
    await ref.read(kostListControllerProvider.notifier).fetchKosts(isRefresh: true);
  }

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kostListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _DashboardAppBar(),
      drawer: const HomeDrawer(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: _buildBody(state),
      ),
      bottomNavigationBar: _DashboardBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  /// Membangun isi halaman sesuai state pemuatan dan data.
  ///
  /// Method ini memilih tampilan kosong, loading, error, atau daftar data.
  Widget _buildBody(KostListState state) {
    if (state.kosts.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.error != null && state.kosts.isEmpty) {
      return CustomEmptyState(
        message: state.error!,
        onRetry: _onRefresh,
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const HomeSearchBarSliver(),
        const AnimatedPromoSlider(),
        const _PopularLocationsSliver(),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const _SectionTitleSliver(title: 'Kost Terbaru', actionText: 'LIHAT SEMUA'),
        const _SeparatorLineSliver(),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        if (state.kosts.isNotEmpty) _KostListSliver(kosts: state.kosts),
        _LoadMoreSliver(
          isLoading: state.isLoading,
          hasMore: state.hasMore,
          onTapped: () => ref.read(kostListControllerProvider.notifier).fetchKosts(),
        ),
      ],
    );
  }
}

/// Menampilkan app bar khusus pada halaman utama.
///
/// Widget ini menyediakan akses menu dan notifikasi.
class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar();

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: const Text(
        'NgekosKiye',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            NotificationUtils.show(context, message: 'Belum ada notifikasi baru');
          },
        ),
      ],
    );
  }

  /// Menentukan tinggi app bar agar sesuai dengan kontrak Flutter.
  ///
  /// Nilai ini dipakai oleh Scaffold saat menempatkan app bar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Menampilkan navigasi bawah untuk akses cepat halaman utama.
///
/// Widget ini membantu pengguna berpindah ke bagian penting aplikasi.
class _DashboardBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DashboardBottomNavBar({required this.currentIndex, required this.onTap});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), activeIcon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}

/// Menampilkan pilihan lokasi populer dalam bentuk sliver.
///
/// Widget ini membantu pengguna menemukan kos berdasarkan area.
class _PopularLocationsSliver extends StatelessWidget {
  const _PopularLocationsSliver();

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final locations = ['Banyumas', 'Cilacap', 'Purbalingga', 'Kebumen', 'Brebes', 'Tegal', 'Banjarnegara', 'Wonosobo'];
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Lokasi Populer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: locations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => context.push('/search?query=${Uri.encodeComponent(locations[index])}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      locations[index],
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Menampilkan judul bagian pada daftar sliver.
///
/// Widget ini memisahkan konten halaman agar mudah dipindai.
class _SectionTitleSliver extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionTitleSliver({required this.title, required this.actionText});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan garis pemisah antarbagian sliver.
///
/// Widget ini menjaga struktur visual halaman tetap rapi.
class _SeparatorLineSliver extends StatelessWidget {
  const _SeparatorLineSliver();

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox.shrink(),
    );
  }
}

/// Menampilkan daftar kos dalam struktur sliver.
///
/// Widget ini menyusun kartu kos pada halaman utama.
class _KostListSliver extends StatelessWidget {
  final List<KostModel> kosts;

  const _KostListSliver({required this.kosts});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final kost = kosts[index];
          final isPromo = index % 2 == 0;
          final badgeText = isPromo ? 'PROMO' : 'TERLARIS';

          return _KostListItemCard(kost: kost, badgeText: badgeText);
        },
        childCount: kosts.length,
      ),
    );
  }
}

/// Menampilkan ringkasan satu kos pada daftar utama.
///
/// Widget ini memuat gambar, nama, lokasi, dan harga kos.
class _KostListItemCard extends StatelessWidget {
  final KostModel kost;
  final String badgeText;

  const _KostListItemCard({required this.kost, required this.badgeText});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/kost/${kost.id}'),
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: kost.images.isNotEmpty
                        ? Image.network(
                            kost.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                          )
                        : Container(color: Colors.grey[300]),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
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
                  const SizedBox(height: 8),
                  Text(
                    kost.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          kost.facilities.replaceAll(',', ' •'),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        CurrencyFormatter.toShortIDR(kost.minPrice),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan indikator saat data tambahan sedang dimuat.
///
/// Widget ini memberi umpan balik pada proses pagination.
class _LoadMoreSliver extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onTapped;

  const _LoadMoreSliver({required this.isLoading, required this.hasMore, required this.onTapped});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: hasMore
            ? (isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : OutlinedButton(
                    onPressed: onTapped,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('MUAT LEBIH BANYAK', style: TextStyle(fontWeight: FontWeight.bold)),
                  ))
            : const Center(
                child: Text('Semua kost telah ditampilkan', style: TextStyle(color: AppColors.textSecondary)),
              ),
      ),
    );
  }
}