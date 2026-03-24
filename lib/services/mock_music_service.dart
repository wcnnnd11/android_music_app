import 'package:flutter/foundation.dart';

import '../models/music_account.dart';
import '../models/playlist.dart';
import 'music_service.dart';

/// Mock 音乐服务
///
/// 职责：
/// 1. 提供当前开发阶段的模拟数据
/// 2. 模拟账号新增、删除、切换等行为
/// 3. 后续可被 ApiMusicService 替换
class MockMusicService implements IMusicService {
  MockMusicService._internal();

  static final MockMusicService instance = MockMusicService._internal();

  /// 平台 -> 账号列表
  final Map<String, List<MusicAccount>> _accountsByPlatform = {
    MusicPlatforms.qq: [],
    MusicPlatforms.netease: [],
  };

  /// 平台 -> 当前账号 id
  final Map<String, String?> _currentAccountIdByPlatform = {
    MusicPlatforms.qq: null,
    MusicPlatforms.netease: null,
  };

  static const List<Map<String, dynamic>> _mockSearchSongs = [
    {
      'id': 'qq_song_001',
      'platform': MusicPlatforms.qq,
      'title': '夜曲',
      'artist': '周杰伦',
      'album': '十一月的萧邦',
      'subtitle': '周杰伦 · 十一月的萧邦',
    },
    {
      'id': 'qq_song_002',
      'platform': MusicPlatforms.qq,
      'title': '晴天',
      'artist': '周杰伦',
      'album': '叶惠美',
      'subtitle': '周杰伦 · 叶惠美',
    },
    {
      'id': 'qq_song_003',
      'platform': MusicPlatforms.qq,
      'title': '稻香',
      'artist': '周杰伦',
      'album': '魔杰座',
      'subtitle': '周杰伦 · 魔杰座',
    },
    {
      'id': 'qq_song_004',
      'platform': MusicPlatforms.qq,
      'title': '七里香',
      'artist': '周杰伦',
      'album': '七里香',
      'subtitle': '周杰伦 · 七里香',
    },
    {
      'id': 'netease_song_001',
      'platform': MusicPlatforms.netease,
      'title': '演员',
      'artist': '薛之谦',
      'album': '绅士',
      'subtitle': '薛之谦 · 绅士',
    },
    {
      'id': 'netease_song_002',
      'platform': MusicPlatforms.netease,
      'title': '起风了',
      'artist': '买辣椒也用券',
      'album': '起风了',
      'subtitle': '买辣椒也用券 · 起风了',
    },
    {
      'id': 'netease_song_003',
      'platform': MusicPlatforms.netease,
      'title': '光年之外',
      'artist': '邓紫棋',
      'album': '光年之外',
      'subtitle': '邓紫棋 · 光年之外',
    },
  ];

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    _accountsByPlatform[MusicPlatforms.qq] = [
      const MusicAccount(
        id: 'qq_001',
        nickname: 'QQ用户A',
        playlists: [
          Playlist(id: '1', name: '我喜欢的音乐', coverUrl: 'xxx'),
          Playlist(id: '2', name: '深夜循环', coverUrl: 'xxx'),
          Playlist(id: '3', name: '学习专注', coverUrl: 'xxx'),
        ],
      ),
      const MusicAccount(
        id: 'qq_002',
        nickname: 'QQ用户B',
        playlists: [
          Playlist(id: '1', name: '热歌收藏', coverUrl: 'xxx'),
          Playlist(id: '2', name: '轻音乐', coverUrl: 'xxx'),
        ],
      ),
    ];

    _accountsByPlatform[MusicPlatforms.netease] = [
      const MusicAccount(
        id: 'netease_001',
        nickname: '网易用户A',
        playlists: [
          Playlist(id: '1', name: '每日推荐收藏', coverUrl: 'xxx'),
          Playlist(id: '2', name: '民谣', coverUrl: 'xxx'),
          Playlist(id: '3', name: '纯音乐', coverUrl: 'xxx'),
        ],
      ),
    ];

    _currentAccountIdByPlatform[MusicPlatforms.qq] = 'qq_001';
    _currentAccountIdByPlatform[MusicPlatforms.netease] = 'netease_001';

