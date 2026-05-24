import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../controllers/kost_list_controller.dart';
import '../../domain/kost_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../widgets/inline_booking_form.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../presentation/controllers/favorite_controller.dart';

final selectedRoomIdProvider = StateProvider.autoDispose<int?>((ref) => null);
final bookingStartDateProvider = StateProvider.autoDispose<DateTime?>((ref) => null);
final bookingDurationProvider = StateProvider.autoDispose<int>((ref) => 1);

/// Menampilkan detail kos beserta galeri, fasilitas, dan pilihan kamar.
///
/// Widget ini membantu pengguna meninjau kos sebelum memesan.
class KostDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const KostDetailScreen({super.key, required this.id});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<KostDetailScreen> createState() => _KostDetailScreenState();
}

/// Mengelola interaksi scroll pada halaman detail kos.
///
/// State ini mengarahkan pengguna ke bagian kamar saat diperlukan.
class _KostDetailScreenState extends ConsumerState<KostDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _roomsSectionKey = GlobalKey();

  /// Menggulir halaman menuju bagian pilihan kamar.
  ///
  /// Method ini memudahkan pengguna langsung melihat kamar yang tersedia.
  void _scrollToRooms() {
    final context = _roomsSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final detailAsyncValue = ref.watch(kostDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: detailAsyncValue.when(
        data: (kost) => CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _ImageGallerySliver(kost: kost),
            _TitleLocationSliver(kost: kost),
            const _ThickDividerSliver(),
            _FacilitiesSliver(facilitiesStr: kost.facilities),
            const _ThickDividerSliver(),
            _RoomsSelectionSliver(kost: kost, sectionKey: _roomsSectionKey),
            const _ThickDividerSliver(),
            _DescriptionSliver(description: kost.description),
            const _ThickDividerSliver(),
            _LocationMapSliver(kost: kost),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Gagal memuat detail: $err')),
      ),
      bottomNavigationBar: detailAsyncValue.maybeWhen(
        data: (kost) => _StickyBottomBar(kost: kost, onScrollToRooms: _scrollToRooms),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

/// Menampilkan galeri gambar kos pada bagian atas halaman detail.
///
/// Widget ini memberi gambaran visual utama dari kos.
class _ImageGallerySliver extends ConsumerStatefulWidget {
  final KostModel kost;
  const _ImageGallerySliver({required this.kost});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<_ImageGallerySliver> createState() => _ImageGallerySliverState();
}

/// Mengelola state galeri gambar pada halaman detail kos.
///
/// State ini menjaga tampilan gambar tetap responsif terhadap interaksi pengguna.
class _ImageGallerySliverState extends ConsumerState<_ImageGallerySliver> {
  int _currentIndex = 0;

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final images = widget.kost.images;
    final isFav = ref.watch(favoriteProvider).contains(widget.kost.id);

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: images.isEmpty
                ? Container(color: Colors.grey[300])
                : PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                      );
                    },
                  ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularBtn(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
                Row(
                  children: [
                    _buildCircularBtn(
                      icon: isFav ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFav ? AppColors.error : AppColors.textPrimary,
                      onTap: () {
                        ref.read(favoriteProvider.notifier).toggleFavorite(widget.kost.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        NotificationUtils.show(
                          context,
                          message: isFav ? 'Dihapus dari favorit' : 'Disimpan ke favorit',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (images.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${images.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Membuat tombol ikon berbentuk lingkaran untuk aksi cepat.
  ///
  /// Method ini digunakan pada galeri dan aksi detail kos.
  Widget _buildCircularBtn({required IconData icon, Color iconColor = AppColors.textPrimary, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

/// Menampilkan nama, harga, dan lokasi kos dalam bentuk sliver.
///
/// Widget ini merangkum informasi utama kos.
class _TitleLocationSliver extends StatelessWidget {
  final KostModel kost;

  const _TitleLocationSliver({required this.kost});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Campur',
                style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              kost.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.2),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kost.address,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => context.push('/map', extra: {'lat': kost.latitude, 'lng': kost.longitude, 'name': kost.name}),
                        child: const Text(
                          'Lihat Peta',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan daftar fasilitas kos dalam bentuk sliver.
///
/// Widget ini membantu pengguna memahami fasilitas yang tersedia.
class _FacilitiesSliver extends StatelessWidget {
  final String facilitiesStr;

  const _FacilitiesSliver({required this.facilitiesStr});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final allFacilities = facilitiesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final previewFacilities = allFacilities.take(4).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fasilitas Populer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: previewFacilities.map((facility) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    facility,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Semua Fasilitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: allFacilities.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.check_circle, color: AppColors.primary),
                                    title: Text(allFacilities[index]),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Lihat Semua Fasilitas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan pilihan kamar yang dapat dipesan.
///
/// Widget ini menyediakan aksi booking untuk kamar yang tersedia.
class _RoomsSelectionSliver extends ConsumerWidget {
  final KostModel kost;
  final GlobalKey sectionKey;

  const _RoomsSelectionSliver({required this.kost, required this.sectionKey});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = kost.rooms ?? [];
    final selectedId = ref.watch(selectedRoomIdProvider);

    return SliverToBoxAdapter(
      key: sectionKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Tipe Kamar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (rooms.isEmpty)
              const Text('Belum ada kamar tersedia.', style: TextStyle(color: AppColors.textSecondary))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rooms.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final isAvailable = room.status == 'available';
                  final isSelected = selectedId == room.id;

                  return GestureDetector(
                    onTap: isAvailable ? () {
                      if (isSelected) {
                        ref.read(selectedRoomIdProvider.notifier).state = null;
                      } else {
                        ref.read(selectedRoomIdProvider.notifier).state = room.id;
                      }
                    } : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _RoomImageCarousel(images: room.images),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Kamar ${room.roomNumber}',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                            ),
                                          ),
                                          if (!isAvailable)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text('Penuh', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: CurrencyFormatter.toIDR(room.price),
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                              children: const [
                                                TextSpan(
                                                  text: '/bln',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isAvailable)
                                            Icon(
                                              isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                              size: 24,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isSelected) const InlineBookingForm(),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan carousel gambar untuk satu kamar.
///
/// Widget ini membantu pengguna melihat kondisi kamar lebih jelas.
class _RoomImageCarousel extends StatefulWidget {
  final List<String> images;

  const _RoomImageCarousel({required this.images});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  State<_RoomImageCarousel> createState() => _RoomImageCarouselState();
}

/// Mengelola state tampilan gambar kamar.
///
/// State ini menjaga perpindahan gambar tetap terkontrol.
class _RoomImageCarouselState extends State<_RoomImageCarousel> {
  int _currentIndex = 0;

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
        child: widget.images.isEmpty
            ? const Icon(Icons.bed, color: Colors.grey, size: 40)
            : Stack(
                children: [
                  PageView.builder(
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
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                  if (widget.images.length > 1)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_currentIndex + 1}/${widget.images.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Menampilkan deskripsi kos dalam bentuk sliver.
///
/// Widget ini memberi konteks tambahan sebelum pengguna memesan.
class _DescriptionSliver extends StatelessWidget {
  final String description;

  const _DescriptionSliver({required this.description});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
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

/// Menampilkan pratinjau lokasi kos pada peta.
///
/// Widget ini membantu pengguna memahami posisi kos.
class _LocationMapSliver extends StatelessWidget {
  final KostModel kost;

  const _LocationMapSliver({required this.kost});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/map', extra: {'lat': kost.latitude, 'lng': kost.longitude, 'name': kost.name}),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: AppColors.error, size: 40),
                    SizedBox(height: 8),
                    Text('Lihat Peta Lokasi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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

/// Menampilkan aksi utama yang tetap terlihat di bagian bawah detail kos.
///
/// Widget ini memudahkan pengguna lanjut ke bagian pemesanan.
class _StickyBottomBar extends ConsumerWidget {
  final KostModel kost;
  final VoidCallback onScrollToRooms;

  const _StickyBottomBar({required this.kost, required this.onScrollToRooms});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedRoomIdProvider);
    final rooms = kost.rooms ?? [];
    
    RoomModel? selectedRoom;
    if (selectedId != null) {
      try {
        selectedRoom = rooms.firstWhere((r) => r.id == selectedId);
      } catch (_) {}
    }

    final isLoading = ref.watch(bookingControllerProvider).isLoading;
    final duration = ref.watch(bookingDurationProvider);
    final startDate = ref.watch(bookingStartDateProvider);
    
    double totalPriceVal = 0;
    if (selectedRoom != null) {
      totalPriceVal = double.parse(selectedRoom.price) * duration;
    }

    ref.listen<AsyncValue>(bookingControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        NotificationUtils.show(
          context,
          message: state.error.toString(),
          type: SnackBarType.error,
        );
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedRoom != null ? 'Total Tagihan' : 'Mulai dari',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  RichText(
                    text: TextSpan(
                      text: CurrencyFormatter.toIDR(selectedRoom != null ? totalPriceVal : kost.minPrice),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      children: [
                        TextSpan(
                          text: selectedRoom != null ? '' : '/bln',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (selectedRoom != null) {
                  if (startDate == null) {
                    NotificationUtils.show(
                      context,
                      message: 'Pilih tanggal mulai terlebih dahulu.',
                      type: SnackBarType.error,
                    );
                    return;
                  }
                  
                  final formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
                  final notifier = ref.read(bookingControllerProvider.notifier);
                  final booking = await notifier.createBooking(selectedRoom.id, formattedDate, duration);
                  
                  if (booking != null && context.mounted) {
                    context.push('/payment/${booking.id}/${kost.id}', extra: booking.totalPrice);
                  }
                } else {
                  onScrollToRooms();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text(
                    selectedRoom != null ? 'Pesan Sekarang' : 'Pilih Kamar',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan pemisah tebal antarbagian detail kos.
///
/// Widget ini membuat struktur halaman lebih mudah dibaca.
class _ThickDividerSliver extends StatelessWidget {
  const _ThickDividerSliver();

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 8,
        color: AppColors.background,
      ),
    );
  }
}