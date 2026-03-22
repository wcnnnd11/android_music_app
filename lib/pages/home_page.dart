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

/// 首页
///
/// 当前职责：
/// 1. 持有 HomeController
/// 2. 调度弹窗
/// 3. 组合首页模块
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 登录平台选择弹窗
  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheet(context),
      // surfaceTintColor: Colors.transparent,
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

  /// 账号切换弹窗
  void _showAccountSwitchSheet(MusicPlatformState platform) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheet(context),
      // surfaceTintColor: Colors.transparent,
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
          body: HomeBackground(
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
        );
      },
    );
  }
}
