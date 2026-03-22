/// 歌单模型
/// 作用：表示一个歌单对象
class Playlist {
  final String id;
  final String name;
  final String coverUrl;

  const Playlist({
    required this.id,
    required this.name,
    required this.coverUrl,
  });

  /// 从 JSON 构建 Playlist
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'coverUrl': coverUrl};
  }
}
