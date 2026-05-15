import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/kost_list_controller.dart';
import '../../domain/kost_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';

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
    if (index == 3) {
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
        const _SearchBarSliver(),
        if (state.kosts.isNotEmpty) _FeaturedKostSliver(kost: state.kosts.first),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const _SectionTitleSliver(title: 'Rekomendasi Kami', actionText: 'LIHAT SEMUA'),
        const _SeparatorLineSliver(),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (state.kosts.length > 1) _KostListSliver(kosts: state.kosts.skip(1).toList()),
        _LoadMoreSliver(isLoading: state.isLoading, hasMore: state.hasMore, onTapped: () => ref.read(kostListControllerProvider.notifier).fetchKosts()),
      ],
    );
  }
}

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.primary),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu ditekan')));
        },
      ),
      title: const Text(
        'NGEKOSKIYE',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1.5,
          color: AppColors.primary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi ditekan')));
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

class _SearchBarSliver extends StatelessWidget {
  const _SearchBarSliver();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Cari kost, lokasi, atau fasilitas...',
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
        ),
      ),
    );
  }
}

class _FeaturedKostSliver extends StatelessWidget {
  final KostModel kost;

  const _FeaturedKostSliver({required this.kost});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => context.push('/kost/${kost.id}'),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: kost.images.isNotEmpty
                  ? Image.network(
                      kost.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                    )
                  : Container(color: Colors.grey[300]),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: AppColors.primary,
                    child: const Text(
                      'KOST TERPOPULER',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    kost.name,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kost.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/kost/${kost.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                      ),
                      child: const Text('LIHAT DETAIL'),
                    ),
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

class _SectionTitleSliver extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionTitleSliver({required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const Icon(Icons.arrow_forward, size: 14, color: AppColors.textSecondary),
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(color: AppColors.border, thickness: 1, height: 1),
      ),
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
          final isNew = index % 2 == 0;
          final badgeText = isNew ? 'BARU' : 'TERLARIS';

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
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: kost.images.isNotEmpty
                      ? Image.network(
                          kost.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                        )
                      : Container(color: Colors.grey[300]),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: AppColors.surface,
                    child: Text(
                      badgeText,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          kost.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        CurrencyFormatter.toShortIDR(kost.minPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          kost.address,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kost.facilities.replaceAll(',', ' •'),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
