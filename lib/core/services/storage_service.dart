import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<void> saveFavorite(String podcastId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    if (!favorites.contains(podcastId)) {
      favorites.add(podcastId);
      await prefs.setStringList('favorites', favorites);
    }
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }
}
