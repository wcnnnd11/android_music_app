import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/music_account.dart';
import '../models/playlist.dart';
import 'music_service.dart';

class ApiMusicService implements IMusicService {
  /// Android 模拟器访问宿主机
  static const String baseUrl = 'http://10.0.2.2:8000';

  final Map<String, String?> _currentAccountIdByPlatform = {
    MusicPlatforms.qq: null,
    MusicPlatforms.netease: null,
  };

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  @override
  Future<List<MusicAccount>> getAccounts(String platform) async {
    await init();

    try {
      final url = Uri.parse('$baseUrl/accounts');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('请求失败: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      final List list = jsonData['data'] ?? [];

      final filteredList = list.where((e) {
        final map = e as Map<String, dynamic>;
        return map['platform'] == platform;
      }).toList();

      final accounts = filteredList
          .map((e) => MusicAccount.fromJson(e as Map<String, dynamic>))
          .toList();

      final currentId = _currentAccountIdByPlatform[platform];

      if (accounts.isEmpty) {
        _currentAccountIdByPlatform[platform] = null;
      } else if (currentId == null ||
          !accounts.any((account) => account.id == currentId)) {
        _currentAccountIdByPlatform[platform] = accounts.first.id;
      }

      return accounts;
    } catch (e) {
      debugPrint('getAccounts error: $e');
      return [];
    }
  }

  @override
  Future<MusicAccount?> getCurrentAccount(String platform) async {
    await init();

    try {
      final accounts = await getAccounts(platform);
      if (accounts.isEmpty) return null;

      final currentId = _currentAccountIdByPlatform[platform];
      if (currentId == null) {
        _currentAccountIdByPlatform[platform] = accounts.first.id;
        return accounts.first;
      }

      try {
        return accounts.firstWhere((account) => account.id == currentId);
      } catch (_) {
        _currentAccountIdByPlatform[platform] = accounts.first.id;
        return accounts.first;
      }
    } catch (e) {
      debugPrint('getCurrentAccount error: $e');
      return null;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists(String platform) async {
    await init();

    try {
      final account = await getCurrentAccount(platform);
      if (account == null) return [];

      final url = Uri.parse('$baseUrl/playlists?account_id=${account.id}');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('请求失败: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      final List list = jsonData['data'] ?? [];

      return list
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getPlaylists error: $e');
      return [];
    }
  }

  @override
  Future<void> addAccount(String platform, MusicAccount account) async {
    await init();

    try {
      final url = Uri.parse('$baseUrl/accounts');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'platform': platform,
              'name': account.nickname,
              'avatarUrl': '',
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('新增账号失败: ${response.statusCode}');
      }

      final jsonData = json.decode(response.body);
      final data = jsonData['data'];

      if (data != null && data['id'] != null) {
        _currentAccountIdByPlatform[platform] = data['id'] as String;
      }
    } catch (e) {
      debugPrint('addAccount error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String platform, String accountId) async {
    await init();

    try {
      final url = Uri.parse('$baseUrl/accounts/$accountId');
      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('删除账号失败: ${response.statusCode}');
      }

      final currentId = _currentAccountIdByPlatform[platform];
      if (currentId == accountId) {
        _currentAccountIdByPlatform[platform] = null;
      }
    } catch (e) {
      debugPrint('deleteAccount error: $e');
      rethrow;
    }
  }

  @override
  Future<void> switchAccount(String platform, String accountId) async {
    await init();

    final accounts = await getAccounts(platform);
    final exists = accounts.any((account) => account.id == accountId);

    if (!exists) {
      throw FlutterError('切换失败：账号不存在，platform=$platform, accountId=$accountId');
    }

    _currentAccountIdByPlatform[platform] = accountId;
  }

  @override
  Future<bool> hasAccounts(String platform) async {
    await init();
    final accounts = await getAccounts(platform);
    return accounts.isNotEmpty;
  }
}
