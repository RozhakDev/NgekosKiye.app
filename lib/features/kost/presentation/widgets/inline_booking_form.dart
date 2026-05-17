import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../screens/kost_detail_screen.dart';

class InlineBookingForm extends ConsumerWidget {
  const InlineBookingForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(bookingStartDateProvider);
    final duration = ref.watch(bookingDurationProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Sewa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                  ref.read(bookingStartDateProvider.notifier).state = picked;
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
                if (val != null) ref.read(bookingDurationProvider.notifier).state = val;
              },
            ),
          ],
        ),
      ),
    );
  }
}