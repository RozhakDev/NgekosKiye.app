import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, Set<int>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<Set<int>> {
  FavoriteNotifier() : super({}) {
    _loadFavorites();
  }

  static const String _prefsKey = 'favorite_kosts';

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

  bool isFavorite(int kostId) {
    return state.contains(kostId);
  }
}