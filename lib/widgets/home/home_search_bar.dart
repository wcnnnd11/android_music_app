import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '搜索歌曲、歌手、专辑',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(width: 8),

          /// ✅ 右侧“搜索”文字按钮
          GestureDetector(
            onTap: () {
              debugPrint('点击搜索');
            },
            child: Text(
              '搜索',
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : Colors.black87.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
