import 'package:flutter/material.dart';

/// 应用主题模式
enum AppThemeMode {
  light,
  dark,
  system,
}

/// 全局主题控制器
///
/// 当前先用最轻量的 ChangeNotifier。
/// 目的：
/// 1. 支持浅色 / 深色 / 跟随系统
/// 2. 顶部按钮可直接切换浅深色
/// 3. 后续做“设置页”时还能继续复用
class AppThemeController extends ChangeNotifier {
  /// 默认先用浅色
  AppThemeMode mode = AppThemeMode.light;

  /// 提供给 MaterialApp 的 ThemeMode
  ThemeMode get themeMode {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// 当前是否手动深色模式
  bool get isDarkMode => mode == AppThemeMode.dark;

  /// 当前是否手动浅色模式
  bool get isLightMode => mode == AppThemeMode.light;

  /// 顶部图标按钮使用：
  /// 只在浅色 / 深色之间来回切换
  void toggleLightDark() {
    if (mode == AppThemeMode.dark) {
      mode = AppThemeMode.light;
    } else {
      mode = AppThemeMode.dark;
    }
    notifyListeners();
  }

  /// 设置为跟随系统
  void setSystem() {
    mode = AppThemeMode.system;
    notifyListeners();
  }

  /// 直接设置指定模式
  void setMode(AppThemeMode newMode) {
    mode = newMode;
    notifyListeners();
  }
}

/// 全局单例
final appThemeController = AppThemeController();