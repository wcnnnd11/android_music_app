import 'package:flutter/foundation.dart';
import '../models/music_account.dart';
import 'music_service.dart';
import '../models/playlist.dart';

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
}
