import 'package:flutter/material.dart';
import '../../models/music_account.dart';
import '../../models/playlist.dart';

/// 通用平台歌单区域
/// 作用：
/// 1. 显示平台名称
/// 2. 显示当前账号昵称
/// 3. 点击右侧账号区域，弹出账号切换弹窗
/// 4. 展示当前账号的歌单列表
class MusicPlatformSection extends StatelessWidget {
  final String platformName;
  final MusicAccount currentAccount;
  final List<Playlist> playlists;
  final VoidCallback onTapAccountSwitcher;

  const MusicPlatformSection({
    super.key,
    required this.platformName,
    required this.currentAccount,
    required this.playlists, // ✅ 新增
    required this.onTapAccountSwitcher,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 平台标题 + 当前账号切换入口
        Row(
          children: [
            Expanded(
              child: Text(
                platformName,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87, // 修改了这里
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onTapAccountSwitcher,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12, // 修改了这里
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentAccount.nickname,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black, // 修改了这里
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more, // 修改了图标
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// 当前账号的歌单列表
        Column(
          children: playlists
              .map(
                (playlist) =>
                    _PlaylistCard(title: playlist.name, isDark: isDark),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final String title;
  final bool isDark;

  const _PlaylistCard({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white, // 修改了这里
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12, // 修改了这里
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12, // 修改了这里
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.queue_music, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black, // 修改了这里
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}
