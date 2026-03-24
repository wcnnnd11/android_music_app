class AppConfig {
  /// ===== 启动 loading 配置 =====
  static const LoadingConfig loading = LoadingConfig(
    enable: true,
    image: 'assets/images/loading.jpg',
    text: '加载中...', // 先预留（UI 还没用）
  );

  /// ===== 公告配置 =====
  static const AnnouncementConfig announcement = AnnouncementConfig(
    enable: true,
    title: '公告',
    content: '''
这里写你的公告内容
可以很长
以后这里可以替换成远程数据
''',
  );
}

/// ===== Loading 配置 =====
class LoadingConfig {
  final bool enable;
  final String image;
  final String text;

  const LoadingConfig({
    required this.enable,
    required this.image,
    required this.text,
  });
}

/// ===== 公告配置 =====
class AnnouncementConfig {
  final bool enable;
  final String title;
  final String content;

  const AnnouncementConfig({
    required this.enable,
    required this.title,
    required this.content,
  });
}
