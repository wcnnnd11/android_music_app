import 'package:flutter/material.dart';
import '../../models/music_platform_state.dart';
import 'music_platform_section.dart';

/// “我的歌单”总区域
/// 作用：
/// 1. 根据平台状态决定是否显示整个区域
/// 2. 组合 QQ / 网易云 等平台模块
/// 3. 只负责展示，不负责业务逻辑
class MyPlaylistPanel extends StatelessWidget {
  final MusicPlatformState qqPlatform;
  final MusicPlatformState neteasePlatform;
  final ValueChanged<MusicPlatformState> onTapPlatformAccountSwitcher;

  const MyPlaylistPanel({
    super.key,
    required this.qqPlatform,
    required this.neteasePlatform,
    required this.onTapPlatformAccountSwitcher,
  });

  @override
  Widget build(BuildContext context) {
    final qqCurrent = qqPlatform.currentAccount;
    final neteaseCurrent = neteasePlatform.currentAccount;

    /// 两个平台都没有账号，则整个区域不显示
    if (qqCurrent == null && neteaseCurrent == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的歌单',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (qqCurrent != null) ...[
          MusicPlatformSection(
            platformName: qqPlatform.platformName,
            currentAccount: qqCurrent,
            onTapAccountSwitcher: () =>
                onTapPlatformAccountSwitcher(qqPlatform),
          ),
          const SizedBox(height: 20),
        ],

        if (neteaseCurrent != null)
          MusicPlatformSection(
            platformName: neteasePlatform.platformName,
            currentAccount: neteaseCurrent,
            onTapAccountSwitcher: () =>
                onTapPlatformAccountSwitcher(neteasePlatform),
          ),
      ],
    );
  }
}
