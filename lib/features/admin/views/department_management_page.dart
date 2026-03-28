// File: lib/features/admin/views/department_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ung_dung_nm/features/admin/controllers/department_controller.dart';
import 'package:ung_dung_nm/features/auth/controllers/auth_controller.dart';

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
  "gop_y": "Đóng góp Ý kiến",
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
    final currentUser = ref.watch(currentProfileProvider).valueOrNull;
    final bool isAdmin = currentUser?.role == 'admin';
    final userRole = currentUser?.role ?? '';

    // Gọi provider bình thường (không có ngoặc đơn)
    final allPermissionsAsync = ref.watch(rolePermissionsProvider);

    return allPermissionsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Lỗi: $e"))),
      data: (allPerms) {
        // Tìm quyền của role hiện tại
        final myRoleRecord = allPerms
            .where((p) => p['role'] == userRole)
            .toList();
        final List<dynamic> myFeatures = myRoleRecord.isNotEmpty
            ? myRoleRecord.first['allowed_features']
            : [];

        List<Widget> tabs = [];
        List<Widget> tabViews = [];

        if (isAdmin || myFeatures.contains('phong_ban_bo_phan')) {
          tabs.add(const Tab(icon: Icon(Icons.apartment), text: "Bộ Phận"));
          tabViews.add(const _DivisionTab());
        }
        if (isAdmin || myFeatures.contains('phong_ban_phong_ban')) {
          tabs.add(const Tab(icon: Icon(Icons.business), text: "Phòng Ban"));
          tabViews.add(const _DepartmentTab());
        }
        if (isAdmin || myFeatures.contains('phong_ban_chuc_vu')) {
          tabs.add(const Tab(icon: Icon(Icons.badge), text: "Chức Vụ"));
          tabViews.add(const _RolesTab()); // Đã có class ở dưới
        }
        if (isAdmin || myFeatures.contains('phong_ban_phan_quyen')) {
          tabs.add(const Tab(icon: Icon(Icons.security), text: "Phân Quyền"));
          tabViews.add(const _RolePermissionsTab());
        }
        if (isAdmin || myFeatures.contains('phong_ban_cap_bac')) {
          // Hoặc dùng phong_ban_chuc_vu
          tabs.add(
            const Tab(icon: Icon(Icons.account_tree), text: "Tuyến Duyệt Đơn"),
          );
          tabViews.add(const _ApprovalWorkflowTab());
        }

        if (tabs.isEmpty)
          return const Scaffold(
            body: Center(child: Text("Bạn không có quyền xem trang này.")),
          );

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "Cơ Cấu & Cấu Hình",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              bottom: TabBar(
                isScrollable: true,
                labelColor: Colors.orangeAccent,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.orangeAccent,
                tabs: tabs,
              ),
            ),
            body: TabBarView(children: tabViews),
          ),
        );
      },
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
    final rolesAsync = ref.watch(roleListProvider);

    return rolesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text("Lỗi: $e"),
      data: (roles) {
        // SẮP XẾP ROLE THEO CẤP BẬC TỪ NHỎ (SẾP) ĐẾN LỚN (NHÂN VIÊN)
        final sortedRoles = List<Map<String, dynamic>>.from(roles);
        sortedRoles.sort(
          (a, b) => (a['level_rank'] ?? 4).compareTo(b['level_rank'] ?? 4),
        );

        return permissionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text("Lỗi: $e"),
          data: (perms) {
            return ListView.builder(
              itemCount: sortedRoles.length,
              itemBuilder: (context, index) {
                final roleCode = sortedRoles[index]['code'];
                final roleName = sortedRoles[index]['name'];
                final level = sortedRoles[index]['level_rank'] ?? 4;

                if (roleCode == 'admin')
                  return const SizedBox.shrink(); // Ẩn Admin

                final existingRecord = perms
                    .where((p) => p['role'] == roleCode)
                    .toList();
                List<String> currentFeatures = existingRecord.isNotEmpty
                    ? List<String>.from(
                        existingRecord.first['allowed_features'] as List,
                      )
                    : [];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      "Cấp $level - $roleName ($roleCode)",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    children: GROUP_NAMES.entries.map((group) {
                      final featuresInGroup = ALL_FEATURES_NESTED[group.key]!;
                      final groupFeatureKeys = featuresInGroup.keys
                          .map((e) => e.toString())
                          .toSet();
                      final selectedInGroup = currentFeatures
                          .where((f) => groupFeatureKeys.contains(f))
                          .toSet();
                      final bool isAllSelected =
                          selectedInGroup.length == groupFeatureKeys.length;
                      final bool isIndeterminate =
                          selectedInGroup.isNotEmpty && !isAllSelected;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: Text(
                              group.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: isIndeterminate ? null : isAllSelected,
                            tristate: true,
                            onChanged: (bool? checked) {
                              List<String> newF = List.from(currentFeatures);
                              if (checked == true) {
                                newF.addAll(groupFeatureKeys);
                                newF = newF.toSet().toList();
                              } else {
                                newF.removeWhere(
                                  (f) => groupFeatureKeys.contains(f),
                                );
                              }
                              ref
                                  .read(systemActionProvider)
                                  .updateRolePermissions(roleCode, newF);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Column(
                              children: featuresInGroup.entries.map((f) {
                                return CheckboxListTile(
                                  visualDensity: VisualDensity.compact,
                                  title: Text(f.value),
                                  value: currentFeatures.contains(f.key),
                                  onChanged: (bool? checked) {
                                    List<String> newF = List.from(
                                      currentFeatures,
                                    );
                                    if (checked == true)
                                      newF.add(f.key);
                                    else
                                      newF.remove(f.key);
                                    ref
                                        .read(systemActionProvider)
                                        .updateRolePermissions(roleCode, newF);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Tab Quản lý Chức Vụ động
class _RolesTab extends ConsumerWidget {
  const _RolesTab();

  void _showAddOrEdit(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? item,
  }) {
    final isEditing = item != null;
    final codeCtrl = TextEditingController(text: isEditing ? item['code'] : '');
    final nameCtrl = TextEditingController(text: isEditing ? item['name'] : '');
    final descCtrl = TextEditingController(
      text: isEditing ? item['description'] : '',
    );
    final levelCtrl = TextEditingController(
      text: isEditing ? (item['level_rank']?.toString() ?? '4') : '4',
    );

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEditing ? "Sửa Chức Vụ & Cấp Bậc" : "Thêm Chức Vụ Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              enabled: !isEditing,
              decoration: const InputDecoration(
                labelText: "Mã chức vụ (VD: manager)",
              ),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Tên hiển thị"),
            ),
            TextField(
              controller: levelCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cấp bậc (Level: 0, 1, 2, 3, 4)",
                helperText:
                    "Số càng nhỏ, cấp càng cao. (VD: Giám đốc=1, Quản lý=2, NV=4)",
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
              if (codeCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              final act = ref.read(systemActionProvider);
              final lvl = int.tryParse(levelCtrl.text) ?? 4;
              final success = isEditing
                  ? await act.updateRole(
                      codeCtrl.text.trim(),
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
                      lvl,
                    )
                  : await act.addRole(
                      codeCtrl.text.trim(),
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
                      lvl,
                    );
              if (context.mounted) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? "Thành công!" : "Thất bại/Trùng mã.",
                    ),
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
    final asyncData = ref.watch(roleListProvider);
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
                "${data[i]['name']} (${data[i]['code']})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['description'] ?? ''),
              trailing: data[i]['code'] == 'admin'
                  ? const Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ) // Không cho sửa/xóa admin
                  : Row(
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
                            final act = ref.read(systemActionProvider);
                            final msg = await act.deleteRole(data[i]['code']);
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEdit(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ====================== TAB: TUYẾN DUYỆT ĐƠN (WORKFLOWS) ======================
class _ApprovalWorkflowTab extends ConsumerWidget {
  const _ApprovalWorkflowTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowsAsync = ref.watch(approvalWorkflowsProvider);
    final rolesAsync = ref.watch(roleListProvider);

    return rolesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi tải chức vụ: $e")),
      data: (roles) {
        // Sắp xếp Role theo cấp bậc để hiển thị
        final sortedRoles = List<Map<String, dynamic>>.from(roles);
        sortedRoles.sort(
          (a, b) => (a['level_rank'] ?? 4).compareTo(b['level_rank'] ?? 4),
        );

        return workflowsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Lỗi tải quy trình: $e")),
          data: (workflows) {
            return ListView.builder(
              itemCount: sortedRoles.length,
              itemBuilder: (context, index) {
                final roleCode = sortedRoles[index]['code'];
                final roleName = sortedRoles[index]['name'];
                final level = sortedRoles[index]['level_rank'] ?? 4;

                // GIÁM ĐỐC (CẤP 1) VÀ ADMIN KHÔNG CẦN QUY TRÌNH DUYỆT ĐƠN
                if (roleCode == 'admin' || level <= 1)
                  return const SizedBox.shrink();

                // Lấy các quy trình thuộc về Role này
                final myWorkflows = workflows
                    .where((w) => w['role_code'] == roleCode)
                    .toList();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Chức vụ tạo đơn: $roleName (Cấp $level)",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.alt_route, size: 16),
                              label: const Text("Thêm Quy Trình"),
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _showAddWorkflowDialog(
                                context,
                                ref,
                                sortedRoles,
                                roleCode,
                                roleName,
                                level,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (myWorkflows.isEmpty)
                          const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 18,
                              ), // Thay Emoji bằng Icon chuẩn
                              SizedBox(width: 8),
                              Text(
                                "Chưa cấu hình luồng duyệt. Đơn sẽ không gửi được.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ...myWorkflows.map((wf) {
                          // Lấy mảng các bước duyệt
                          List<dynamic> steps = wf['steps'] ?? [];

                          // Tạo giao diện chuỗi mũi tên: [Người tạo] -> [Người duyệt 1] -> [Giám đốc]
                          List<Widget> stepWidgets = [
                            Chip(
                              label: const Text(
                                "Người làm đơn",
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ];

                          for (var stepCode in steps) {
                            final approverRole = sortedRoles.firstWhere(
                              (r) => r['code'] == stepCode,
                              orElse: () => {'name': stepCode, 'level_rank': 4},
                            );
                            stepWidgets.add(
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.orange,
                                size: 20,
                              ),
                            );
                            stepWidgets.add(
                              Chip(
                                label: Text(
                                  "${approverRole['name']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: approverRole['level_rank'] == 1
                                    ? Colors.purple
                                    : Colors
                                          .blue, // Đánh dấu Giám đốc bằng màu Tím
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.label_important,
                                            color: Colors.blue,
                                            size: 18,
                                          ), // Thay Emoji bằng Icon
                                          const SizedBox(width: 6),
                                          Text(
                                            "${wf['workflow_name']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: stepWidgets,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => ref
                                      .read(systemActionProvider)
                                      .deleteApprovalWorkflow(
                                        wf['id'].toString(),
                                      ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Hộp thoại tạo Quy trình duyệt siêu thông minh
  void _showAddWorkflowDialog(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> allRoles,
    String roleCode,
    String roleName,
    int currentLevel,
  ) {
    final nameCtrl = TextEditingController();
    // Lọc ra những người có cấp bậc CAO HƠN người làm đơn (level_rank nhỏ hơn)
    final availableApprovers = allRoles
        .where(
          (r) => (r['level_rank'] ?? 4) < currentLevel && r['code'] != 'admin',
        )
        .toList();
    List<String> selectedSteps = [];
    String selectedModule = 'leave_request';

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Tạo quy trình cho: $roleName"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- THÊM DROPDOWN CHỌN LOẠI QUY TRÌNH ---
                  const Text(
                    "Áp dụng cho tính năng:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedModule,
                        items: const [
                          DropdownMenuItem(
                            value: 'leave_request',
                            child: Text("Đơn Xin Nghỉ Phép"),
                          ),
                          DropdownMenuItem(
                            value: 'material_request',
                            child: Text("Phiếu Đề Xuất Vật Tư"),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => selectedModule = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Tên quy trình",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tick chọn những cấp sẽ tham gia duyệt đơn này:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "(Hệ thống sẽ tự động sắp xếp theo thứ tự cấp bậc từ thấp đến Giám đốc)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ...availableApprovers.map((r) {
                    final rCode = r['code'].toString();
                    final isDirector = r['level_rank'] == 1;
                    return CheckboxListTile(
                      title: Text(
                        "${r['name']} (Cấp ${r['level_rank']})",
                        style: TextStyle(
                          color: isDirector ? Colors.purple : Colors.black87,
                          fontWeight: isDirector
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      value: selectedSteps.contains(rCode),
                      onChanged: (val) {
                        setState(() {
                          if (val == true)
                            selectedSteps.add(rCode);
                          else
                            selectedSteps.remove(rCode);
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || selectedSteps.isEmpty) return;

                  // THUẬT TOÁN SẮP XẾP LẠI THỨ TỰ DUYỆT TỪ DƯỚI LÊN GIÁM ĐỐC
                  selectedSteps.sort((a, b) {
                    final levelA =
                        allRoles.firstWhere(
                          (r) => r['code'] == a,
                          orElse: () => {'level_rank': 0},
                        )['level_rank'] ??
                        0;
                    final levelB =
                        allRoles.firstWhere(
                          (r) => r['code'] == b,
                          orElse: () => {'level_rank': 0},
                        )['level_rank'] ??
                        0;
                    return levelB.compareTo(levelA); // Sort giảm dần
                  });

                  final success = await ref
                      .read(systemActionProvider)
                      .addApprovalWorkflow(
                        roleCode,
                        nameCtrl.text,
                        selectedModule,
                        selectedSteps,
                      );

                  if (context.mounted) {
                    Navigator.pop(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? "Đã lưu quy trình!" : "Lỗi khi lưu.",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("TẠO QUY TRÌNH"),
              ),
            ],
          );
        },
      ),
    );
  }
}
