import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/views/main_navigation_page.dart';

// Import các Tab đã có sẵn từ file Đề Xuất Vật Tư cũ
import 'material_request_page.dart';
// Import Tab Kho (File này bạn đã có, hãy đảm bảo đường dẫn và tên file chính xác)
import 'inventory_main_page.dart';

class MaterialMainPage extends ConsumerWidget {
  const MaterialMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    // Bắt đầu bằng việc kiểm tra thông tin người dùng
    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Lỗi tải hồ sơ: $e"))),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text("Không tìm thấy thông tin người dùng.")),
          );
        }

        // Sau khi có thông tin, kiểm tra quyền của người dùng
        final permissionsAsync = ref.watch(
          rolePermissionsProviderUser(profile.role),
        );
        final isGlobalAdmin = profile.role == 'admin';

        return permissionsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) =>
              Scaffold(body: Center(child: Text("Lỗi tải quyền: $e"))),
          data: (allowedFeatures) {
            // 1. KIỂM TRA TỪNG QUYỀN (Theo đúng cấu hình đã setup)
            final canViewInventory =
                isGlobalAdmin || allowedFeatures.contains('vat_tu_xem_kho');
            final canRequest =
                isGlobalAdmin || allowedFeatures.contains('vat_tu_de_xuat');
            final canApprove =
                isGlobalAdmin || allowedFeatures.contains('vat_tu_duyet');
            final canViewHistory =
                isGlobalAdmin || allowedFeatures.contains('vat_tu_lich_su');
            final canManageCatalog =
                isGlobalAdmin || allowedFeatures.contains('vat_tu_danh_muc');

            // 2. KHỞI TẠO DANH SÁCH TAB VÀ VIEW TRỐNG
            List<Tab> tabs = [];
            List<Widget> tabViews = [];

            // 3. THÊM TAB ĐỘNG DỰA TRÊN QUYỀN
            if (canRequest) {
              tabs.add(
                const Tab(
                  icon: Icon(Icons.add_shopping_cart),
                  text: "Tạo Đề Xuất",
                ),
              );
              tabViews.add(CreateRequestTab(userProfile: profile));

              tabs.add(
                const Tab(icon: Icon(Icons.history_edu), text: "Phiếu Của Tôi"),
              );
              tabViews.add(MyRequestsTab(userId: profile.id));
            }

            // Đây là Tab dành cho tính năng Kho Vật Tư cũ của bạn
            if (canViewInventory) {
              tabs.add(
                const Tab(
                  icon: Icon(Icons.inventory_2),
                  text: "Tồn Kho & Nhập/Xuất",
                ),
              );
              tabViews.add(
                const InventoryMainPage(),
              ); // Đảm bảo bạn đã import file này
            }

            if (canApprove) {
              tabs.add(
                const Tab(
                  icon: Icon(Icons.fact_check_outlined),
                  text: "Chờ Duyệt",
                ),
              );
              tabViews.add(const ApproveRequestsTab());
            }

            if (canViewHistory) {
              tabs.add(
                const Tab(
                  icon: Icon(Icons.archive_outlined),
                  text: "Lịch Sử Duyệt",
                ),
              );
              tabViews.add(ApprovedHistoryTab());
            }

            if (canManageCatalog) {
              tabs.add(
                const Tab(
                  icon: Icon(Icons.category_outlined),
                  text: "Quản Lý Mã VTPT",
                ),
              );
              tabViews.add(const CatalogSettingsTab());
            }

            // Xử lý trường hợp người dùng không có quyền nào
            if (tabs.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text("Quản lý Vật tư & Đề xuất")),
                body: const Center(
                  child: Text("Bạn không có quyền truy cập tính năng này."),
                ),
              );
            }

            // 4. TRẢ VỀ GIAO DIỆN TAB HOÀN CHỈNH
            return DefaultTabController(
              length: tabs.length,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "Quản lý Vật tư & Đề xuất",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: tabs,
                  ),
                ),
                body: TabBarView(children: tabViews),
              ),
            );
          },
        );
      },
    );
  }
}