    _initialized = true;
  }

  @override
  Future<List<MusicAccount>> getAccounts(String platform) async {
    await init();
    return List<MusicAccount>.from(_accountsByPlatform[platform] ?? []);
  }

  @override
  Future<MusicAccount?> getCurrentAccount(String platform) async {
    await init();

    final accounts = _accountsByPlatform[platform] ?? [];
    final currentId = _currentAccountIdByPlatform[platform];

    if (currentId == null) return null;

    try {
      return accounts.firstWhere((account) => account.id == currentId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists(String platform) async {
    await init();

    final currentAccount = await getCurrentAccount(platform);
    if (currentAccount == null) return [];

    return List<Playlist>.from(currentAccount.playlists);
  }

  @override
  Future<void> addAccount(String platform, MusicAccount account) async {
    await init();

    final list = _accountsByPlatform[platform];
    if (list == null) return;

    list.add(account);

    if (_currentAccountIdByPlatform[platform] == null) {
      _currentAccountIdByPlatform[platform] = account.id;
    }
  }

  @override
  Future<void> deleteAccount(String platform, String accountId) async {
    await init();

    final list = _accountsByPlatform[platform];
    if (list == null) return;

    list.removeWhere((account) => account.id == accountId);

    final currentId = _currentAccountIdByPlatform[platform];

    if (currentId == accountId) {
      if (list.isEmpty) {
        _currentAccountIdByPlatform[platform] = null;
      } else {
        _currentAccountIdByPlatform[platform] = list.first.id;
      }
    }
  }

  @override
  Future<void> switchAccount(String platform, String accountId) async {
    await init();

    final list = _accountsByPlatform[platform] ?? [];
    final exists = list.any((account) => account.id == accountId);

    if (!exists) {
      throw FlutterError('切换失败：账号不存在，platform=$platform, accountId=$accountId');
    }

    _currentAccountIdByPlatform[platform] = accountId;
  }

  @override
  Future<bool> hasAccounts(String platform) async {
    await init();
    final list = _accountsByPlatform[platform] ?? [];
    return list.isNotEmpty;
  }

  @override
  Future<List<Map<String, dynamic>>> getPlaylistSongs(
    String platform,
    String playlistId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    await init();

    return _mockSearchSongs
        .where((song) => song['platform'] == platform)
        .skip((page - 1) * pageSize)
        .take(pageSize)
        .map((song) => Map<String, dynamic>.from(song))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> searchSongs({
    required String keyword,
    String? platform,
    int page = 1,
    int pageSize = 20,
  }) async {
    await init();

    final normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) return [];

    final filtered = _mockSearchSongs.where((song) {
      final matchesPlatform = platform == null || song['platform'] == platform;
      final title = (song['title'] ?? '').toString().toLowerCase();
      final subtitle = (song['subtitle'] ?? '').toString().toLowerCase();
      final artist = (song['artist'] ?? '').toString().toLowerCase();
      final album = (song['album'] ?? '').toString().toLowerCase();

      return matchesPlatform &&
          (title.contains(normalizedKeyword) ||
              subtitle.contains(normalizedKeyword) ||
              artist.contains(normalizedKeyword) ||
              album.contains(normalizedKeyword));
    }).toList();

    return filtered
        .skip((page - 1) * pageSize)
        .take(pageSize)
        .map((song) => Map<String, dynamic>.from(song))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> getSongDetail({
    required String platform,
    required String songId,
  }) async {
    await init();

    try {
      final song = _mockSearchSongs.firstWhere(
        (item) => item['platform'] == platform && item['id'] == songId,
      );
      return Map<String, dynamic>.from(song);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getSongResource({
    required String platform,
    required String songId,
    String? quality,
  }) async {
    await init();

    final detail = await getSongDetail(platform: platform, songId: songId);
    if (detail == null) return null;

    return {
      'song_id': songId,
      'platform': platform,
      'quality': quality ?? 'standard',
      'url': 'https://example.com/mock/$platform/$songId.mp3',
      'expires_at': null,
      'headers': <String, String>{},
    };
  }
}
