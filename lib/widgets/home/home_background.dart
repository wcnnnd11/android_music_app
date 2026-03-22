import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 首页背景组件
///
/// 当前先做最稳的纯色背景切换：
/// - 浅色：柔和浅灰白
/// - 深色：高级深灰
///
/// 不再用花哨渐变，避免脏。
class HomeBackground extends StatelessWidget {
  final Widget child;

  const HomeBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background(context),
      child: child,
    );
  }
}