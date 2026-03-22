//底部播放器（固定）
import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // 给底部播放器一点安全边距
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // 左侧封面
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              color: Colors.deepPurple.shade100,
              alignment: Alignment.center,
              child: const Icon(Icons.music_note),
            ),
          ),

          const SizedBox(width: 12),

          // 中间歌曲信息
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '晴天',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  '周杰伦',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 播放按钮
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow_rounded),
            iconSize: 32,
          ),

          // 播放列表按钮
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.queue_music_rounded),
          ),
        ],
      ),
    );
  }
}
