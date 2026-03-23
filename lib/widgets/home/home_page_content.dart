import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import 'home_background.dart';
import 'home_search_bar.dart';
import 'my_playlist_panel.dart';
import 'mini_player.dart';
import '../../models/music_platform_state.dart';

class HomePageContent extends StatelessWidget {
  final HomeController controller;
  final ValueChanged<MusicPlatformState> onTapAccountSwitcher;

  const HomePageContent({
    super.key,
    required this.controller,
    required this.onTapAccountSwitcher,
  });

  @override
  Widget build(BuildContext context) {
    return HomeBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeSearchBar(),
                    if (controller.hasAnyAccount) const SizedBox(height: 24),
                    MyPlaylistPanel(
                      qqPlatform: controller.qqPlatform,
                      neteasePlatform: controller.neteasePlatform,
                      onTapPlatformAccountSwitcher: onTapAccountSwitcher,
                    ),
                  ],
                ),
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}
