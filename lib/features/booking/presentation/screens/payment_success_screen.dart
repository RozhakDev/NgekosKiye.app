import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Menampilkan konfirmasi setelah bukti pembayaran berhasil dikirim.
///
/// Widget ini memberi ringkasan status pembayaran kepada pengguna.
class PaymentSuccessScreen extends StatelessWidget {
  final String totalPrice;

  const PaymentSuccessScreen({
    super.key,
    required this.totalPrice,
  });

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(now);
    final trxId = 'TRX-${DateFormat('yyyyMMdd').format(now)}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Pembayaran Berhasil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pembayaran Anda telah berhasil\ndikonfirmasi. Detail transaksi dapat dilihat\npada ringkasan di bawah ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    
                    _buildInfoRow('Status', 'Berhasil', valueColor: AppColors.primary, isBold: true),
                    const SizedBox(height: 12),
                    _buildInfoRow('Metode Pembayaran', 'QRIS / Transfer'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Tanggal Pembayaran', '$formattedDate WIB'),
                    const SizedBox(height: 12),
                    _buildInfoRow('ID Transaksi', trxId),
                    const SizedBox(height: 12),
                    _buildInfoRow('Tipe Kamar', 'Kamar Pilihan Anda'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Bukti Transfer', 'Sudah Diunggah'),
                    
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        Text(
                          CurrencyFormatter.toIDR(totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Pesanan Anda akan segera diproses. Anda dapat\nmemantau status pesanan melalui halaman detail\npesanan atau riwayat pemesanan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () => context.go('/history'),
                child: const Text('Lihat Detail Pesanan'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menampilkan satu baris informasi dengan label dan nilai.
  ///
  /// Method ini menjaga format detail tetap konsisten.
  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}