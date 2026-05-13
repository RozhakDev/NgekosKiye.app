import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../controllers/booking_controller.dart';
import '../../../../core/theme/app_colors.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final int kostId;

  const PaymentScreen({super.key, required this.bookingId, required this.kostId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  File? _selectedImage;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _uploadPayment() async {
    if (_selectedImage == null) return;
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('PEMBAYARAN')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('METODE PEMBAYARAN TERSEDIA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            paymentMethodsAsync.when(
              data: (methods) => methods.isEmpty
                  ? const Text('Belum ada metode pembayaran diset.')
                  : Column(
                      children: methods.map((m) => Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                        color: AppColors.background,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (m.image != null) ...[
                                const SizedBox(height: 16),
                                Image.network(
                                  m.image!,
                                  height: 200,
                                  errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                const Text('Scan QRIS di atas', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ]
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, st) => Text('Gagal memuat: $e'),
            ),
            const Divider(height: 48, color: AppColors.border),
            const Text('UNGGAH BUKTI PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  color: AppColors.background,
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, size: 40, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('Pilih Gambar Bukti Transfer', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (_selectedImage == null || isLoading) ? null : _uploadPayment,
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('KIRIM BUKTI PEMBAYARAN'),
            ),
          ],
        ),
      ),
    );
  }
}