import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import 'feedback_submission_page.dart';
import 'feedback_management_tab.dart';

class FeedbackMainPage extends ConsumerWidget {
  const FeedbackMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Lỗi: $err"))),
      data: (profile) {
        if (profile == null)
          return const Scaffold(body: Center(child: Text("Không có dữ liệu")));

        // Kiểm tra xem user có quyền quản lý không
        final isManager = [
          'admin',
          'director',
          'team_leader',
          'section_head',
        ].contains(profile.role);

        if (!isManager) {
          // Worker bình thường chỉ thấy trang gửi
          return const FeedbackSubmissionPage(isStandalone: true);
        }

        // Quản lý sẽ thấy giao diện 2 Tabs
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "Ý Kiến & Đóng Góp",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              bottom: const TabBar(
                labelColor: Colors.orangeAccent,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.orangeAccent,
                tabs: [
                  Tab(icon: Icon(Icons.list_alt), text: "Quản Lý Ý Kiến"),
                  Tab(icon: Icon(Icons.send), text: "Gửi Ý Kiến"),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                FeedbackManagementTab(),
                FeedbackSubmissionPage(isStandalone: false),
              ],
            ),
          ),
        );
      },
    );
  }
}
