import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Menampilkan banner promosi yang bergulir otomatis.
///
/// Widget ini digunakan pada halaman utama untuk menarik
/// perhatian pengguna terhadap penawaran spesial.
class AnimatedPromoSlider extends StatefulWidget {
  const AnimatedPromoSlider({super.key});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  State<AnimatedPromoSlider> createState() => _AnimatedPromoSliderState();
}

/// Mengelola state animasi dan pergerakan carousel promosi.
///
/// State ini memastikan banner bergulir secara berkala
/// dan mereset waktu tunggu saat pengguna menggeser manual.
class _AnimatedPromoSliderState extends State<AnimatedPromoSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final List<Color> _colors = [AppColors.primary, AppColors.secondary, Colors.teal];
  final List<String> _titles = ['Diskon 25%', 'Cashback 15%', 'Hemat 20%'];
  final List<String> _badges = ['Pengguna Baru', 'Promo Spesial', 'Terbatas'];
  final List<String> _subtitles = [
    'Untuk pemesanan bulan pertama',
    'Minimal transaksi Rp 500rb',
    'Khusus kost area Banyumas'
  ];

  /// Menyiapkan pengaturan awal saat widget pertama kali dimuat.
  ///
  /// Method ini menginisialisasi controller halaman dan
  /// memulai siklus gulir otomatis.
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _startAutoPlay();
  }

  /// Memulai siklus pergeseran halaman secara otomatis.
  ///
  /// Fungsi ini mengatur timer untuk berpindah ke promo selanjutnya
  /// setiap beberapa detik.
  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _colors.length) {
          nextPage = 0;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
  }

  /// Membersihkan resource saat widget dihapus dari layar.
  ///
  /// Memastikan timer dihentikan agar tidak terjadi kebocoran memori.
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Membangun tampilan widget berdasarkan state saat ini.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai dengan data promosi.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            // Reset timer on manual swipe to prevent jerky movement
            _timer?.cancel();
            _startAutoPlay();
          },
          itemCount: _colors.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _colors[index],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.local_offer,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _badges[index],
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _titles[index],
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitles[index],
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                          ),
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

