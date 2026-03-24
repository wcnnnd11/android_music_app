import 'playlist.dart';

class MusicAccount {
  final String id;
  final String nickname;
  final List<Playlist> playlists;

  /// 👇 新增
  final String? avatarUrl;

  const MusicAccount({
    required this.id,
    required this.nickname,
    required this.playlists,
    this.avatarUrl,
  });

  factory MusicAccount.fromJson(Map<String, dynamic> json) {
    final playlistsJson = json['playlists'] as List<dynamic>? ?? [];

    return MusicAccount(
      id: json['id'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      playlists: playlistsJson
          .map((item) => Playlist.fromJson(item as Map<String, dynamic>))
          .toList(),

      /// 👇 新增
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'playlists': playlists.map((playlist) => playlist.toJson()).toList(),

      /// 👇 新增
      'avatar_url': avatarUrl,
    };
  }
}
