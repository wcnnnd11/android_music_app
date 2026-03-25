import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../controllers/home_controller.dart';
import '../widgets/home/home_announcement_overlay.dart';
import '../widgets/home/home_bottom_sheets.dart';
import '../widgets/home/home_drawer.dart';
import '../widgets/home/home_error_overlay.dart';
import '../widgets/home/home_loading_overlays.dart';
import '../widgets/home/home_page_content.dart';
import '../widgets/home/home_top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  late final AssetImage _launchImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showAnnouncement = true;
  bool _forceShowAnnouncement = false;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _launchImage = AssetImage(AppConfig.loading.image);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(_launchImage, context);
      if (!mounted) return;
      await _controller.init();
    });
  }

  Future<void> _showDownloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('download_history') ?? [];

    final list = rawList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '下载历史',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                          child: Text('暂无下载记录', style: TextStyle(fontSize: 14)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            final musicName =
                                item['musicName']?.toString() ?? '未知音乐';
                            final quality = item['quality']?.toString() ?? '-';
                            final time = item['time']?.toString() ?? '-';
                            final result = item['result']?.toString() ?? '-';

                            Color statusColor;
                            switch (result) {
                              case '成功':
                                statusColor = Colors.green;
                                break;
                              case '失败':
                                statusColor = Colors.red;
                                break;
                              default:
                                statusColor = Colors.orange;
                            }

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              title: Text(
                                musicName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '$quality · $time',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              trailing: Text(
                                result,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final remoteLoading =
            _controller.remoteConfig?['loading'] as Map<String, dynamic>?;
        final remoteAnnouncement =
            _controller.remoteConfig?['announcement'] as Map<String, dynamic>?;

        final loadingEnabled =
            remoteLoading?['enable'] as bool? ?? AppConfig.loading.enable;

        final loadingImagePath =
            remoteLoading?['image'] as String? ?? AppConfig.loading.image;

        final announcementEnabled =
            remoteAnnouncement?['enable'] as bool? ??
            AppConfig.announcement.enable;

        final announcementContent =
            remoteAnnouncement?['content'] as String? ??
            AppConfig.announcement.content;

        final shouldShowAutoAnnouncement =
            announcementEnabled &&
            _showAnnouncement &&
            !_controller.isInitializing &&
            _controller.errorMessage == null;

        final shouldShowAnnouncement =
            _forceShowAnnouncement || shouldShowAutoAnnouncement;

        final shouldHideTopBar =
            (loadingEnabled && _controller.isInitializing) ||
            shouldShowAnnouncement;

        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          drawer: HomeDrawer(
            onTapAnnouncement: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _forceShowAnnouncement = true;
                });
              });
            },
            onTapDownloadHistory: _showDownloadHistory,
          ),
          appBar: shouldHideTopBar
              ? null
              : HomeTopBar(
                  onTapMenu: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  onTapLogin: () {
                    showLoginSheet(context: context, controller: _controller);
                  },
                  avatarUrl: _controller.currentAccount?.avatarUrl,
                ),
          body: Stack(
            children: [
              HomePageContent(
                controller: _controller,
                onTapAccountSwitcher: (platform) {
                  showAccountSwitchSheet(
                    context: context,
                    controller: _controller,
                    platform: platform,
                  );
                },
              ),
              if (loadingEnabled && _controller.isInitializing)
                LaunchLoadingOverlay(
                  image: loadingImagePath.startsWith('http')
                      ? NetworkImage(loadingImagePath)
                      : AssetImage(loadingImagePath),
                ),
              if (_controller.isOperating) const OperatingLoadingOverlay(),
              if (_controller.errorMessage != null)
                HomeErrorOverlay(message: _controller.errorMessage!),
              if (shouldShowAnnouncement)
                HomeAnnouncementOverlay(
                  content: announcementContent,
                  ignoreShownOnce: _forceShowAnnouncement,
                  onClose: () {
                    setState(() {
                      _showAnnouncement = false;
                      _forceShowAnnouncement = false;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
