import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/booking_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/custom_empty_state.dart';

/// Menampilkan riwayat pemesanan pengguna.
///
/// Widget ini membantu pengguna melihat daftar booking yang pernah dibuat.
class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(bookingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Riwayat Pemesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: historyAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pemesanan.'));
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.refresh(bookingHistoryProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                
                String statusText;
                Color statusColor;
                
                switch (booking.status) {
                  case 'pending_payment':
                    statusText = 'Menunggu Pembayaran';
                    statusColor = Colors.orange;
                    break;
                  case 'waiting_verification':
                    statusText = 'Menunggu Verifikasi';
                    statusColor = Colors.blue;
                    break;
                  case 'paid':
                    statusText = 'Lunas';
                    statusColor = Colors.green;
                    break;
                  case 'rejected':
                    statusText = 'Ditolak';
                    statusColor = AppColors.error;
                    break;
                  default:
                    statusText = booking.status;
                    statusColor = AppColors.textSecondary;
                }

                return GestureDetector(
                  onTap: () {
                    if (booking.status == 'pending_payment') {
                      context.push('/payment/${booking.id}/${booking.kostId}', extra: booking.totalPrice);
                    } else {
                      context.push('/booking-detail/${booking.id}');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            border: const Border(bottom: BorderSide(color: AppColors.border)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${booking.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking.kostName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(booking.roomDetails, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Mulai Sewa', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.startDate.isNotEmpty ? booking.startDate : '-', 
                                        style: const TextStyle(fontWeight: FontWeight.w600)
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Total Tagihan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      const SizedBox(height: 2),
                                      Text(
                                        CurrencyFormatter.toIDR(booking.totalPrice), 
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (booking.status == 'pending_payment') ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.push('/payment/${booking.id}/${booking.kostId}', extra: booking.totalPrice);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Lanjutkan Pembayaran', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => CustomEmptyState(
          message: 'Gagal memuat riwayat: $err',
          onRetry: () => ref.refresh(bookingHistoryProvider.future),
        ),
      ),
    );
  }
}