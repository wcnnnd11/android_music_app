import 'package:flutter/material.dart';

class HomeSearchResultSection extends StatelessWidget {
  final String keyword;
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final ValueChanged<String> onSongTap; // 点击歌曲的回调

  const HomeSearchResultSection({
    super.key,
    required this.keyword,
    required this.results,
    required this.isLoading,
    required this.onSongTap, // 传递点击事件
  });

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '搜索结果',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          '关键词：$keyword',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        /// 加载中
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          )
        /// 无结果
        else if (results.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text(
              '暂无搜索结果',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        /// 有结果
        else
          Column(
            children: results
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => onSongTap(item['id']), // 触发点击事件
                      child: _SearchResultCard(item: item),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _SearchResultCard({required this.item});

  String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = item['title'] ?? '';
    final artist = item['artist'] ?? '';
    final duration = item['duration'] ?? 0;
    final quality = item['quality']?.join('/') ?? 'Standard';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.music_note_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(artist),
                    const SizedBox(width: 8),
                    Text(formatDuration(duration)),
                    const SizedBox(width: 8),
                    Text(quality, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
