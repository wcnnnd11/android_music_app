// APP入口，启动+指向首页
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'theme/app_theme_mode.dart';

void main() {
  runApp(const MusicApp());
}

/// 整个应用入口
class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// 监听全局主题控制器
    /// 当切换浅色 / 深色 / 跟随系统时，MaterialApp 会自动重建
    return AnimatedBuilder(
      animation: appThemeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Music App',
          debugShowCheckedModeBanner: false,

          /// 当前应用主题模式
          themeMode: appThemeController.themeMode,

          /// 浅色主题
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),

            /// 页面基础背景
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),

            /// 卡片颜色
            cardColor: Colors.white,

            /// 底部弹窗主题
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color(0xFFF2F2F7),
              surfaceTintColor: Colors.transparent,
            ),

            /// 顶部导航栏默认样式
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              foregroundColor: Colors.black,
            ),
          ),

          /// 深色主题
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),

            /// 页面基础背景，不用纯黑
            scaffoldBackgroundColor: const Color(0xFF1C1C1E),

            /// 卡片颜色
            cardColor: const Color(0xFF2C2C2E),

            /// 底部弹窗主题
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color(0xFF2C2C2E),
              surfaceTintColor: Colors.transparent,
            ),

            /// 顶部导航栏默认样式
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              foregroundColor: Colors.white,
            ),
          ),

          home: const HomePage(),
        );
      },
    );
  }
}