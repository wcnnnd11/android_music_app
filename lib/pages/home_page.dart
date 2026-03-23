import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../widgets/home/home_top_bar.dart';
import '../config/app_config.dart';
import '../widgets/home/home_announcement_overlay.dart';
import '../widgets/home/home_loading_overlays.dart';
import '../widgets/home/home_error_overlay.dart';
import '../widgets/home/home_bottom_sheets.dart';
import '../widgets/home/home_page_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  late final AssetImage _launchImage;

  /// ===== 新增：公告显示状态 =====
  bool _showAnnouncement = true;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _launchImage = const AssetImage(AppConfig.launchImage);

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
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: HomeTopBar(
            onTapLogin: () {
              showLoginSheet(context: context, controller: _controller);
            },
          ),
          body: Stack(
            children: [
              /// 原本页面
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

              /// ===== loading 覆盖层 =====
              if (_controller.isInitializing)
                LaunchLoadingOverlay(image: _launchImage),

              /// App 内操作 loading
              if (_controller.isOperating) const OperatingLoadingOverlay(),

              /// ===== error 覆盖层 =====
              if (_controller.errorMessage != null)
                HomeErrorOverlay(message: _controller.errorMessage!),

              /// ===== 新增：公告弹层 =====
              if (_showAnnouncement &&
                  !_controller.isInitializing &&
                  _controller.errorMessage == null)
                HomeAnnouncementOverlay(
                  onClose: () {
                    setState(() {
                      _showAnnouncement = false;
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
