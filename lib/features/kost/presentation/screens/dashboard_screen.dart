import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/kost_list_controller.dart';
import '../../domain/kost_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_drawer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(kostListControllerProvider.notifier).fetchKosts();
    }
  }

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

  Future<void> _onRefresh() async {
    await ref.read(kostListControllerProvider.notifier).fetchKosts(isRefresh: true);
  }

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

  Widget _buildBody(KostListState state) {
    if (state.kosts.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.error != null && state.kosts.isEmpty) {
      return Center(child: Text(state.error!));
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const HomeSearchBarSliver(),
        const _PromoSliderSliver(),
        const _PopularLocationsSliver(),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const _SectionTitleSliver(title: 'Rekomendasi Kost', actionText: 'LIHAT SEMUA'),
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

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar();

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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DashboardBottomNavBar({required this.currentIndex, required this.onTap});

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

class _PromoSliderSliver extends StatelessWidget {
  const _PromoSliderSliver();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final colors = [AppColors.primary, AppColors.secondary, Colors.teal];
            final titles = ['Diskon 25%', 'Cashback 15%', 'Hemat 20%'];
            final badges = ['Pengguna Baru', 'Promo Spesial', 'Terbatas'];
            final subtitles = [
              'Untuk pemesanan bulan pertama',
              'Minimal transaksi Rp 500rb',
              'Khusus kost area Banyumas'
            ];

            return Container(
              width: MediaQuery.of(context).size.width - 34,
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.local_offer,
                      size: 100,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badges[index],
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          titles[index],
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitles[index],
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PopularLocationsSliver extends StatelessWidget {
  const _PopularLocationsSliver();

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
                return Container(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitleSliver extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionTitleSliver({required this.title, required this.actionText});

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

class _SeparatorLineSliver extends StatelessWidget {
  const _SeparatorLineSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox.shrink(),
    );
  }
}

class _KostListSliver extends StatelessWidget {
  final List<KostModel> kosts;

  const _KostListSliver({required this.kosts});

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

class _KostListItemCard extends StatelessWidget {
  final KostModel kost;
  final String badgeText;

  const _KostListItemCard({required this.kost, required this.badgeText});

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

class _LoadMoreSliver extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onTapped;

  const _LoadMoreSliver({required this.isLoading, required this.hasMore, required this.onTapped});

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