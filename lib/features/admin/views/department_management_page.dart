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
          tabs.add(const Tab(icon: Icon(Icons.account_tree), text: "Cấp Bậc"));
          tabViews.add(const _RoleHierarchyTab());
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
        return permissionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text("Lỗi: $e"),
          data: (perms) {
            return ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final roleCode = roles[index]['code'];
                final roleName = roles[index]['name'];

                if (roleCode == 'admin') {
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        "Chức vụ: $roleName",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      subtitle: const Text(
                        "Tài khoản mặc định có TẤT CẢ quyền. Không thể chỉnh sửa.",
                      ),
                      trailing: const Icon(Icons.lock, color: Colors.red),
                    ),
                  );
                }

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
                      "Chức vụ: $roleName",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    children: GROUP_NAMES.entries.map((group) {
                      final featuresInGroup = ALL_FEATURES_NESTED[group.key]!;
                      final Set<String> groupFeatureKeys = featuresInGroup.keys
                          .map((e) => e.toString()) // Đảm bảo chuyển về string
                          .toSet();
                      final Set<String> selectedFeaturesInGroup =
                          currentFeatures
                              .where((f) => groupFeatureKeys.contains(f))
                              .toSet();

                      // LOGIC MỚI: Xác định trạng thái của Checkbox "Chọn tất cả"
                      final bool isAllSelected =
                          selectedFeaturesInGroup.length ==
                          groupFeatureKeys.length;
                      // tristate cho phép có trạng thái gạch ngang (khi chỉ chọn 1 vài cái)
                      final bool isIndeterminate =
                          selectedFeaturesInGroup.isNotEmpty && !isAllSelected;

                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CHECKBOX "CHỌN TẤT CẢ"
                            CheckboxListTile(
                              title: Text(
                                group.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              value: isIndeterminate ? null : isAllSelected,
                              tristate: true, // Cho phép trạng thái gạch ngang
                              onChanged: (bool? checked) {
                                List<String> newFeatures = List.from(
                                  currentFeatures,
                                );
                                if (checked == true) {
                                  // Khi tick chọn
                                  // Thêm tất cả quyền con của nhóm này vào
                                  newFeatures.addAll(groupFeatureKeys);
                                  // Xóa các quyền trùng lặp
                                  newFeatures = newFeatures.toSet().toList();
                                } else {
                                  // Khi bỏ tick
                                  // Xóa tất cả quyền con của nhóm này đi
                                  newFeatures.removeWhere(
                                    (feature) =>
                                        groupFeatureKeys.contains(feature),
                                  );
                                }
                                // Cập nhật lên Supabase
                                ref
                                    .read(systemActionProvider)
                                    .updateRolePermissions(
                                      roleCode,
                                      newFeatures,
                                    );
                              },
                            ),

                            // Danh sách các quyền con
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: Column(
                                children: featuresInGroup.entries.map((
                                  feature,
                                ) {
                                  final isAllowed = currentFeatures.contains(
                                    feature.key,
                                  );
                                  return CheckboxListTile(
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    title: Text(
                                      feature.value,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    value: isAllowed,
                                    onChanged: (bool? checked) {
                                      if (checked == null) return;
                                      List<String> newFeatures = List.from(
                                        currentFeatures,
                                      );
                                      if (checked) {
                                        newFeatures.add(feature.key);
                                      } else {
                                        newFeatures.remove(feature.key);
                                      }
                                      ref
                                          .read(systemActionProvider)
                                          .updateRolePermissions(
                                            roleCode,
                                            newFeatures,
                                          );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
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

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEditing ? "Sửa Chức Vụ" : "Thêm Chức Vụ Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              enabled: !isEditing, // Đã tạo thì không cho sửa mã Code
              decoration: const InputDecoration(
                labelText: "Mã chức vụ (VD: manager)",
              ),
            ),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Tên hiển thị"),
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
              final success = isEditing
                  ? await act.updateRole(
                      codeCtrl.text.trim(),
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
                    )
                  : await act.addRole(
                      codeCtrl.text.trim(),
                      nameCtrl.text.trim(),
                      descCtrl.text.trim(),
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

// ====================== TAB 4: PHÂN CẤP QUẢN LÝ ======================
class _RoleHierarchyTab extends ConsumerWidget {
  const _RoleHierarchyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy danh sách cấu hình cấp bậc
    final hierarchyAsync = ref.watch(roleHierarchyProvider);
    // Lấy danh sách chức vụ động
    final rolesAsync = ref.watch(roleListProvider);

    return rolesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi tải chức vụ: $e")),
      data: (roles) {
        return hierarchyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Lỗi tải cấp bậc: $e")),
          data: (hierarchy) {
            return ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final roleCode = roles[index]['code'];
                final roleName = roles[index]['name'];

                // Tìm xem chức vụ này phải báo cáo cho những ai
                final managedByRoles = hierarchy
                    .where((h) => h['role'] == roleCode)
                    .map((h) => h['managed_by_role'])
                    .toList();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      "Chức vụ: $roleName ($roleCode)",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8,
                        children: managedByRoles.map((mCode) {
                          // Tìm tên hiển thị của chức vụ quản lý để UI thân thiện hơn
                          final managerRoleObj = roles.firstWhere(
                            (r) => r['code'] == mCode,
                            orElse: () => {
                              'name': mCode,
                            }, // Fallback nếu không tìm thấy
                          );
                          final managerName = managerRoleObj['name'];

                          return Chip(
                            label: Text(
                              "Báo cáo cho: $managerName",
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            deleteIconColor: Colors.red,
                            // Chặn không cho xóa cấp bậc nếu là Admin
                            onDeleted: roleCode == 'admin'
                                ? null
                                : () => ref
                                      .read(systemActionProvider)
                                      .deleteRoleHierarchy(
                                        roleCode,
                                        mCode.toString(),
                                      ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Khóa thao tác thêm người quản lý đối với Admin
                    trailing: roleCode == 'admin'
                        ? const Icon(Icons.lock, color: Colors.grey)
                        : IconButton(
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
                                  title: Text("Thêm cấp trên cho:\n$roleName"),
                                  children: roles
                                      .where(
                                        // Ẩn đi chức vụ hiện tại VÀ những chức vụ đã được chọn làm quản lý rồi
                                        (r) =>
                                            r['code'] != roleCode &&
                                            !managedByRoles.contains(r['code']),
                                      )
                                      .map(
                                        (r) => ListTile(
                                          leading: const Icon(
                                            Icons.person_add,
                                            color: Colors.blueGrey,
                                          ),
                                          title: Text(
                                            "${r['name']} (${r['code']})",
                                          ),
                                          onTap: () {
                                            ref
                                                .read(systemActionProvider)
                                                .addRoleHierarchy(
                                                  roleCode,
                                                  r['code'],
                                                );
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
      },
    );
  }
}
