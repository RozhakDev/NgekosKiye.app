import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/kost_list_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(kostListControllerProvider.notifier).fetchKosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kostListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NGEKOSKIYE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/profile')),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(kostListControllerProvider.notifier).fetchKosts(isRefresh: true),
        child: state.kosts.isEmpty && state.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : state.error != null && state.kosts.isEmpty
                ? Center(child: Text(state.error!))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.kosts.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.kosts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        );
                      }
                      
                      final kost = state.kosts[index];
                      return GestureDetector(
                        onTap: () => context.push('/kost/${kost.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: AppColors.surface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: kost.images.isNotEmpty
                                    ? Image.network(kost.images.first, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                                    : Container(color: Colors.grey, child: const Icon(Icons.image, size: 50)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(kost.name.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                    const SizedBox(height: 4),
                                    Text(kost.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    Text('Mulai dari ${CurrencyFormatter.toIDR(kost.minPrice)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}