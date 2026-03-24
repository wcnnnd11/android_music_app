import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/search_controller.dart' as app;
import '../../models/music_platform_state.dart';
import 'home_background.dart';
import 'home_search_bar.dart';
import 'home_search_result_section.dart';
import 'mini_player.dart';
import 'my_playlist_panel.dart';

class HomePageContent extends StatefulWidget {
  final HomeController controller;
  final ValueChanged<MusicPlatformState> onTapAccountSwitcher;

  const HomePageContent({
    super.key,
    required this.controller,
    required this.onTapAccountSwitcher,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final app.SearchController _searchController = app.SearchController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, dynamic>? _currentPreviewSong;
  String? _currentPreviewUrl;
  bool _isMiniPlayerVisible = false;
  bool _isPreviewPlaying = false;

  void _handleSearch(String keyword) {
    _searchController.search(keyword);
  }

  void _exitSearch(BuildContext context) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
  }

  Future<void> _handleSongTap(Map<String, dynamic> song) async {
    debugPrint('点击歌曲: $song');

    final resource = await _searchController.fetchSongResource(song);

    if (!mounted) return;

    if (resource == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('获取试听资源失败')));
      return;
    }

    final playUrl = resource['url']?.toString();

    debugPrint('试听资源: $resource');
    debugPrint('试听链接: $playUrl');

    if (playUrl == null || playUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已拿到资源响应，但没有可播放链接')));
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(playUrl);
      await _audioPlayer.play();

      if (!mounted) return;

      setState(() {
        _currentPreviewSong = song;
        _currentPreviewUrl = playUrl;
        _isMiniPlayerVisible = true;
        _isPreviewPlaying = true;
      });
    } catch (e) {
      debugPrint('试听播放失败: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('试听播放失败')));
    }
  }

  Future<void> _handlePreviewPlayPause() async {
    if (_currentPreviewUrl == null || _currentPreviewUrl!.isEmpty) return;

    try {
      if (_isPreviewPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }

      if (!mounted) return;

      setState(() {
        _isPreviewPlaying = !_isPreviewPlaying;
      });
    } catch (e) {
      debugPrint('播放/暂停失败: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('播放控制失败')));
    }
  }

  Future<void> _handleCloseMiniPlayer() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('关闭试听失败: $e');
    }

    if (!mounted) return;

    setState(() {
      _currentPreviewSong = null;
      _currentPreviewUrl = null;
      _isMiniPlayerVisible = false;
      _isPreviewPlaying = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final bottomInset = _isMiniPlayerVisible ? 96.0 : 24.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _exitSearch(context),
      child: HomeBackground(
        child: SafeArea(
          bottom: false,
          child: SizedBox.expand(
            child: AnimatedBuilder(
              animation: _searchController,
              builder: (context, _) {
                final isSearchMode = _searchController.isInSearchMode;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeSearchBar(onSearch: _handleSearch),
                          const SizedBox(height: 16),
                          if (isSearchMode)
                            HomeSearchResultSection(
                              keyword: _searchController.keyword ?? '',
                              results: _searchController.results,
                              isLoading: _searchController.isSearching,
                              onSongTap: _handleSongTap,
                            )
                          else ...[
                            if (controller.hasAnyAccount)
                              const SizedBox(height: 24),
                            MyPlaylistPanel(
                              qqPlatform: controller.qqPlatform,
                              neteasePlatform: controller.neteasePlatform,
                              onTapPlatformAccountSwitcher:
                                  widget.onTapAccountSwitcher,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_isMiniPlayerVisible && _currentPreviewSong != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SafeArea(
                          top: false,
                          child: MiniPlayer(
                            title:
                                _currentPreviewSong!['title']?.toString() ?? '',
                            artist:
                                _currentPreviewSong!['artist']?.toString() ??
                                '',
                            isPlaying: _isPreviewPlaying,
                            onPlayPause: _handlePreviewPlayPause,
                            onClose: _handleCloseMiniPlayer,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
