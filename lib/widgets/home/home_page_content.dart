import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/search_controller.dart' as app;
import '../../models/music_platform_state.dart';
import 'home_background.dart';
import 'home_search_bar.dart';
import 'home_search_result_section.dart';
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

  void _handleSearch(String keyword) {
    _searchController.search(keyword);
  }

  void _exitSearch(BuildContext context) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _exitSearch(context),
      child: HomeBackground(
        child: SafeArea(
          bottom: false,
          child: SizedBox.expand(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: AnimatedBuilder(
                animation: _searchController,
                builder: (context, _) {
                  final isSearchMode = _searchController.isInSearchMode;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeSearchBar(onSearch: _handleSearch),
                      const SizedBox(height: 16),
                      if (isSearchMode)
                        HomeSearchResultSection(
                          keyword: _searchController.keyword ?? '',
                          results: _searchController.results,
                          isLoading: _searchController.isSearching,
                          onSongTap: (songId) {
                            debugPrint('点击歌曲: $songId');
                            // 先不做播放逻辑，后面再接
                          },
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
