import 'package:flutter/foundation.dart';
import '../models/music_account.dart';
import '../models/playlist.dart';
import 'music_service.dart';

/// API 音乐服务（假接口版）
///
/// 职责：
/// 1. 用内存数据模拟真实接口
/// 2. 对外保持 API Service 的调用方式
/// 3. 内部仍按“原始数据 -> Model”思路组织
class ApiMusicService implements IMusicService {
  /// 平台 -> 原始账号 JSON 列表
  final Map<String, List<Map<String, dynamic>>> _accountJsonByPlatform = {
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

    _accountJsonByPlatform[MusicPlatforms.qq] = [
      {
        'id': 'qq_api_001',
        'nickname': 'QQ接口用户A',
        'playlists': [
          {
            'id': 'qq_p_1',
            'name': '接口歌单1',
            'coverUrl': 'https://picsum.photos/200',
          },
          {
            'id': 'qq_p_2',
            'name': '接口歌单2',
            'coverUrl': 'https://picsum.photos/200',
          },
        ],
      },
      {
        'id': 'qq_api_002',
        'nickname': 'QQ接口用户B',
        'playlists': [
          {
            'id': 'qq_p_3',
            'name': '收藏歌单',
            'coverUrl': 'https://picsum.photos/200',
          },
        ],
      },
    ];

    _accountJsonByPlatform[MusicPlatforms.netease] = [
      {
        'id': 'netease_api_001',
        'nickname': '网易接口用户A',
        'playlists': [
          {
            'id': 'netease_p_1',
            'name': '每日推荐',
            'coverUrl': 'https://picsum.photos/200',
          },
          {
            'id': 'netease_p_2',
            'name': '纯音乐收藏',
            'coverUrl': 'https://picsum.photos/200',
          },
        ],
      },
    ];

    _currentAccountIdByPlatform[MusicPlatforms.qq] = 'qq_api_001';
    _currentAccountIdByPlatform[MusicPlatforms.netease] = 'netease_api_001';

    _initialized = true;
  }

  @override
  Future<List<MusicAccount>> getAccounts(String platform) async {
    await init();
    final rawList = _accountJsonByPlatform[platform] ?? [];
    return rawList.map(MusicAccount.fromJson).toList();
  }

  @override
  Future<MusicAccount?> getCurrentAccount(String platform) async {
    await init();

    final rawList = _accountJsonByPlatform[platform] ?? [];
    final currentId = _currentAccountIdByPlatform[platform];

    if (currentId == null) return null;

    try {
      final json = rawList.firstWhere((item) => item['id'] == currentId);
      return MusicAccount.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists(String platform) async {
    await init();
    final account = await getCurrentAccount(platform);
    return account?.playlists ?? [];
  }

  @override
  Future<void> addAccount(String platform, MusicAccount account) async {
    await init();

    final list = _accountJsonByPlatform[platform];
    if (list == null) return;

    list.add(account.toJson());

    if (_currentAccountIdByPlatform[platform] == null) {
      _currentAccountIdByPlatform[platform] = account.id;
    }
  }

  @override
  Future<void> deleteAccount(String platform, String accountId) async {
    await init();

    final list = _accountJsonByPlatform[platform];
    if (list == null) return;

    list.removeWhere((item) => item['id'] == accountId);

    final currentId = _currentAccountIdByPlatform[platform];
    if (currentId == accountId) {
      if (list.isEmpty) {
        _currentAccountIdByPlatform[platform] = null;
      } else {
        _currentAccountIdByPlatform[platform] = list.first['id'] as String?;
      }
    }
  }

  @override
  Future<void> switchAccount(String platform, String accountId) async {
    await init();

    final list = _accountJsonByPlatform[platform] ?? [];
    final exists = list.any((item) => item['id'] == accountId);

    if (!exists) {
      throw FlutterError('切换失败：账号不存在，platform=$platform, accountId=$accountId');
    }

    _currentAccountIdByPlatform[platform] = accountId;
  }

  @override
  Future<bool> hasAccounts(String platform) async {
    await init();
    final list = _accountJsonByPlatform[platform] ?? [];
    return list.isNotEmpty;
  }
}
