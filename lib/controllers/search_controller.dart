import 'package:flutter/material.dart';

import '../services/api_music_service.dart';
import '../services/music_service.dart';

class SearchController extends ChangeNotifier {
  final IMusicService _musicService = ApiMusicService();

  String? keyword;
  bool isSearching = false;
  List<Map<String, dynamic>> results = [];
  String? errorMessage;

  bool get isInSearchMode {
    return keyword != null && keyword!.trim().isNotEmpty;
  }

  Future<void> search(String input) async {
    final normalized = input.trim();

    if (normalized.isEmpty) {
      clear();
      return;
    }

    try {
      keyword = normalized;
      isSearching = true;
      errorMessage = null;
      notifyListeners();

      final res = await _musicService.searchSongs(keyword: normalized);

      results = res;
    } catch (e) {
      results = [];
      errorMessage = '搜索失败：$e';
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void clear() {
    keyword = null;
    results = [];
    isSearching = false;
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }
}
