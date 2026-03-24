import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme_mode.dart';

class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTapMenu;
  final VoidCallback onTapLogin;

  /// 👇 新增：头像
  final String? avatarUrl;

  const HomeTopBar({
    super.key,
    required this.onTapMenu,
    required this.onTapLogin,
    this.avatarUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appThemeController,
      builder: (context, _) {
        final isDark = appThemeController.isDarkMode;

        return AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,

          leading: IconButton(
            onPressed: onTapMenu,
            icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
            tooltip: '打开侧边栏',
          ),

          actions: [
            IconButton(
              onPressed: () {
                appThemeController.toggleLightDark();
              },
              icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: avatarUrl == null
                  /// 👇 未登录
                  ? TextButton(
                      onPressed: onTapLogin,
                      child: Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    )
                  /// 👇 已登录：显示头像
                  : GestureDetector(
                      onTap: onTapLogin,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: isDark
                            ? Colors.white12
                            : Colors.black12,
                        backgroundImage: avatarUrl!.startsWith('http')
                            ? NetworkImage(avatarUrl!)
                            : AssetImage(avatarUrl!) as ImageProvider,
                      ),
                    ),
            ),
          ],

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
