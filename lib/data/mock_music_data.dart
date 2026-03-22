import '../models/music_account.dart';
import '../models/playlist.dart';

/// 首页模拟数据工厂
/// 作用：
/// 1. 统一生成 QQ / 网易云 模拟账号
/// 2. 统一管理假昵称和假歌单
/// 3. 后续如果接 API，这个文件可以整体替换掉
class MockMusicData {
  /// 构造一个 QQ 模拟账号
  static MusicAccount buildMockQqAccount(int index) {
    const nicknames = ['璃江QQ', '朋友A_QQ', '朋友B_QQ', '学习号_QQ', '收藏号_QQ'];

    final nickname = index < nicknames.length
        ? nicknames[index]
        : 'QQ用户${index + 1}';

    return MusicAccount(
      id: 'qq_$index',
      nickname: nickname,
      playlists: const [
        Playlist(
          id: 'qq_1',
          name: '我喜欢的音乐',
          coverUrl: 'https://picsum.photos/200',
        ),
        Playlist(
          id: 'qq_2',
          name: '深夜循环',
          coverUrl: 'https://picsum.photos/200',
        ),
        Playlist(
          id: 'qq_3',
          name: '学习专注',
          coverUrl: 'https://picsum.photos/200',
        ),
      ],
    );
  }

  /// 构造一个 网易云 模拟账号
  static MusicAccount buildMockNeteaseAccount(int index) {
    const nicknames = ['璃江网易', '朋友A_网易', '朋友B_网易', '学习号_网易', '收藏号_网易'];

    final nickname = index < nicknames.length
        ? nicknames[index]
        : '网易用户${index + 1}';

    return MusicAccount(
      id: 'netease_$index',
      nickname: nickname,
      playlists: const [
        Playlist(
          id: 'netease__1',
          name: '我喜欢的音乐',
          coverUrl: 'https://picsum.photos/200',
        ),
        Playlist(
          id: 'netease__2',
          name: '深夜循环',
          coverUrl: 'https://picsum.photos/200',
        ),
        Playlist(
          id: 'netease__3',
          name: '学习专注',
          coverUrl: 'https://picsum.photos/200',
        ),
      ],
    );
  }
}
