import 'package:flutter/material.dart';

class HomeSearchResultSection extends StatelessWidget {
  final String keyword;
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final ValueChanged<Map<String, dynamic>> onSongTap;

  /// 当前播放歌曲 id
  final String? currentPlayingId;

  /// 是否正在播放
  final bool isPlaying;

  /// 新增：点击某个音质后的回调
  final void Function(Map<String, dynamic> song, String quality)? onQualityTap;

  const HomeSearchResultSection({
    super.key,
    required this.keyword,
    required this.results,
    required this.isLoading,
    required this.onSongTap,
    this.currentPlayingId,
    this.isPlaying = false,
    this.onQualityTap,
  });

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showQualityOptions(BuildContext context, Map<String, dynamic> item) {
    final rawQualities = item['quality'];
    final qualities = rawQualities is List
        ? rawQualities.map((e) => e.toString()).toList()
        : <String>[];

    if (qualities.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < qualities.length; i++) ...[
                ListTile(
                  title: Center(
                    child: Text(
                      qualities[i],
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onQualityTap?.call(item, qualities[i]);
                  },
                ),
                if (i != qualities.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
              ],
            ],
          ),
        );
      },
    );
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
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          )
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
        else
          Column(
            children: results.map((item) {
              final id = item['id']?.toString();
              final isCurrent = id != null && id == currentPlayingId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSongTap(item),
                    onLongPress: () => _showQualityOptions(context, item),
                    child: _SearchResultCard(
                      item: item,
                      isActive: isCurrent,
                      isPlaying: isCurrent && isPlaying,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isActive;
  final bool isPlaying;

  const _SearchResultCard({
    required this.item,
    this.isActive = false,
    this.isPlaying = false,
  });

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark
                  ? Colors.blue.withValues(alpha: 0.12)
                  : Colors.blue.withValues(alpha: 0.06))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$title - $artist - ${formatDuration(duration)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive
              ? Colors.blue
              : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}
