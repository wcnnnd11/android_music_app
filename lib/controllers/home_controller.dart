import 'package:flutter/material.dart';
import '../models/music_platform_state.dart';
import '../models/music_account.dart';
import '../services/music_service.dart';
import '../models/playlist.dart';
import '../services/api_music_service.dart';

class HomeController extends ChangeNotifier {
  final IMusicService _musicService = ApiMusicService();

  bool isInitializing = false; // 启动 loading（全屏图）
  bool isOperating = false; // 操作 loading（转圈）
  String? errorMessage;

  static const Duration _minLaunchDuration = Duration(
    milliseconds: 3000,
  ); // 最短启动展示时间

  static const Duration _startupTimeout = Duration(seconds: 5); // 启动阶段超时保护

  late final MusicPlatformState qqPlatform;
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
  }

  /// 初始化（启动 loading）
  Future<void> init() async {
    final startTime = DateTime.now();

    try {
      isInitializing = true;
      errorMessage = null;
      notifyListeners();

      await _musicService.init().timeout(_startupTimeout);
      await fetchRemoteConfig().timeout(_startupTimeout);
      await refreshAll(isInit: true).timeout(_startupTimeout);

      final elapsed = DateTime.now().difference(startTime);
      final remaining = _minLaunchDuration - elapsed;

      if (remaining > Duration.zero) {
        await Future.delayed(remaining); // 保证最短展示时间
      }
    } catch (e) {
      errorMessage = '启动失败：$e';

      final elapsed = DateTime.now().difference(startTime);
      final remaining = _minLaunchDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining); // 保证最短展示时间
      }
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  bool get hasAnyAccount {
    return qqPlatform.hasAccounts || neteasePlatform.hasAccounts;
  }

  MusicAccount? get currentAccount {
    // 先看 QQ
    if (qqPlatform.currentAccountId != null) {
      try {
        return qqPlatform.accounts.firstWhere(
          (acc) => acc.id == qqPlatform.currentAccountId,
        );
      } catch (_) {}
    }

    // 再看网易
    if (neteasePlatform.currentAccountId != null) {
      try {
        return neteasePlatform.accounts.firstWhere(
          (acc) => acc.id == neteasePlatform.currentAccountId,
        );
      } catch (_) {}
    }

    return null;
  }

  MusicPlatformState getPlatformByKey(String platformKey) {
    if (platformKey == 'qq') {
      return qqPlatform;
    }
    return neteasePlatform;
  }

  /// 刷新
  Future<void> refreshAll({bool isInit = false}) async {
    try {
      if (!isInit) {
        isOperating = true;
        notifyListeners();
      }

      errorMessage = null;

      final qqAccounts = await _musicService
          .getAccounts('qq')
          .timeout(_startupTimeout);
      final qqCurrent = await _musicService
          .getCurrentAccount('qq')
          .timeout(_startupTimeout);
      final qqPlaylists = await _musicService
          .getPlaylists('qq')
          .timeout(_startupTimeout);

      qqPlatform.playlists
        ..clear()
        ..addAll(qqPlaylists);

      qqPlatform.accounts
        ..clear()
        ..addAll(qqAccounts);

      qqPlatform.currentAccountId = qqCurrent?.id;

      final neteaseAccounts = await _musicService
          .getAccounts('netease')
          .timeout(_startupTimeout);
      final neteaseCurrent = await _musicService
          .getCurrentAccount('netease')
          .timeout(_startupTimeout);
      final neteasePlaylists = await _musicService
          .getPlaylists('netease')
          .timeout(_startupTimeout);

      neteasePlatform.playlists
        ..clear()
        ..addAll(neteasePlaylists);

      neteasePlatform.accounts
        ..clear()
        ..addAll(neteaseAccounts);

      neteasePlatform.currentAccountId = neteaseCurrent?.id;
    } catch (e) {
      errorMessage = '数据加载失败：$e';
    } finally {
      if (!isInit) {
        isOperating = false;
        notifyListeners();
      }
    }
  }

  /// 新增账号
  Future<void> addMockAccount(String platformKey) async {
    try {
      isOperating = true;
      errorMessage = null;
      notifyListeners();

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
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isOperating = false;
      notifyListeners();
    }
  }

  /// 切换账号
  Future<void> switchAccount({
    required MusicPlatformState platform,
    required String accountId,
  }) async {
    try {
      isOperating = true;
      errorMessage = null;
      notifyListeners();

      await _musicService.switchAccount(platform.platformKey, accountId);
      await refreshAll();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isOperating = false;
      notifyListeners();
    }
  }

  /// 删除账号
  Future<void> deleteAccount({
    required MusicPlatformState platform,
    required String accountId,
  }) async {
    try {
      isOperating = true;
      errorMessage = null;
      notifyListeners();

      await _musicService.deleteAccount(platform.platformKey, accountId);
      await refreshAll();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isOperating = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? remoteConfig;
  Future<void> fetchRemoteConfig() async {
    try {
      final config = await (_musicService as ApiMusicService).getRemoteConfig();
      if (config != null) {
        remoteConfig = config;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchRemoteConfig error: $e');
    }
  }
}
