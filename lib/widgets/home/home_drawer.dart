import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  final VoidCallback onTapAnnouncement;

  const HomeDrawer({super.key, required this.onTapAnnouncement});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('下载历史'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('应用设置'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),

            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('反馈'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),

            /// 👇 关键改动
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('查看公告'),
              onTap: () {
                Navigator.pop(context);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onTapAnnouncement();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
