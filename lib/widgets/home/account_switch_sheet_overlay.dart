import 'package:flutter/material.dart';
import '../../models/music_account.dart';
import '../home/account_switch_sheet.dart';

class AccountSwitchSheetOverlay extends StatelessWidget {
  final String platformName;
  final List<MusicAccount> accounts;
  final String? currentAccountId;
  final ValueChanged<String> onSwitchAccount;
  final ValueChanged<String> onDeleteAccount;
  final VoidCallback onAddAccount;

  const AccountSwitchSheetOverlay({
    super.key,
    required this.platformName,
    required this.accounts,
    required this.currentAccountId,
    required this.onSwitchAccount,
    required this.onDeleteAccount,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: AccountSwitchSheet(
          platformName: platformName,
          accounts: accounts,
          currentAccountId: currentAccountId,
          onSwitchAccount: onSwitchAccount,
          onDeleteAccount: onDeleteAccount,
          onAddAccount: onAddAccount,
        ),
      ),
    );
  }
}
