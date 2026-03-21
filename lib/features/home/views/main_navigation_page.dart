// File: lib/features/home/views/main_navigation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ung_dung_nm/core/services/supabase_provider.dart';

import 'home_dashboard_page.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../attendance/views/worker/tab_cong_ca_nhan.dart';
import '../../attendance/views/leave_approval_page.dart';
import '../../admin/views/tab_quan_ly_nhan_su.dart';
import '../../admin/views/department_management_page.dart';
import '../../attendance/views/manager_attendance_page.dart';

final rolePermissionsProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  role,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('role_permissions')
      .select('allowed_features')
      .eq('role', role)
      .single();
  return response['allowed_features'] as List<dynamic>;
});

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(authActionControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Lỗi tải thông tin: $err"))),
      data: (profile) {
        if (profile == null)
          return const Scaffold(
            body: Center(child: Text("Không tìm thấy dữ liệu.")),
          );

        // 1. ĐỊNH NGHĨA TẤT CẢ TÍNH NĂNG CỦA APP
        final allFeaturesMap = {
          "nhan_su": FeatureMenuItem(
            title: 'Quản lý Nhân sự',
            icon: Icons.people_alt,
            destination: const TabQuanLyNhanSu(),
            iconColor: Colors.blue.shade700,
          ),
          "phong_ban": FeatureMenuItem(
            title: 'Cơ Cấu & Cấu Hình',
            icon: Icons.business,
            destination: const DepartmentManagementPage(),
            iconColor: Colors.indigo,
          ),
          "cham_cong_tram": FeatureMenuItem(
            title: 'Chấm Công Tổ/Trạm',
            icon: Icons.playlist_add_check_circle,
            destination: ManagerAttendancePage(profileId: profile.id),
            iconColor: Colors.teal,
          ),
          "duyet_don": FeatureMenuItem(
            title: 'Duyệt Đơn Từ',
            icon: Icons.edit_document,
            destination: const LeaveApprovalPage(),
            iconColor: Colors.orange.shade700,
          ),
          "cong_ca_nhan": FeatureMenuItem(
            title: 'Bảng Công & Xin Nghỉ',
            icon: Icons.calendar_month,
            destination: TabCongCaNhan(currentUserId: profile.id),
            iconColor: Colors.green.shade600,
          ),
          "bao_cao": const FeatureMenuItem(
            title: 'Báo cáo & Thống kê',
            icon: Icons.bar_chart,
            isComingSoon: true,
            iconColor: Colors.purple,
          ),
          "vat_tu": const FeatureMenuItem(
            title: 'Quản lý Vật tư',
            icon: Icons.inventory_2,
            isComingSoon: true,
            iconColor: Colors.brown,
          ),
          "tai_san": const FeatureMenuItem(
            title: 'Quản lý Tài sản',
            icon: Icons.devices,
            isComingSoon: true,
            iconColor: Colors.blueGrey,
          ),
          "san_xuat": const FeatureMenuItem(
            title: 'Nhật ký Sản xuất',
            icon: Icons.precision_manufacturing,
            isComingSoon: true,
            iconColor: Colors.redAccent,
          ),
          "giao_viec": const FeatureMenuItem(
            title: 'Giao Việc',
            icon: Icons.task_alt,
            isComingSoon: true,
            iconColor: Colors.lightGreen,
          ),
        };

        // 2. XỬ LÝ RIÊNG CHO ADMIN: Thấy 100% tính năng, không cần check DB
        if (profile.role == 'admin') {
          return HomeDashboardPage(
            userName: profile.fullName,
            menuItems: allFeaturesMap.values.toList(),
            onLogout: () => _showLogoutDialog(context, ref),
          );
        }

        // 3. XỬ LÝ CHO CÁC ROLE KHÁC: Gọi DB để lọc tính năng
        final permissionsAsync = ref.watch(
          rolePermissionsProvider(profile.role),
        );

        return permissionsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) =>
              Scaffold(body: Center(child: Text("Lỗi tải quyền: $err"))),
          data: (allowedFeatures) {
            List<FeatureMenuItem> userFeatures = [];
            for (String featureKey in allowedFeatures) {
              if (allFeaturesMap.containsKey(featureKey)) {
                userFeatures.add(allFeaturesMap[featureKey]!);
              }
            }
            return HomeDashboardPage(
              userName: profile.fullName,
              menuItems: userFeatures,
              onLogout: () => _showLogoutDialog(context, ref),
            );
          },
        );
      },
    );
  }
}
