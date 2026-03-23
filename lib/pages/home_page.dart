import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../models/music_platform_state.dart';
import '../theme/app_colors.dart';
import '../widgets/home/account_switch_sheet.dart';
import '../widgets/home/home_background.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/home_top_bar.dart';
import '../widgets/home/login_platform_sheet.dart';
import '../widgets/home/mini_player.dart';
import '../widgets/home/my_playlist_panel.dart';

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
    _launchImage = const AssetImage('assets/images/loading.jpg');

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

  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return LoginPlatformSheet(
              qqAccountCount: _controller.qqPlatform.accounts.length,
              neteaseAccountCount: _controller.neteasePlatform.accounts.length,
              onTapAddQqAccount: () {
                _controller.addMockAccount('qq');
                Navigator.pop(context);
              },
              onTapAddNeteaseAccount: () {
                _controller.addMockAccount('netease');
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showAccountSwitchSheet(MusicPlatformState platform) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheet(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AccountSwitchSheet(
          platformName: platform.platformName,
          accounts: platform.accounts,
          currentAccountId: platform.currentAccountId,
          onSwitchAccount: (accountId) {
            _controller.switchAccount(platform: platform, accountId: accountId);
            Navigator.pop(context);
          },
          onDeleteAccount: (accountId) {
            _controller.deleteAccount(platform: platform, accountId: accountId);
            Navigator.pop(context);
          },
          onAddAccount: () {
            _controller.addMockAccount(platform.platformKey);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: HomeTopBar(onTapLogin: _showLoginSheet),
          body: Stack(
            children: [
              /// 原本页面
              HomeBackground(
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
                              if (_controller.hasAnyAccount)
                                const SizedBox(height: 24),
                              MyPlaylistPanel(
                                qqPlatform: _controller.qqPlatform,
                                neteasePlatform: _controller.neteasePlatform,
                                onTapPlatformAccountSwitcher:
                                    _showAccountSwitchSheet,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const MiniPlayer(),
                    ],
                  ),
                ),
              ),

              /// ===== loading 覆盖层 =====
              if (_controller.isInitializing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Image(image: _launchImage, fit: BoxFit.contain),
                  ),
                ),

              /// App 内操作 loading
              if (_controller.isOperating)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),

              /// ===== error 覆盖层 =====
              if (_controller.errorMessage != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.8),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

              /// ===== 新增：公告弹层 =====
              if (_showAnnouncement &&
                  !_controller.isInitializing &&
                  _controller.errorMessage == null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(24),
                    child: _AnnouncementCard(
                      onClose: () {
                        setState(() {
                          _showAnnouncement = false;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// ===== 新增：公告卡片 =====
class _AnnouncementCard extends StatelessWidget {
  final VoidCallback onClose;

  const _AnnouncementCard({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: 420,
        maxHeight: screenHeight * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ===== 文本区域 =====
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                '这个App目前是做成一个音乐库用的\n\n'
                '不提供播放功能，主要是方便整理账号、歌单这些内容。\n\n'
                '后面我会慢慢完善，有些功能现在还比较早期，可能会继续调整，我自己的想法也会慢慢往里面加。\n\n'
                '有问题直接找我。',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 15, // ✅ 字体缩小
                  height: 1.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// ===== 按钮 =====
          SizedBox(
            width: 82,
            height: 34, // 更矮一点
            child: TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12), // 关键：缩内边距
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 收紧圆角
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('关闭'),
            ),
          ),
        ],
      ),
    );
  }
}
