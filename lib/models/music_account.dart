import 'playlist.dart';

/// 音乐账号模型
/// 作用：表示某个平台下的一个具体账号
class MusicAccount {
  /// 账号唯一标识
  final String id;

  /// 账号昵称
  final String nickname;

  /// 当前账号对应的歌单列表
  final List<Playlist> playlists;

  const MusicAccount({
    required this.id,
    required this.nickname,
    required this.playlists,
  });

  /// 从 JSON 构建 MusicAccount
  factory MusicAccount.fromJson(Map<String, dynamic> json) {
    final playlistsJson = json['playlists'] as List<dynamic>? ?? [];

    return MusicAccount(
      id: json['id'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      playlists: playlistsJson
          .map((item) => Playlist.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
    };
  }
}
