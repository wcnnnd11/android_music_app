import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import '../../models/music_platform_state.dart';
import '../../theme/app_colors.dart';
import 'account_switch_sheet.dart';
import 'login_platform_sheet.dart';

void showLoginSheet({
  required BuildContext context,
  required HomeController controller,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.sheet(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return LoginPlatformSheet(
            qqAccountCount: controller.qqPlatform.accounts.length,
            neteaseAccountCount: controller.neteasePlatform.accounts.length,
            onTapAddQqAccount: () {
              controller.addMockAccount('qq');
              Navigator.pop(context);
            },
            onTapAddNeteaseAccount: () {
              controller.addMockAccount('netease');
              Navigator.pop(context);
            },
          );
        },
      );
    },
  );
}

void showAccountSwitchSheet({
  required BuildContext context,
  required HomeController controller,
  required MusicPlatformState platform,
}) {
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
          controller.switchAccount(platform: platform, accountId: accountId);
          Navigator.pop(context);
        },
        onDeleteAccount: (accountId) {
          controller.deleteAccount(platform: platform, accountId: accountId);
          Navigator.pop(context);
        },
        onAddAccount: () {
          controller.addMockAccount(platform.platformKey);
          Navigator.pop(context);
        },
      );
    },
  );
}

void showSearchSheet({required BuildContext context}) {
  final textController = TextEditingController();
  final focusNode = FocusNode();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 🔥 关键：让键盘顶上来
    backgroundColor: AppColors.sheet(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      // 自动聚焦（弹出键盘）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });

      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16, // 🔥 适配键盘
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 输入框
            TextField(
              controller: textController,
              focusNode: focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '搜索歌曲、歌手、专辑',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                debugPrint('搜索内容: $value');
              },
            ),

            const SizedBox(height: 12),

            /// 占位提示（后面会替换成结果）
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '输入关键词开始搜索',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    },
  );
}
