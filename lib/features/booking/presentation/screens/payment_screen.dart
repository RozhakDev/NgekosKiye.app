import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../controllers/booking_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final int kostId;
  final String totalPrice;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.kostId,
    required this.totalPrice,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  File? _selectedImage;
  int? _selectedMethodId;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _uploadPayment() async {
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu.'), backgroundColor: AppColors.error));
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unggah bukti pembayaran terlebih dahulu.'), backgroundColor: AppColors.error));
      return;
    }
    
    final success = await ref.read(bookingControllerProvider.notifier).uploadPayment(widget.bookingId, _selectedImage!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bukti berhasil diunggah. Menunggu verifikasi.'), backgroundColor: Colors.black));
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider(widget.kostId));
    final isLoading = ref.watch(bookingControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bed, color: Colors.grey, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TIPE KAMAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0)),
                                const SizedBox(height: 4),
                                const Text('Kamar Pilihan Anda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                Text(
                                  CurrencyFormatter.toIDR(widget.totalPrice),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    paymentMethodsAsync.when(
                      data: (methods) => methods.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text('Belum ada metode pembayaran yang dikonfigurasi.', style: TextStyle(color: AppColors.textSecondary)),
                            )
                          : Column(
                              children: methods.map((m) {
                                final isSelected = _selectedMethodId == m.id;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedMethodId = m.id;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(m.name.toLowerCase().contains('qris') ? Icons.qr_code_scanner : Icons.account_balance, color: Colors.blue[700]),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    m.name.toLowerCase().contains('qris') ? 'Gopay, OVO, Dana, ShopeePay' : 'Transfer Manual / Otomatis',
                                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                            ),
                                          ],
                                        ),
                                        if (isSelected && m.image != null) ...[
                                          const Padding(
                                            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                                            child: Divider(color: AppColors.border),
                                          ),
                                          const Text('Scan kode QRIS di bawah ini:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              m.image!,
                                              width: 200,
                                              fit: BoxFit.contain,
                                              errorBuilder: (ctx, err, stack) => Container(
                                                width: 200,
                                                height: 200,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.broken_image, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      error: (e, st) => Text('Gagal memuat metode pembayaran: $e', style: const TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        const Text('Bukti Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Wajib diisi untuk konfirmasi pembayaran', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                    ),
                                    child: const Icon(Icons.cloud_upload_outlined, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Unggah Bukti', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  const Text('JPG, PNG maks 5MB', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Tagihan', style: TextStyle(color: AppColors.textPrimary)),
                        Text(CurrencyFormatter.toIDR(widget.totalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedImage == null || _selectedMethodId == null || isLoading) ? null : _uploadPayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Konfirmasi Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                      ),
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