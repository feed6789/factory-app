// File: lib/features/attendance/views/manager_attendance_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ung_dung_nm/features/attendance/views/tab_cham_cong_ngay.dart';
import 'package:ung_dung_nm/features/attendance/views/tab_bang_cong_thang.dart';
import 'package:ung_dung_nm/features/attendance/views/tab_danh_gia_xep_loai.dart';
import 'package:ung_dung_nm/features/admin/controllers/department_controller.dart';

class ManagerAttendancePage extends StatelessWidget {
  final String profileId;
  const ManagerAttendancePage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // ĐỔI TỪ 3 THÀNH 4
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý Chấm Công"),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orangeAccent,
            tabs: [
              Tab(icon: Icon(Icons.playlist_add_check), text: "Chấm Công Ngày"),
              Tab(icon: Icon(Icons.grid_on), text: "Bảng Tháng"),
              Tab(icon: Icon(Icons.star_rate), text: "Đánh Giá Xếp Loại"),
              Tab(icon: Icon(Icons.settings), text: "Cấu Hình"), // TAB THÊM MỚI
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TabChamCongNgay(currentUserId: profileId),
            const TabBangCongThang(),
            const TabDanhGiaXepLoai(),
            const AttendanceConfigTab(), // TÊN CLASS VỪA ĐEM TỪ BÊN KIA SANG (Nhớ bỏ dấu _ nếu báo lỗi)
          ],
        ),
      ),
    );
  }
}

// ====================== TAB CẤU HÌNH ĐỘNG (NO-CODE) ======================
class AttendanceConfigTab extends ConsumerWidget {
  const AttendanceConfigTab();

  void _showAddOrEdit(
    BuildContext context,
    WidgetRef ref, {
    required String type,
    Map<String, dynamic>? item,
  }) {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: isEditing ? item['name'] : '');
    final symbolCtrl = TextEditingController(
      text: isEditing ? (item['symbol'] ?? '') : '',
    );
    bool isActive = isEditing ? item['is_active'] : true;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? "Sửa" : "Thêm mới"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: type == 'shift'
                        ? "Tên Ca (VD: Ca Ngày)"
                        : "Trạng thái (VD: Nghỉ phép)",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: symbolCtrl,
                  decoration: const InputDecoration(
                    labelText: "Ký hiệu trên bảng công (VD: X, P)",
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text("Đang sử dụng"),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  final act = ref.read(systemActionProvider);
                  bool success = false;

                  if (type == 'shift') {
                    success = isEditing
                        ? await act.updateShiftConfig(
                            item['id'].toString(),
                            nameCtrl.text,
                            symbolCtrl.text,
                            isActive,
                          )
                        : await act.addShiftConfig(
                            nameCtrl.text,
                            symbolCtrl.text,
                          );
                  } else {
                    success = isEditing
                        ? await act.updateAttendanceStatusConfig(
                            item['id'].toString(),
                            nameCtrl.text,
                            symbolCtrl.text,
                            isActive,
                          )
                        : await act.addAttendanceStatusConfig(
                            nameCtrl.text,
                            symbolCtrl.text,
                          );
                  }

                  if (context.mounted) {
                    Navigator.pop(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Lưu thành công!"
                              : "Lỗi (Có thể trùng tên).",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Lưu"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    String type,
    AsyncValue<List<Map<String, dynamic>>> asyncData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Thêm"),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showAddOrEdit(context, ref, type: type),
              ),
            ],
          ),
        ),
        asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Lỗi: $e")),
          data: (data) {
            if (data.isEmpty)
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Chưa có dữ liệu."),
              );
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (c, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(
                    data[i]['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Ký hiệu: ${data[i]['symbol'] ?? 'Không có'} | Trạng thái: ${data[i]['is_active'] == true ? 'Đang dùng' : 'Đã ẩn'}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddOrEdit(
                          context,
                          ref,
                          type: type,
                          item: data[i],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final act = ref.read(systemActionProvider);
                          final msg = type == 'shift'
                              ? await act.deleteShiftConfig(
                                  data[i]['id'].toString(),
                                )
                              : await act.deleteAttendanceStatusConfig(
                                  data[i]['id'].toString(),
                                );
                          if (context.mounted)
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(msg)));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const Divider(height: 32, thickness: 2),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftData = ref.watch(shiftConfigsProvider);
    final statusData = ref.watch(attendanceStatusConfigsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildSection(
              context,
              ref,
              "1. Cấu hình Ca làm việc",
              "shift",
              shiftData,
            ),
            _buildSection(
              context,
              ref,
              "2. Cấu hình Trạng thái nghỉ/công",
              "status",
              statusData,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
