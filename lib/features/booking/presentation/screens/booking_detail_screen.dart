import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/booking_controller.dart';

/// Menampilkan detail lengkap dari satu pemesanan.
///
/// Widget ini memperlihatkan status, kamar, harga, dan informasi pembayaran.
class BookingDetailScreen extends ConsumerWidget {
  final int id;
  const BookingDetailScreen({super.key, required this.id});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(bookingDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: detailAsync.when(
        data: (booking) {
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status Pesanan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text('Informasi Kamar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.kostName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.bed, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(booking.roomDetails, style: const TextStyle(color: AppColors.textPrimary))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text('Rincian Sewa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('ID Pesanan', '#${booking.id}'),
                      const Divider(color: AppColors.border, height: 24),
                      _buildInfoRow('Mulai Sewa', booking.startDate.isNotEmpty ? booking.startDate : '-'),
                      const Divider(color: AppColors.border, height: 24),
                      _buildInfoRow('Durasi', '${booking.durationMonths} Bulan'),
                      const Divider(color: AppColors.border, height: 24),
                      _buildInfoRow('Total Tagihan', CurrencyFormatter.toIDR(booking.totalPrice), isBold: true, valueColor: AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (booking.paymentProof != null) ...[
                  const Text('Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Diunggah pada: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(booking.paymentProof!.uploadedAt))}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                          child: Image.network(
                            booking.paymentProof!.image,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Gagal memuat detail pesanan: $err')),
      ),
    );
  }

  /// Menampilkan satu baris informasi dengan label dan nilai.
  ///
  /// Method ini menjaga format detail tetap konsisten.
  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}