import 'music_account.dart';
import 'playlist.dart';

/// 音乐平台状态模型
/// 作用：管理一个平台下的所有账号，以及“当前账号”是谁
class MusicPlatformState {
  /// 平台标识，例如：qq / netease
  final String platformKey;

  /// 平台展示名称，例如：QQ音乐 / 网易云音乐
  final String platformName;

  /// 当前平台下登录的所有账号
  final List<MusicAccount> accounts;

  /// 当前选中的账号 id
  String? currentAccountId;

  /// 当前账号对应歌单
  final List<Playlist> playlists;

  MusicPlatformState({
    required this.platformKey,
    required this.platformName,
    required this.accounts,
    required this.playlists,
    this.currentAccountId,
  });

  /// 当前账号对象
  MusicAccount? get currentAccount {
    if (currentAccountId == null) return null;

    try {
      return accounts.firstWhere((account) => account.id == currentAccountId);
    } catch (_) {
      return null;
    }
  }

  /// 当前平台是否至少有一个账号
  bool get hasAccounts => accounts.isNotEmpty;
}
