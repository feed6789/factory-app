// File: lib/features/admin/views/department_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ung_dung_nm/features/admin/controllers/department_controller.dart';

// --- HẰNG SỐ CẤU HÌNH ---
const Map<String, String> ALL_FEATURES = {
  "nhan_su": "Quản lý Nhân sự",
  "phong_ban": "Cơ Cấu Tổ Chức & Cấu Hình",
  "cham_cong_tram": "Chấm Công Tổ/Trạm",
  "duyet_don": "Duyệt Đơn Từ",
  "cong_ca_nhan": "Bảng Công & Xin Nghỉ Cá Nhân",
  "bao_cao": "Báo cáo & Thống kê",
  "vat_tu": "Quản lý Vật tư",
  "tai_san": "Quản lý Tài sản",
  "san_xuat": "Nhật ký Sản xuất",
  "giao_viec": "Giao Việc",
};
const List<String> ROLES = [
  'admin',
  'director',
  'team_leader',
  'section_head',
  'office_staff',
  'worker',
];

class DepartmentManagementPage extends ConsumerWidget {
  const DepartmentManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4, // ĐÃ TĂNG LÊN 4 TAB
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cơ Cấu & Cấu Hình Hệ Thống",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // --- ĐÃ SỬA MÀU SẮC TẠI ĐÂY ---
          backgroundColor: Colors.blue.shade800, // Nền xanh đậm
          foregroundColor: Colors.white, // Chữ trắng
          bottom: const TabBar(
            isScrollable: true, // Cuộn được nếu màn hình điện thoại nhỏ
            labelColor: Colors.orangeAccent, // Tab đang chọn màu cam sáng
            unselectedLabelColor: Colors.white70, // Tab không chọn màu trắng mờ
            indicatorColor: Colors.orangeAccent, // Vạch chân màu cam
            tabs: [
              Tab(icon: Icon(Icons.apartment), text: "Bộ Phận"),
              Tab(icon: Icon(Icons.business), text: "Phòng Ban"),
              Tab(icon: Icon(Icons.security), text: "Phân Quyền App"),
              Tab(icon: Icon(Icons.account_tree), text: "Cấp Bậc Quản Lý"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DivisionTab(),
            _DepartmentTab(),
            _RolePermissionsTab(),
            _RoleHierarchyTab(),
          ],
        ),
      ),
    );
  }
}

// ====================== TAB 1: BỘ PHẬN ======================
class _DivisionTab extends ConsumerWidget {
  const _DivisionTab();

