import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme_mode.dart';

/// 首页顶部导航栏
///
/// 职责：
/// 1. 显示标题
/// 2. 提供浅色 / 深色切换按钮
/// 3. 提供登录按钮入口
/// 4. 提供毛玻璃效果
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTapLogin;

  const HomeTopBar({
    super.key,
    required this.onTapLogin,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appThemeController,
      builder: (context, _) {
        /// 这里优先根据全局主题控制器判断，
        /// 避免按钮点击后图标状态没有及时更新
        final isDark = appThemeController.isDarkMode;

        return AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(
            '首页',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            /// 浅深色切换按钮
            /// 当前是深色 -> 显示太阳
            /// 当前是浅色 -> 显示月亮
            IconButton(
              onPressed: () {
                appThemeController.toggleLightDark();
              },
              icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                color: isDark ? Colors.white : Colors.black,
              ),
              tooltip: isDark ? '切换到浅色模式' : '切换到深色模式',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: onTapLogin,
                child: Text(
                  '登录',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],

          /// 毛玻璃层
          /// 浅色下不要太白，改成灰白半透明
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : const Color(0xFFF2F2F2).withValues(alpha: 0.60),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}