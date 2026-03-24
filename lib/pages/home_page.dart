import 'package:flutter/material.dart';
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