  void _showAddOrEdit(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? item,
  }) {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: isEditing ? item['name'] : '');
    final descCtrl = TextEditingController(
      text: isEditing ? item['description'] : '',
    );

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEditing ? "Sửa Bộ Phận" : "Thêm Bộ Phận"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Tên bộ phận"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Mô tả"),
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
              final success = isEditing
                  ? await act.updateDivision(
                      item['id'],
                      nameCtrl.text,
                      descCtrl.text,
                    )
                  : await act.addDivision(nameCtrl.text, descCtrl.text);
              if (context.mounted) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "Thành công!" : "Thất bại."),
                  ),
                );
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(divisionListProvider);
    return Scaffold(
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi: $e")),
        data: (data) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (c, i) => Card(
            child: ListTile(
              title: Text(
                data[i]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['description'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _showAddOrEdit(context, ref, item: data[i]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      if (await _confirmDelete(context, data[i]['name'])) {
                        final result = await ref
                            .read(systemActionProvider)
                            .deleteDivision(data[i]['id']);
                        if (context.mounted)
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEdit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Xác nhận xóa"),
            content: Text("Xóa bộ phận '$name'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ====================== TAB 2: PHÒNG BAN ======================
class _DepartmentTab extends ConsumerWidget {
  const _DepartmentTab();

  void _showAddOrEdit(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? item,
  }) {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: isEditing ? item['name'] : '');
    final descCtrl = TextEditingController(
      text: isEditing ? item['description'] : '',
    );
    String? selectedDivId = item?['division_id'];

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          final divAsync = ref.watch(divisionListProvider);
          return AlertDialog(
            title: Text(isEditing ? "Sửa Phòng Ban" : "Thêm Phòng Ban"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Tên phòng ban"),
                ),
                divAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => const Text("Lỗi tải bộ phận"),
                  data: (divisions) => DropdownButtonFormField<String>(
                    value: selectedDivId,
                    hint: const Text("Thuộc bộ phận nào? (Ko bắt buộc)"),
                    items: divisions
                        .map(
                          (div) => DropdownMenuItem(
                            value: div['id'].toString(),
                            child: Text(div['name'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedDivId = v),
                  ),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Mô tả"),
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
                  final success = isEditing
                      ? await act.updateDepartment(
                          id: item['id'],
                          name: nameCtrl.text,
                          description: descCtrl.text,
                          divisionId: selectedDivId,
                        )
                      : await act.addDepartment(
                          name: nameCtrl.text,
                          description: descCtrl.text,
                          divisionId: selectedDivId,
                        );
                  if (context.mounted) {
                    Navigator.pop(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? "Thành công!" : "Thất bại."),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(departmentListProvider);
    return Scaffold(
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi: $e")),
        data: (data) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (c, i) => Card(
            child: ListTile(
              title: Text(
                data[i]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['description'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _showAddOrEdit(context, ref, item: data[i]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm =
                          await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text("Xác nhận xóa"),
                              content: Text(
                                "Xóa phòng ban '${data[i]['name']}'?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text("Hủy"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text(
                                    "Xóa",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (confirm) {
                        final result = await ref
                            .read(systemActionProvider)
                            .deleteDepartment(data[i]['id']);
                        if (context.mounted)
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEdit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ====================== TAB 3: PHÂN QUYỀN APP ======================
class _RolePermissionsTab extends ConsumerWidget {
  const _RolePermissionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(rolePermissionsProvider);

    return permissionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi: $e")),
      data: (perms) {
        return ListView.builder(
          itemCount: ROLES.length,
          itemBuilder: (context, index) {
            final role = ROLES[index];
            final existingRecord = perms
                .where((p) => p['role'] == role)
                .toList();
            List<dynamic> currentFeatures = existingRecord.isNotEmpty
                ? existingRecord.first['allowed_features']
                : [];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  "Chức vụ: ${role.toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                children: ALL_FEATURES.entries.map((feature) {
                  final isAllowed = currentFeatures.contains(feature.key);
                  return CheckboxListTile(
                    title: Text(feature.value),
                    value: isAllowed,
                    activeColor: Colors.blue.shade800,
                    onChanged: (bool? checked) async {
                      if (checked == null) return;
                      List<String> newFeatures = List<String>.from(
                        currentFeatures,
                      );
                      if (checked) {
                        newFeatures.add(feature.key);
                      } else {
                        newFeatures.remove(feature.key);
                      }

                      await ref
                          .read(systemActionProvider)
                          .updateRolePermissions(role, newFeatures);
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

// ====================== TAB 4: PHÂN CẤP QUẢN LÝ ======================
class _RoleHierarchyTab extends ConsumerWidget {
  const _RoleHierarchyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hierarchyAsync = ref.watch(roleHierarchyProvider);

    return hierarchyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi: $e")),
      data: (hierarchy) {
        return ListView.builder(
          itemCount: ROLES.length,
          itemBuilder: (context, index) {
            final role = ROLES[index];
            final managedByRoles = hierarchy
                .where((h) => h['role'] == role)
                .map((h) => h['managed_by_role'])
                .toList();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                title: Text(
                  "Chức vụ: ${role.toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 8,
                    children: managedByRoles
                        .map(
                          (m) => Chip(
                            label: Text(
                              "Báo cáo cho: $m",
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            deleteIconColor: Colors.red,
                            onDeleted: () => ref
                                .read(systemActionProvider)
                                .deleteRoleHierarchy(role, m.toString()),
                          ),
                        )
                        .toList(),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  tooltip: "Thêm người quản lý",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => SimpleDialog(
                        title: Text("Thêm cấp trên cho $role"),
                        children: ROLES
                            .where(
                              (r) => r != role && !managedByRoles.contains(r),
                            )
                            .map(
                              (r) => ListTile(
                                leading: const Icon(Icons.person_add),
                                title: Text(r),
                                onTap: () {
                                  ref
                                      .read(systemActionProvider)
                                      .addRoleHierarchy(role, r);
                                  Navigator.pop(c);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
