import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ung_dung_nm/core/services/supabase_provider.dart';
import 'package:ung_dung_nm/features/reports/views/inventory_main_page.dart';
import 'package:ung_dung_nm/features/reports/views/material_request_page.dart';

import 'home_dashboard_page.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../attendance/views/worker/tab_cong_ca_nhan.dart';
import '../../attendance/views/leave_approval_page.dart';
import '../../admin/views/tab_quan_ly_nhan_su.dart';
import '../../admin/views/department_management_page.dart';
import '../../attendance/views/manager_attendance_page.dart';
import '../../reports/views/production_report_page.dart';
import '../../attendance/views/feedback_submission_page.dart';
import '../../attendance/views/feedback_main_page.dart';
import '../../reports/views/data_entry_page.dart'; // <-- Thêm dòng này

// Fetch quyền của role cụ thể
final rolePermissionsProviderUser =
    FutureProvider.family<List<dynamic>, String>((ref, role) async {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase
          .from('role_permissions')
          .select('allowed_features')
          .eq('role', role)
          .maybeSingle();
      if (response == null) return [];
      return response['allowed_features'] as List<dynamic>;
    });

// --- PROVIDER MỚI: Kiểm tra cờ thủ kho của từng cá nhân ---
// Giúp không cần sửa ProfileModel và chạy lại build_runner
final inventoryPermissionProvider = FutureProvider.family<bool, String>((
  ref,
  userId,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('profiles')
      .select('can_manage_inventory')
      .eq('id', userId)
      .maybeSingle();
  if (response == null) return false;
  return response['can_manage_inventory'] == true;
});

// Hàm phụ trợ kiểm tra quyền
bool hasAnyPermissionInGroup(List<dynamic> allowedFeatures, String groupKey) {
  return allowedFeatures.any(
    (feature) => feature.toString().startsWith(groupKey),
  );
}

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

        // Đọc trạng thái xem user này có phải là Thủ kho (cá nhân) không
        final canManageInventoryAsync = ref.watch(
          inventoryPermissionProvider(profile.id),
        );
        final bool isInventoryManager =
            canManageInventoryAsync.valueOrNull ?? false;

        // Định nghĩa tất cả các Menu Lớn ngoài Dashboard
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
          "cham_cong": FeatureMenuItem(
            title: 'Chấm Công & Đánh Giá',
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
          "nhap_lieu": const FeatureMenuItem(
            title: 'Nhập Liệu & Cấu Hình',
            icon: Icons.edit_note,
            destination: DataEntryPage(),
            iconColor: Colors.blueAccent,
          ),
          "bao_cao": const FeatureMenuItem(
            title: 'Báo cáo & Thống kê',
            icon: Icons.bar_chart,
            destination: ProductionReportPage(),
            iconColor: Colors.purple,
          ),
          "cong_ca_nhan": FeatureMenuItem(
            title: 'Bảng Công Cá Nhân',
            icon: Icons.calendar_month,
            destination: TabCongCaNhan(currentUserId: profile.id),
            iconColor: Colors.green.shade600,
          ),

          // ==========================================
          // ĐÃ SỬA: MỞ KHÓA TÍNH NĂNG VẬT TƯ
          // ==========================================
          "vat_tu": const FeatureMenuItem(
            title: 'Quản lý Vật tư',
            icon: Icons.inventory_2,
            destination: InventoryMainPage(), // Liên kết tới trang Vật Tư
            iconColor: Colors.brown,
          ),
          "de_xuat_vt": const FeatureMenuItem(
            title: 'Đề Xuất Vật Tư',
            icon: Icons.assignment_add,
            destination: MaterialRequestPage(),
            iconColor: Colors.teal,
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
          "gop_y": const FeatureMenuItem(
            title: 'Đóng góp Ý kiến',
            icon: Icons.record_voice_over,
            destination: FeedbackMainPage(),
            iconColor: Colors.pinkAccent,
          ),
        };

        // Điều kiện để được thấy Tab Quản Lý Vật Tư
        final bool canAccessInventory =
            profile.role == 'admin' ||
            profile.role == 'director' ||
            profile.role == 'section_head' ||
            isInventoryManager;

        // 1. NẾU LÀ ADMIN -> Hiển thị toàn bộ tính năng
        if (profile.role == 'admin') {
          return HomeDashboardPage(
            userName: profile.fullName,
            menuItems: allFeaturesMap.values.toList(),
            onLogout: () => _showLogoutDialog(context, ref),
          );
        }

        // 2. NẾU LÀ USER THƯỜNG -> Kéo danh sách quyền từ Database về
        final permissionsAsync = ref.watch(
          rolePermissionsProviderUser(profile.role),
        );

        return permissionsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) =>
              Scaffold(body: Center(child: Text("Lỗi tải quyền: $err"))),
          data: (allowedFeatures) {
            List<FeatureMenuItem> userFeatures = [];

            if (hasAnyPermissionInGroup(allowedFeatures, 'nhan_su')) {
              userFeatures.add(allFeaturesMap['nhan_su']!);
            }
            if (hasAnyPermissionInGroup(allowedFeatures, 'phong_ban')) {
              userFeatures.add(allFeaturesMap['phong_ban']!);
            }
            if (hasAnyPermissionInGroup(allowedFeatures, 'cham_cong')) {
              userFeatures.add(allFeaturesMap['cham_cong']!);
            }
            if (hasAnyPermissionInGroup(allowedFeatures, 'duyet_don')) {
              userFeatures.add(allFeaturesMap['duyet_don']!);
            }
            if (hasAnyPermissionInGroup(allowedFeatures, 'nhap_lieu')) {
              userFeatures.add(allFeaturesMap['nhap_lieu']!);
            }
            if (hasAnyPermissionInGroup(allowedFeatures, 'bao_cao')) {
              userFeatures.add(allFeaturesMap['bao_cao']!);
            }

            // KIỂM TRA QUYỀN VẬT TƯ Ở ĐÂY
            if (canAccessInventory ||
                hasAnyPermissionInGroup(allowedFeatures, 'vat_tu')) {
              userFeatures.add(allFeaturesMap['vat_tu']!);
            }

            if (hasAnyPermissionInGroup(allowedFeatures, 'de_xuat')) {
              userFeatures.add(
                allFeaturesMap['de_xuat_vt']!,
              ); // Map tên de_xuat_vt bạn đã tạo ở bước trước
            }

            // Luôn thêm Bảng công cá nhân
            userFeatures.add(allFeaturesMap['cong_ca_nhan']!);
            userFeatures.add(allFeaturesMap['gop_y']!);

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
