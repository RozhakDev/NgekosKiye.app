import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/kost_list_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';

class KostDetailScreen extends ConsumerWidget {
  final int id;
  const KostDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsyncValue = ref.watch(kostDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('DETAIL KOST')),
      body: detailAsyncValue.when(
        data: (kost) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: kost.images.isEmpty ? 1 : kost.images.length,
                  itemBuilder: (context, index) {
                    if (kost.images.isEmpty) return Container(color: Colors.grey);
                    return Image.network(kost.images[index], fit: BoxFit.cover);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kost.name.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(child: Text(kost.address, style: const TextStyle(color: AppColors.textSecondary))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/map', extra: {'lat': kost.latitude, 'lng': kost.longitude, 'name': kost.name}),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('LIHAT PETA'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    const Divider(height: 48, color: AppColors.border),
                    const Text('FASILITAS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(kost.facilities, style: const TextStyle(height: 1.5)),
                    const Divider(height: 48, color: AppColors.border),
                    const Text('KAMAR TERSEDIA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    ...(kost.rooms ?? []).map((room) => ListTile(
                          onTap: room.status == 'available' ? () {
                            context.push('/booking/${room.id}', extra: {
                              'kostId': kost.id,
                              'roomPrice': double.parse(room.price)
                            });
                          } : null,
                          contentPadding: EdgeInsets.zero,
                          title: Text('Kamar ${room.roomNumber}'),
                          subtitle: Text(room.status.toUpperCase(), style: TextStyle(color: room.status == 'available' ? Colors.green : AppColors.error, fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(CurrencyFormatter.toIDR(room.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Gagal memuat detail: $err')),
      ),
      bottomNavigationBar: detailAsyncValue.maybeWhen(
        data: (kost) {
          if (kost.rooms == null || kost.rooms!.isEmpty) return null;
          final room = kost.rooms!.first;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  context.push('/booking/${room.id}', extra: {
                    'kostId': kost.id,
                    'roomPrice': double.parse(room.price)
                  });
                },
                child: const Text('PESAN SEKARANG'),
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}