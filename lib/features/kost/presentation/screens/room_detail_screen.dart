import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../controllers/kost_list_controller.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../domain/kost_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/routing/app_router.dart';

/// Menyimpan tanggal mulai sewa yang dipilih pengguna.
///
/// Provider ini digunakan sementara selama pengguna berada di halaman detail kamar.
final roomBookingStartDateProvider = StateProvider.autoDispose<DateTime?>((ref) => null);
/// Menyimpan durasi sewa kamar yang dipilih pengguna.
///
/// Provider ini menjaga pilihan durasi tetap tersedia saat form diperbarui.
final roomBookingDurationProvider = StateProvider.autoDispose<int>((ref) => 1);

/// Menampilkan detail kamar beserta galeri, deskripsi, dan form pemesanan.
///
/// Widget ini membantu pengguna meninjau kamar sebelum membuat booking.
class RoomDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const RoomDetailScreen({super.key, required this.id});

  /// Membuat state yang mengelola interaksi halaman detail kamar.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

/// Mengelola state utama pada halaman detail kamar.
///
/// State ini memuat data kamar dan menyusun bagian-bagian detail dalam sliver.
class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Membangun tampilan detail kamar berdasarkan state data.
  ///
  /// Method ini menampilkan loading, error, atau konten kamar yang berhasil dimuat.
  @override
  Widget build(BuildContext context) {
    final detailAsyncValue = ref.watch(roomDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: detailAsyncValue.when(
        data: (room) => CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _RoomImageGallerySliver(images: room.images, status: room.status),
            _RoomTitleSliver(room: room),
            const _ThickDividerSliver(),
            _RoomDescriptionSliver(description: room.description),
            const _ThickDividerSliver(),
            if (room.status == 'available')
              _RoomBookingFormSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Gagal memuat detail kamar: $err')),
      ),
      bottomNavigationBar: detailAsyncValue.maybeWhen(
        data: (room) => _RoomStickyBottomBar(room: room),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

/// Menampilkan galeri gambar kamar dalam bentuk sliver.
///
/// Widget ini juga menampilkan status ketersediaan kamar.
class _RoomImageGallerySliver extends StatefulWidget {
  final List<String> images;
  final String status;
  const _RoomImageGallerySliver({required this.images, required this.status});

  /// Membuat state untuk mengelola posisi gambar galeri.
  ///
  /// Digunakan oleh Flutter agar indikator gambar dapat diperbarui.
  @override
  State<_RoomImageGallerySliver> createState() => _RoomImageGallerySliverState();
}

/// Mengelola state gambar aktif pada galeri kamar.
///
/// State ini memperbarui indikator saat pengguna berpindah gambar.
class _RoomImageGallerySliverState extends State<_RoomImageGallerySliver> {
  int _currentIndex = 0;

  /// Membangun tampilan galeri gambar kamar.
  ///
  /// Method ini menampilkan gambar kamar atau placeholder saat gambar kosong.
  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final isAvailable = widget.status == 'available';

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: images.isEmpty
                ? Container(color: Colors.grey[300], child: const Icon(Icons.bed, size: 64, color: Colors.grey))
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
            child: _buildCircularBtn(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAvailable ? AppColors.primary : AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isAvailable ? 'Tersedia' : 'Penuh',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
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
  /// Method ini digunakan untuk tombol kembali pada galeri kamar.
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

/// Menampilkan nomor kamar dan harga sewa dalam bentuk sliver.
///
/// Widget ini merangkum informasi utama kamar.
class _RoomTitleSliver extends StatelessWidget {
  final RoomModel room;

  const _RoomTitleSliver({required this.room});

  /// Membangun tampilan judul dan harga kamar.
  ///
  /// Method ini menyusun informasi ringkas agar mudah dibaca pengguna.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TIPE KAMAR',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamar ${room.roomNumber}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.2),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.toIDR(room.price),
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

/// Menampilkan deskripsi kamar dalam bentuk sliver.
///
/// Widget ini memberi konteks tambahan tentang kamar yang dipilih.
class _RoomDescriptionSliver extends StatelessWidget {
  final String description;

  const _RoomDescriptionSliver({required this.description});

  /// Membangun tampilan deskripsi kamar.
  ///
  /// Method ini menampilkan teks pengganti saat deskripsi belum tersedia.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi Kamar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              description.isEmpty ? 'Tidak ada deskripsi untuk kamar ini.' : description,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan form informasi sewa kamar dalam bentuk sliver.
///
/// Widget ini mengatur tanggal mulai dan durasi sewa sebelum booking dibuat.
class _RoomBookingFormSliver extends ConsumerWidget {
  /// Membangun form tanggal mulai dan durasi sewa.
  ///
  /// Method ini memperbarui provider saat pengguna mengubah pilihan.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(roomBookingStartDateProvider);
    final duration = ref.watch(roomBookingDurationProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Sewa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            const Text('Tanggal Mulai', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: AppColors.primary),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  ref.read(roomBookingStartDateProvider.notifier).state = picked;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      startDate == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy').format(startDate),
                      style: TextStyle(color: startDate == null ? AppColors.textSecondary : AppColors.textPrimary),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Durasi Sewa', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: duration,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1} Bulan'))),
              onChanged: (val) {
                if (val != null) ref.read(roomBookingDurationProvider.notifier).state = val;
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan ringkasan tagihan dan tombol pemesanan kamar.
///
/// Widget ini tetap berada di bawah layar agar aksi booking mudah dijangkau.
class _RoomStickyBottomBar extends ConsumerWidget {
  final RoomModel room;

  const _RoomStickyBottomBar({required this.room});

  /// Membangun bar bawah untuk total tagihan dan aksi pemesanan.
  ///
  /// Method ini memvalidasi tanggal mulai sebelum booking dikirim.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(bookingControllerProvider).isLoading;
    final duration = ref.watch(roomBookingDurationProvider);
    final startDate = ref.watch(roomBookingStartDateProvider);
    final isAvailable = room.status == 'available';
    
    double totalPriceVal = double.parse(room.price) * duration;

    ref.listen<AsyncValue>(bookingControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        NotificationUtils.show(context, message: state.error.toString(), type: SnackBarType.error);
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
                  const Text(
                    'Total Tagihan',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    CurrencyFormatter.toIDR(totalPriceVal),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: (!isAvailable || isLoading) ? null : () async {
                final isLoggedIn = ref.read(authStateProvider);
                if (!isLoggedIn) {
                  NotificationUtils.show(
                    context,
                    message: 'Silakan masuk terlebih dahulu untuk melakukan pemesanan.',
                    type: SnackBarType.info,
                  );
                  context.push('/login');
                  return;
                }

                if (startDate == null) {
                  NotificationUtils.show(context, message: 'Pilih tanggal mulai terlebih dahulu.', type: SnackBarType.error);
                  return;
                }
                
                final formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
                final notifier = ref.read(bookingControllerProvider.notifier);
                final booking = await notifier.createBooking(room.id, formattedDate, duration);
                
                if (booking != null && context.mounted) {
                  context.push('/payment/${booking.id}/${room.kostId}', extra: booking.totalPrice);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text(
                    isAvailable ? 'Pesan Sekarang' : 'Kamar Penuh',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan pemisah tebal antarbagian detail kamar.
///
/// Widget ini menjaga struktur halaman tetap rapi dan mudah dipindai.
class _ThickDividerSliver extends StatelessWidget {
  const _ThickDividerSliver();

  /// Membangun tampilan pemisah antarbagian.
  ///
  /// Method ini menghasilkan sliver sederhana dengan warna latar halaman.
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