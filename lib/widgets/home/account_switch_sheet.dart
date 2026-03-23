import 'package:flutter/material.dart';
import '../../models/music_account.dart';

/// 账号切换弹窗
/// 功能：
/// 1. 查看当前平台所有账号
/// 2. 点击某个账号 -> 切换当前账号
/// 3. 删除某个账号
/// 4. 新增一个账号
class AccountSwitchSheet extends StatelessWidget {
  final String platformName;
  final List<MusicAccount> accounts;
  final String? currentAccountId;
  final ValueChanged<String> onSwitchAccount;
  final ValueChanged<String> onDeleteAccount;
  final VoidCallback onAddAccount;

  const AccountSwitchSheet({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 顶部拖拽条
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$platformName 账号管理',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            ...accounts.map(
              (account) => _buildAccountTile(
                context: context,
                account: account,
                isCurrent: account.id == currentAccountId,
              ),
            ),

            const SizedBox(height: 12),

            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onAddAccount,
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '新增一个模拟账号',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required BuildContext context,
    required MusicAccount account,
    required bool isCurrent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? Colors.greenAccent
              : (isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          /// 👇 左侧点击区域（只负责切换）
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onSwitchAccount(account.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                      child: Text(
                        account.nickname.isNotEmpty ? account.nickname[0] : '?',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.nickname,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCurrent ? '当前账号' : '点击切换到该账号',
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.greenAccent
                                  : (isDark ? Colors.white60 : Colors.black54),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 👇 删除按钮（独立区域，不会触发 onTap）
          IconButton(
            onPressed: () => onDeleteAccount(account.id),
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
