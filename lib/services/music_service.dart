import '../models/music_account.dart';
import '../models/playlist.dart';

/// 平台标识常量
class MusicPlatforms {
  static const String qq = 'qq';
  static const String netease = 'netease';

  static const List<String> values = [qq, netease];
}

/// 音乐服务抽象接口
abstract class IMusicService {
  Future<void> init();

  Future<List<MusicAccount>> getAccounts(String platform);

  Future<MusicAccount?> getCurrentAccount(String platform);

  Future<List<Playlist>> getPlaylists(String platform);

  Future<void> addAccount(String platform, MusicAccount account);

  Future<void> deleteAccount(String platform, String accountId);

  Future<void> switchAccount(String platform, String accountId);

  Future<bool> hasAccounts(String platform);
}
