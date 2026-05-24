import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, Set<int>>((ref) {
  return FavoriteNotifier();
});

/// Mengelola daftar kos favorit yang tersimpan di perangkat.
///
/// Class ini membuat status favorit dapat digunakan ulang oleh tampilan.
class FavoriteNotifier extends StateNotifier<Set<int>> {
  FavoriteNotifier() : super({}) {
    _loadFavorites();
  }

  static const String _prefsKey = 'favorite_kosts';

  /// Memuat daftar kos favorit dari penyimpanan lokal.
  ///
  /// Method ini dijalankan saat notifier pertama kali dibuat.
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedFavs = prefs.getStringList(_prefsKey);
      if (savedFavs != null) {
        state = savedFavs.map((e) => int.parse(e)).toSet();
      }
    } catch (e) {
      //
    }
  }

  /// Menambah atau menghapus kos dari daftar favorit.
  ///
  /// Method ini memperbarui data lokal dan state tampilan.
  Future<void> toggleFavorite(int kostId) async {
    final newFavorites = Set<int>.from(state);

    if (newFavorites.contains(kostId)) {
      newFavorites.remove(kostId);
    } else {
      newFavorites.add(kostId);
    }

    state = newFavorites;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, newFavorites.map((e) => e.toString()).toList());
    } catch (e) {
      //
    }
  }

  /// Memeriksa apakah kos termasuk dalam daftar favorit.
  ///
  /// Nilai benar menunjukkan kos sudah disimpan pengguna.
  bool isFavorite(int kostId) {
    return state.contains(kostId);
  }
}