import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/kost_list_controller.dart';
import '../../domain/kost_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';

class KostDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const KostDetailScreen({super.key, required this.id});

  @override
  ConsumerState<KostDetailScreen> createState() => _KostDetailScreenState();
}

class _KostDetailScreenState extends ConsumerState<KostDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final detailAsyncValue = ref.watch(kostDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const _DetailAppBar(),
      body: detailAsyncValue.when(
        data: (kost) => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _ImageSliderSliver(images: kost.images),
            _TitleSectionSliver(kost: kost),
            const _DividerSliver(),
            _FacilitiesSectionSliver(facilitiesStr: kost.facilities),
            const _DividerSliver(),
            _DescriptionSectionSliver(description: kost.description),
            const _DividerSliver(),
            _LocationSectionSliver(kost: kost),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Gagal memuat detail: $err')),
      ),
      bottomNavigationBar: detailAsyncValue.maybeWhen(
        data: (kost) => _BottomActionBar(kost: kost),
        orElse: () => null,
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => context.pop(),
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
          icon: const Icon(Icons.favorite_border, color: AppColors.primary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disimpan ke favorit')));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ImageSliderSliver extends StatefulWidget {
  final List<String> images;

  const _ImageSliderSliver({required this.images});

  @override
  State<_ImageSliderSliver> createState() => _ImageSliderSliverState();
}

class _ImageSliderSliverState extends State<_ImageSliderSliver> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: widget.images.isEmpty
                ? Container(color: Colors.grey[300])
                : PageView.builder(
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                      );
                    },
                  ),
          ),
          Positioned(
            top: 24,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppColors.primary,
              child: const Text(
                'TERSEDIA',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.isEmpty ? 1 : widget.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 8 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleSectionSliver extends StatelessWidget {
  final KostModel kost;

  const _TitleSectionSliver({required this.kost});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kost.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    kost.address,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.toIDR(kost.minPrice),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const Text(
                  ' / bulan',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilitiesSectionSliver extends StatelessWidget {
  final String facilitiesStr;

  const _FacilitiesSectionSliver({required this.facilitiesStr});

  IconData _getIconForFacility(String facility) {
    final lower = facility.toLowerCase();
    if (lower.contains('wifi') || lower.contains('internet')) return Icons.wifi;
    if (lower.contains('ac')) return Icons.ac_unit;
    if (lower.contains('kamar mandi dalam') || lower.contains('km dalam')) return Icons.shower_outlined;
    if (lower.contains('laundry')) return Icons.local_laundry_service_outlined;
    if (lower.contains('dapur')) return Icons.kitchen_outlined;
    if (lower.contains('parkir')) return Icons.local_parking_outlined;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_outlined;
    if (lower.contains('keamanan') || lower.contains('cctv')) return Icons.security_outlined;
    if (lower.contains('kasur')) return Icons.bed_outlined;
    if (lower.contains('lemari')) return Icons.door_sliding_outlined;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final facilities = facilitiesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fasilitas Utama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: facilities.length,
              itemBuilder: (context, index) {
                final facility = facilities[index];
                return Row(
                  children: [
                    Icon(_getIconForFacility(facility), size: 24, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        facility,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionSectionSliver extends StatelessWidget {
  final String description;

  const _DescriptionSectionSliver({required this.description});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSectionSliver extends StatelessWidget {
  final KostModel kost;

  const _LocationSectionSliver({required this.kost});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.push('/map', extra: {'lat': kost.latitude, 'lng': kost.longitude, 'name': kost.name}),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'PETA LOKASI',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              kost.address,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final KostModel kost;

  const _BottomActionBar({required this.kost});

  @override
  Widget build(BuildContext context) {
    bool hasAvailableRoom = kost.rooms != null && kost.rooms!.any((r) => r.status == 'available');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: hasAvailableRoom ? () {
            final room = kost.rooms!.firstWhere((r) => r.status == 'available');
            context.push('/booking/${room.id}', extra: {
              'kostId': kost.id,
              'roomPrice': double.parse(room.price)
            });
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            disabledBackgroundColor: AppColors.textSecondary,
          ),
          child: Text(
            hasAvailableRoom ? 'PESAN SEKARANG' : 'KAMAR PENUH',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}

class _DividerSliver extends StatelessWidget {
  const _DividerSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}