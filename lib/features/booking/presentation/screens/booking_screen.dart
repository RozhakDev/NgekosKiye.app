import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../controllers/booking_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final int roomId;
  final int kostId;
  final double roomPrice;

  const BookingScreen({super.key, required this.roomId, required this.kostId, required this.roomPrice});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _startDate;
  int _duration = 1;

  void _pickDate() async {
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
    if (picked != null) setState(() => _startDate = picked);
  }

  void _submitBooking() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal mulai terlebih dahulu.'), backgroundColor: AppColors.error));
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_startDate!);
    final notifier = ref.read(bookingControllerProvider.notifier);
    
    final booking = await notifier.createBooking(widget.roomId, formattedDate, _duration);
    
    if (booking != null && mounted) {
      context.pushReplacement('/payment/${booking.id}/${widget.kostId}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingControllerProvider).isLoading;
    final total = widget.roomPrice * _duration;

    ref.listen<AsyncValue>(bookingControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('PESAN KAMAR')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('TANGGAL MULAI SEWA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_startDate == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy').format(_startDate!)),
                    const Icon(Icons.calendar_today_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('DURASI SEWA (BULAN)', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _duration,
              decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
              items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1} Bulan'))),
              onChanged: (val) => setState(() => _duration = val!),
            ),
            const Spacer(),
            const Divider(color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL PEMBAYARAN', style: TextStyle(color: AppColors.textSecondary)),
                Text(CurrencyFormatter.toIDR(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _submitBooking,
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('LANJUTKAN KE PEMBAYARAN'),
            ),
          ],
        ),
      ),
    );
  }
}