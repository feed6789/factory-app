// File: lib/features/admin/views/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:ung_dung_nm/features/admin/views/tab_quan_ly_nhan_su.dart';
import 'package:ung_dung_nm/features/attendance/views/leave_approval_page.dart';
import 'package:ung_dung_nm/features/admin/views/department_management_page.dart';

// Class để định nghĩa một mục trong menu, giúp code gọn gàng hơn
class _FeatureMenuItem {
  final String title;
  final IconData icon;
  final Widget? destination; // Widget của trang sẽ điều hướng đến
  final bool isComingSoon;

  const _FeatureMenuItem({
    required this.title,
    required this.icon,
    this.destination,
    this.isComingSoon = false,
  });
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  // DANH SÁCH TÍNH NĂNG - Đây là nơi bạn sẽ thêm các tính năng mới sau này
  static final List<_FeatureMenuItem> _menuItems = [
    _FeatureMenuItem(
      title: 'Quản lý Nhân sự',
      icon: Icons.people_alt,
      destination: const TabQuanLyNhanSu(), // Đây là tính năng đã có
    ),
    _FeatureMenuItem(
      title: 'Quản lý Phòng Ban',
      icon: Icons.business,
      destination: const DepartmentManagementPage(),
    ),
    _FeatureMenuItem(
      title: 'Duyệt Đơn Từ',
      icon: Icons.edit_document,
      destination: const LeaveApprovalPage(),
    ),
    _FeatureMenuItem(
      title: 'Báo cáo & Thống kê',
      icon: Icons.bar_chart,
      isComingSoon: true,
    ),
    _FeatureMenuItem(
      title: 'Quản lý Tài sản',
      icon: Icons.devices,
      isComingSoon: true,
    ),
    _FeatureMenuItem(
      title: 'Nhật ký Sản xuất',
      icon: Icons.precision_manufacturing,
      isComingSoon: true,
    ),
    _FeatureMenuItem(
      title: 'Giao Việc',
      icon: Icons.task_alt,
      isComingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar này sẽ thay thế AppBar cũ trong MainNavigationPage cho Admin
      appBar: AppBar(
        title: const Text(
          "Bảng Điều Khiển Admin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        // Chúng ta vẫn giữ nút logout ở đây
        actions: [
          // Bạn có thể giữ hoặc xóa nút logout này nếu nó đã có ở MainNavigationPage
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        // Sử dụng Center để căn giữa trên màn hình lớn
        child: ConstrainedBox(
          // Giới hạn chiều rộng tối đa của GridView
          constraints: const BoxConstraints(maxWidth: 800),
          child: GridView.builder(
            padding: const EdgeInsets.all(24.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600
                  ? 3
                  : 2, // 3 cột trên web, 2 cột trên mobile
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              childAspectRatio: 1.2, // Tỉ lệ chiều rộng/cao để ô vuông vức hơn
            ),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildMenuItemCard(context, item);
            },
          ),
        ),
      ),
    );
  }

  // Widget để xây dựng mỗi ô trong Grid
  Widget _buildMenuItemCard(BuildContext context, _FeatureMenuItem item) {
    return Stack(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              if (item.isComingSoon || item.destination == null) {
                // Nếu là tính năng sắp có, chỉ hiển thị thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng này sẽ được phát triển sớm!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                // Nếu là tính năng đã có, điều hướng đến trang tương ứng
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item.destination!),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              // Làm mờ các tính năng chưa có
              opacity: item.isComingSoon ? 0.5 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 48, color: Colors.blue.shade700),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Thêm nhãn "Sắp có" cho các tính năng chưa hoàn thiện
        if (item.isComingSoon)
          Positioned(
            top: 8,
            right: 8,
            child: Chip(
              label: const Text('Sắp có'),
              backgroundColor: Colors.orange.shade300,
              padding: EdgeInsets.zero,
              labelStyle: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
