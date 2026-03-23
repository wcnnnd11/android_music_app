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
