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

  /// ===== 账号相关 =====
  Future<List<MusicAccount>> getAccounts(String platform);

  Future<MusicAccount?> getCurrentAccount(String platform);

  Future<void> addAccount(String platform, MusicAccount account);

  Future<void> deleteAccount(String platform, String accountId);

  Future<void> switchAccount(String platform, String accountId);

  Future<bool> hasAccounts(String platform);

  /// ===== 歌单相关 =====
  Future<List<Playlist>> getPlaylists(String platform);

  /// 获取某个歌单下的歌曲列表
  /// 这里先用 Map 过渡，后续如果稳定了，再单独抽 Song model
  Future<List<Map<String, dynamic>>> getPlaylistSongs(
    String platform,
    String playlistId, {
    int page = 1,
    int pageSize = 50,
  });

  /// ===== 搜索相关 =====
  /// 搜索歌曲/音乐资源
  /// 这里先统一返回 Map，避免当前阶段一次性新增过多 model 文件
  Future<List<Map<String, dynamic>>> searchSongs({
    required String keyword,
    String? platform,
    int page = 1,
    int pageSize = 20,
  });

  /// 获取歌曲详情
  Future<Map<String, dynamic>?> getSongDetail({
    required String platform,
    required String songId,
  });

  /// 获取歌曲可播放资源
  /// 典型返回可包含：
  /// - url
  /// - quality
  /// - expires_at
  /// - headers
  Future<Map<String, dynamic>?> getSongResource({
    required String platform,
    required String songId,
    String? quality,
  });
}
