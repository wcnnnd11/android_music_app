import 'package:flutter/material.dart';
import '../models/music_platform_state.dart';
import '../models/music_account.dart';
import '../services/music_service.dart';
import '../models/playlist.dart';
import '../services/api_music_service.dart';

/// 首页控制器
///
/// 职责：
/// 1. 管理两个平台的页面状态
/// 2. 调用 Service 获取数据
/// 3. 负责状态同步 + 通知 UI 更新
class HomeController extends ChangeNotifier {
  final IMusicService _musicService = ApiMusicService();

  /// QQ音乐平台状态
  late final MusicPlatformState qqPlatform;

  /// 网易云音乐平台状态
  late final MusicPlatformState neteasePlatform;

  HomeController() {
    qqPlatform = MusicPlatformState(
      platformKey: 'qq',
      platformName: 'QQ音乐',
      accounts: [],
      playlists: [],
    );

    neteasePlatform = MusicPlatformState(
      platformKey: 'netease',
      platformName: '网易云音乐',
      accounts: [],
      playlists: [],
    );

    init();
  }

  /// 初始化
  Future<void> init() async {
    await _musicService.init();
    await refreshAll();
  }

  /// 是否任意平台存在账号
  bool get hasAnyAccount {
    return qqPlatform.hasAccounts || neteasePlatform.hasAccounts;
  }

  /// 获取平台
  MusicPlatformState getPlatformByKey(String platformKey) {
    if (platformKey == 'qq') {
      return qqPlatform;
    }
    return neteasePlatform;
  }

  /// 统一刷新所有平台状态
  Future<void> refreshAll() async {
    final qqAccounts = await _musicService.getAccounts('qq');
    final qqCurrent = await _musicService.getCurrentAccount('qq');
    final qqPlaylists = await _musicService.getPlaylists('qq'); // ✅ 新增
    qqPlatform.playlists
      ..clear()
      ..addAll(qqPlaylists);

    qqPlatform.accounts
      ..clear()
      ..addAll(qqAccounts);
    qqPlatform.currentAccountId = qqCurrent?.id;

    final neteaseAccounts = await _musicService.getAccounts('netease');
    final neteaseCurrent = await _musicService.getCurrentAccount('netease');
    final neteasePlaylists = await _musicService.getPlaylists('netease');
    neteasePlatform.playlists
      ..clear()
      ..addAll(neteasePlaylists);

    neteasePlatform.accounts
      ..clear()
      ..addAll(neteaseAccounts);
    neteasePlatform.currentAccountId = neteaseCurrent?.id;

    notifyListeners();
  }

  /// 新增模拟账号
  Future<void> addMockAccount(String platformKey) async {
    final newAccount = MusicAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nickname: platformKey == 'qq' ? 'QQ新用户' : '网易新用户',
      playlists: const [
        Playlist(
          id: 'default_1',
          name: '默认歌单',
          coverUrl: 'https://picsum.photos/200',
        ),
      ],
    );

    await _musicService.addAccount(platformKey, newAccount);
    await refreshAll();
  }

  /// 切换账号
  Future<void> switchAccount({
    required MusicPlatformState platform,
    required String accountId,
  }) async {
    await _musicService.switchAccount(platform.platformKey, accountId);
    await refreshAll();
  }

  /// 删除账号
  Future<void> deleteAccount({
    required MusicPlatformState platform,
    required String accountId,
  }) async {
    await _musicService.deleteAccount(platform.platformKey, accountId);
    await refreshAll();
  }
}
