import 'package:flutter/material.dart';

/// 应用颜色常量
///
/// 先只收口首页和主题切换相关颜色。
/// 后面做卡片、弹窗、公告时继续加。
class AppColors {
  /// 浅色背景：不是纯白，柔和一点
  static const Color lightBackground = Color(0xFFF5F5F7);

  /// 深色背景：不是纯黑，用深灰
  static const Color darkBackground = Color(0xFF1C1C1E);

  /// 浅色卡片
  static const Color lightCard = Colors.white;

  /// 深色卡片
  static const Color darkCard = Color(0xFF2C2C2E);

  /// 浅色弹窗
  static const Color lightSheet = Color(0xFFF2F2F7);

  /// 深色弹窗
  static const Color darkSheet = Color(0xFF2C2C2E);

  /// 根据当前亮暗模式返回页面背景色
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  /// 根据当前亮暗模式返回卡片色
  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }

  /// 根据当前亮暗模式返回底部弹窗背景色
  static Color sheet(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSheet
        : lightSheet;
  }

  /// 主要文字颜色
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  /// 次级文字颜色
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }
}