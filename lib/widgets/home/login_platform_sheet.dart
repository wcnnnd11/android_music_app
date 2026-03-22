import 'package:flutter/material.dart';

/// 首页右上角“登录”按钮弹出的平台选择弹窗
/// 现在它的含义不是“平台已登录 / 未登录”
/// 而是：点击后给某个平台新增一个账号（模拟登录）
class LoginPlatformSheet extends StatelessWidget {
  final int qqAccountCount;
  final int neteaseAccountCount;
  final VoidCallback onTapAddQqAccount;
  final VoidCallback onTapAddNeteaseAccount;

  const LoginPlatformSheet({
    super.key,
    required this.qqAccountCount,
    required this.neteaseAccountCount,
    required this.onTapAddQqAccount,
    required this.onTapAddNeteaseAccount,
  });

 @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '选择登录平台',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildPlatformTile(
            context,
            title: 'QQ音乐',
            subtitle: '当前已添加 $qqAccountCount 个账号，点击新增一个模拟账号',
            icon: Icons.music_note,
            onTap: onTapAddQqAccount,
          ),
          const SizedBox(height: 12),

          _buildPlatformTile(
            context,
            title: '网易云音乐',
            subtitle: '当前已添加 $neteaseAccountCount 个账号，点击新增一个模拟账号',
            icon: Icons.library_music,
            onTap: onTapAddNeteaseAccount,
          ),
        ],
      ),
    ),
  );
}

 Widget _buildPlatformTile(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Ink(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.add_circle_outline,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ],
      ),
    ),
  );
}
}