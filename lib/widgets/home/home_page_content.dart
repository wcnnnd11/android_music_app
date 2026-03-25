import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _downloadHistoryKey = 'download_history';
  static const int _downloadHistoryLimit = 50;

  final app.SearchController _searchController = app.SearchController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  Map<String, dynamic>? _currentPreviewSong;
  String? _currentPreviewUrl;
  bool _isMiniPlayerVisible = false;
  bool _isPreviewPlaying = false;

  void _handleSearch(String keyword) {
    _searchController.search(keyword);
  }

  void _unfocusOnly() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleSongTap(Map<String, dynamic> song) async {
    final songId = song['id'];
    _isPreviewPlaying = true;

    FocusScope.of(context).unfocus();

    if (_currentPreviewSong != null &&
        _currentPreviewSong!['id'] == songId &&
        _currentPreviewUrl != null) {
      await _handlePreviewPlayPause();
      return;
    }

    final resource = await _searchController.fetchSongResource(
      song,
      quality: 'standard',
    );

    if (!mounted) return;

    if (resource == null) {
      return;
    }

    final playUrl = resource['url']?.toString();

    if (playUrl == null || playUrl.isEmpty) {
      return;
    }

    try {
      setState(() {
        _currentPreviewSong = song;
        _currentPreviewUrl = playUrl;
        _isMiniPlayerVisible = true;
        _isPreviewPlaying = true;
      });

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(playUrl);
      await _audioPlayer.play();
    } catch (e) {
      await _audioPlayer.stop();

      if (!mounted) return;

      setState(() {
        _currentPreviewSong = null;
        _currentPreviewUrl = null;
        _isMiniPlayerVisible = false;
        _isPreviewPlaying = false;
      });
    }
  }

  Future<void> _handleDownloadTap(
    Map<String, dynamic> song,
    String quality,
  ) async {
    final songTitle = song['title']?.toString().trim();
    final displayTitle = (songTitle != null && songTitle.isNotEmpty)
        ? songTitle
        : '未知歌曲';

    final time = DateTime.now();
    final historyId = time.microsecondsSinceEpoch.toString();

    await _addDownloadHistory(
      id: historyId,
      musicName: displayTitle,
      quality: quality,
      time: time,
      result: '下载中',
    );

    final resource = await _searchController.fetchSongResource(
      song,
      quality: quality,
    );

    if (!mounted) return;

    if (resource == null) {
      await _updateDownloadHistoryResult(historyId, '失败');
      _showSnackBar('获取下载资源失败');
      return;
    }

    final downloadUrl = resource['url']?.toString();
    if (downloadUrl == null || downloadUrl.isEmpty) {
      await _updateDownloadHistoryResult(historyId, '失败');
      _showSnackBar('下载链接为空');
      return;
    }

    final artist = song['artist']?.toString().trim();

    final safeTitle = _sanitizeFileName(
      songTitle?.isNotEmpty == true ? songTitle! : 'unknown',
    );
    final safeArtist = _sanitizeFileName(
      artist?.isNotEmpty == true ? artist! : 'unknown',
    );
    final safeQuality = _sanitizeFileName(quality);

    final extension = _guessFileExtension(downloadUrl, resource);
    final fileName = '$safeTitle - $safeArtist [$safeQuality].$extension';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/downloads');

      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final savePath = '${downloadDir.path}/$fileName';

      if (!mounted) return;
      _showSnackBar('开始下载：$fileName');

      await _dio.download(
        downloadUrl,
        savePath,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      await _updateDownloadHistoryResult(historyId, '成功');

      if (!mounted) return;
      _showSnackBar('下载成功：$fileName');
      debugPrint('下载完成: $savePath');
    } catch (e) {
      await _updateDownloadHistoryResult(historyId, '失败');

      if (!mounted) return;
      _showSnackBar('下载失败：$e');
      debugPrint('下载失败: $e');
    }
  }

  Future<void> _addDownloadHistory({
    required String id,
    required String musicName,
    required String quality,
    required DateTime time,
    required String result,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_downloadHistoryKey) ?? [];

    final item = {
      'id': id,
      'musicName': musicName,
      'quality': quality,
      'time': _formatHistoryTime(time),
      'rawTime': time.toIso8601String(),
      'result': result,
    };

    rawList.insert(0, jsonEncode(item));

    final trimmedList = rawList.take(_downloadHistoryLimit).toList();
    await prefs.setStringList(_downloadHistoryKey, trimmedList);
  }

  Future<void> _updateDownloadHistoryResult(String id, String result) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_downloadHistoryKey) ?? [];

    final updatedList = rawList.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      if (map['id'] == id) {
        map['result'] = result;
      }
      return jsonEncode(map);
    }).toList();

    await prefs.setStringList(_downloadHistoryKey, updatedList);
  }

  String _formatHistoryTime(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  String _sanitizeFileName(String input) {
    return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  String _guessFileExtension(String url, Map<String, dynamic> resource) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('.flac')) return 'flac';
    if (lowerUrl.contains('.mp3')) return 'mp3';
    if (lowerUrl.contains('.m4a')) return 'm4a';
    if (lowerUrl.contains('.aac')) return 'aac';
    if (lowerUrl.contains('.wav')) return 'wav';

    final type = resource['type']?.toString().toLowerCase();
    if (type != null && type.isNotEmpty) {
      if (type.contains('flac')) return 'flac';
      if (type.contains('mp3')) return 'mp3';
      if (type.contains('m4a')) return 'm4a';
      if (type.contains('aac')) return 'aac';
      if (type.contains('wav')) return 'wav';
    }

    return 'mp3';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

      setState(() {});
    } catch (_) {}
  }

  Future<void> _handleCloseMiniPlayer() async {
    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      _currentPreviewSong = null;
      _currentPreviewUrl = null;
      _isMiniPlayerVisible = false;
      _isPreviewPlaying = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPreviewPlaying = state.playing;
      });
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
      onTap: _unfocusOnly,
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
                              currentPlayingId: _currentPreviewSong?['id']
                                  ?.toString(),
                              isPlaying: _isPreviewPlaying,
                              onQualityTap: _handleDownloadTap,
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
