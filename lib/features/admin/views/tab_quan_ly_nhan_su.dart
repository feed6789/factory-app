// File: lib/features/admin/views/tab_quan_ly_nhan_su.dart
// *** PHIÊN BẢN HOÀN CHỈNH VỚI GIAO DIỆN RESPONSIVE ***

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ung_dung_nm/features/admin/controllers/department_controller.dart';
import '../controllers/employee_controller.dart';
import '../../attendance/models/profile_model.dart';

class TabQuanLyNhanSu extends ConsumerStatefulWidget {
  const TabQuanLyNhanSu({super.key});

  @override
  ConsumerState<TabQuanLyNhanSu> createState() => _TabQuanLyNhanSuState();
}

class _TabQuanLyNhanSuState extends ConsumerState<TabQuanLyNhanSu> {
  // CÁC BIẾN LƯU TRẠNG THÁI BỘ LỌC
  String searchQuery = '';
  String filterRole = 'Tất cả';
  String filterStatus = 'Tất cả';

  final List<String> roleOptions = [
    'Tất cả',
    'admin',
    'director',
    'team_leader',
    'section_head',
    'office_staff',
    'worker',
  ];
  final List<String> statusOptions = ['Tất cả', 'Đang hoạt động', 'Đã khóa'];

  @override
  Widget build(BuildContext context) {
    final employeeAsync = ref.watch(employeeListProvider);
    ref.watch(departmentListProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Quản Lý Nhân Sự",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800, // Đồng bộ màu xanh
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(employeeListProvider);
              ref.invalidate(departmentListProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // BỘ LỌC (FILTER BAR)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // 1. Ô Tìm kiếm
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Tìm tên hoặc Mã NV...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) =>
                        setState(() => searchQuery = val.toLowerCase()),
                  ),
                ),
                // 2. Lọc Vai trò
                _buildFilterDropdown(
                  "Chức vụ:",
                  filterRole,
                  roleOptions,
                  (val) => setState(() => filterRole = val!),
                ),
                // 3. Lọc Trạng thái
                _buildFilterDropdown(
                  "Trạng thái:",
                  filterStatus,
                  statusOptions,
                  (val) => setState(() => filterStatus = val!),
                ),
              ],
            ),
          ),

          // DANH SÁCH NHÂN VIÊN
          Expanded(
            child: employeeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text("Lỗi tải danh sách: $err")),
              data: (allEmployees) {
                // ÁP DỤNG LOGIC LỌC DỮ LIỆU
                final employees = allEmployees.where((emp) {
                  // Lọc tìm kiếm
                  bool matchSearch =
                      emp.fullName.toLowerCase().contains(searchQuery) ||
                      emp.employeeCode.toLowerCase().contains(searchQuery);
                  // Lọc chức vụ
                  bool matchRole =
                      filterRole == 'Tất cả' || emp.role == filterRole;
                  // Lọc trạng thái
                  bool matchStatus = true;
                  if (filterStatus == 'Đang hoạt động')
                    matchStatus = emp.isActive;
                  if (filterStatus == 'Đã khóa') matchStatus = !emp.isActive;

                  return matchSearch && matchRole && matchStatus;
                }).toList();

                if (employees.isEmpty)
                  return const Center(
                    child: Text("Không tìm thấy nhân viên nào phù hợp."),
                  );

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 768) {
                      return _buildWebView(context, ref, employees);
                    }
                    return _buildMobileView(context, ref, employees);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text("Thêm NV"),
      ),
    );
  }

  // Widget hỗ trợ vẽ Dropdown lọc
  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // GIAO DIỆN CHO WEB/DESKTOP (Dạng Bảng)
  Widget _buildWebView(
    BuildContext context,
    WidgetRef ref,
    List<ProfileModel> employees,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(
                label: Text(
                  'Trạng thái',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Họ và Tên',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Số điện thoại',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Mã Nhân Viên',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Vai trò',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Hành động',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: employees
                .map(
                  (emp) => DataRow(
                    onSelectChanged: (selected) {
                      if (selected ?? false) {
                        _showEditDialog(context, ref, emp);
                      }
                    },
                    cells: [
                      DataCell(
                        Icon(
                          Icons.circle,
                          color: emp.isActive ? Colors.green : Colors.grey,
                          size: 14,
                        ),
                      ),
                      DataCell(
                        Text(
                          emp.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(Text(emp.email ?? '')),
                      DataCell(Text(emp.phoneNumber ?? '')),
                      DataCell(Text(emp.employeeCode)),
                      DataCell(Chip(label: Text(emp.role))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: "Chỉnh sửa",
                              onPressed: () =>
                                  _showEditDialog(context, ref, emp),
                            ),
                            _buildLockUnlockButton(context, ref, emp),

                            // ---- THÊM NÚT XÓA TẠI ĐÂY ----
                            IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              tooltip: "Xóa vĩnh viễn",
                              onPressed: () async {
                                final confirm = await _showConfirmationDialog(
                                  context,
                                  title: "Xác nhận XÓA VĨNH VIỄN",
                                  content:
                                      "Bạn có chắc muốn XÓA VĨNH VIỄN nhân viên ${emp.fullName}? Hành động này không thể hoàn tác và sẽ xóa mọi dữ liệu liên quan.",
                                  confirmText: "Xóa Vĩnh Viễn",
                                );
                                if (confirm == true) {
                                  await ref
                                      .read(employeeActionProvider)
                                      .deleteEmployee(emp.id);
                                }
                              },
                            ),
                            // --------------------------------
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // GIAO DIỆN CHO MOBILE (Dạng Card cải tiến)
  Widget _buildMobileView(
    BuildContext context,
    WidgetRef ref,
    List<ProfileModel> employees,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        80,
      ), // Thêm padding dưới cho FAB
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final emp = employees[index];
        return Card(
          color: emp.isActive ? Colors.white : Colors.grey.shade200,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showEditDialog(context, ref, emp),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: emp.isActive
                            ? Colors.blue.shade100
                            : Colors.grey.shade400,
                        child: Text(
                          emp.fullName.isNotEmpty
                              ? emp.fullName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          emp.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: emp.isActive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: emp.isActive
                            ? Colors.green.shade400
                            : Colors.grey.shade500,
                        size: 12,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.badge_outlined, size: 16),
                        label: Text(emp.employeeCode),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        avatar: const Icon(Icons.work_outline, size: 16),
                        label: Text(emp.role),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (emp.email != null && emp.email!.isNotEmpty)
                        Chip(
                          avatar: const Icon(Icons.email_outlined, size: 16),
                          label: Text(emp.email!),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (emp.phoneNumber != null &&
                          emp.phoneNumber!.isNotEmpty)
                        Chip(
                          avatar: const Icon(Icons.phone_outlined, size: 16),
                          label: Text(emp.phoneNumber!),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildLockUnlockButton(context, ref, emp),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Color.fromARGB(255, 226, 49, 49),
                        ),
                        tooltip: "Xóa vĩnh viễn",
                        onPressed: () async {
                          final confirm = await _showConfirmationDialog(
                            context,
                            title: "Xác nhận XÓA VĨNH VIỄN",
                            content:
                                "Bạn có chắc muốn XÓA VĨNH VIỄN nhân viên ${emp.fullName}? Hành động này không thể hoàn tác và sẽ xóa mọi dữ liệu liên quan.",
                            confirmText: "Xóa Vĩnh Viễn",
                          );
                          if (confirm == true) {
                            await ref
                                .read(employeeActionProvider)
                                .deleteEmployee(emp.id);
                          }
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Chỉnh sửa"),
                        onPressed: () => _showEditDialog(context, ref, emp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget chung cho nút Khóa/Mở khóa
  Widget _buildLockUnlockButton(
    BuildContext context,
    WidgetRef ref,
    ProfileModel emp,
  ) {
    return emp.isActive
        ? IconButton(
            icon: Icon(Icons.lock_outline, color: Colors.orange.shade700),
            tooltip: "Khóa tài khoản",
            onPressed: () async {
              final confirm = await _showConfirmationDialog(
                context,
                title: "Xác nhận khóa",
                content: "Bạn có muốn tạm khóa tài khoản của ${emp.fullName}?",
                confirmText: "Khóa",
              );
              if (confirm == true) {
                await ref
                    .read(employeeActionProvider)
                    .setEmployeeActiveStatus(emp.id, false);
              }
            },
          )
        : IconButton(
            icon: Icon(Icons.lock_open_outlined, color: Colors.green.shade600),
            tooltip: "Mở khóa tài khoản",
            onPressed: () async {
              final confirm = await _showConfirmationDialog(
                context,
                title: "Xác nhận mở khóa",
                content: "Kích hoạt lại tài khoản cho ${emp.fullName}?",
                confirmText: "Mở khóa",
                isDestructive: false,
              );
              if (confirm == true) {
                await ref
                    .read(employeeActionProvider)
                    .setEmployeeActiveStatus(emp.id, true);
              }
            },
          );
  }

  // Hiển thị Dialog (Hộp thoại) Sửa thông tin
  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ProfileModel profile,
  ) {
    final nameCtrl = TextEditingController(text: profile.fullName);
    final codeCtrl = TextEditingController(text: profile.employeeCode);
    // Đã sửa lỗi undefined bằng cách gọi thẳng profile.email và profile.phoneNumber
    final emailCtrl = TextEditingController(text: profile.email ?? '');
    final phoneCtrl = TextEditingController(text: profile.phoneNumber ?? '');
    final hierarchyAsync = ref.watch(roleHierarchyProvider);

    const validRoles = [
      'worker',
      'team_leader',
      'section_head',
      'office_staff',
      'director',
      'admin',
    ];
    String selectedRole = validRoles.contains(profile.role)
        ? profile.role
        : 'worker';

    bool isActive = profile.isActive;
    String? selectedDepartmentId = profile.departmentId;
    String? selectedDivisionId = profile.divisionId;
    String? selectedManagerId = profile.managerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final departmentsAsync = ref.watch(departmentListProvider);
          final employeesAsync = ref.watch(employeeListProvider);
          return AlertDialog(
            title: const Text("Sửa thông tin & Phân cấp"),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Họ và tên"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(labelText: "Mã NV"),
                    ),
                    const SizedBox(height: 12),
                    // THÊM 2 Ô NHẬP LIỆU MỚI
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Email liên lạc",
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    // 1. DROPDOWN CHỌN BỘ PHẬN (MỚI)
                    ref
                        .watch(divisionListProvider)
                        .when(
                          loading: () => const CircularProgressIndicator(),
                          error: (err, stack) => Text("Lỗi: $err"),
                          data: (divisions) => DropdownButtonFormField<String>(
                            value: selectedDivisionId,
                            decoration: const InputDecoration(
                              labelText: "Bộ phận (Không bắt buộc)",
                            ),
                            items: divisions
                                .map(
                                  (div) => DropdownMenuItem(
                                    value: div['id'].toString(),
                                    child: Text(div['name'].toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedDivisionId = val),
                          ),
                        ),
                    const SizedBox(height: 12),
                    departmentsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text("Lỗi tải phòng ban: $err"),
                      data: (departments) {
                        return DropdownButtonFormField<String>(
                          value: selectedDepartmentId,
                          hint: const Text("Chọn phòng ban"),
                          decoration: const InputDecoration(
                            labelText: "Phòng Ban",
                          ),
                          items: departments
                              .map(
                                (dept) => DropdownMenuItem(
                                  value: dept['id'].toString(),
                                  child: Text(dept['name'].toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedDepartmentId = val),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Vai trò trong tổ chức",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'worker',
                          child: Text("Nhân viên"),
                        ),
                        DropdownMenuItem(
                          value: 'team_leader',
                          child: Text("Tổ trưởng"),
                        ),
                        DropdownMenuItem(
                          value: 'section_head',
                          child: Text("Trưởng công đoạn"),
                        ),
                        DropdownMenuItem(
                          value: 'office_staff',
                          child: Text("NV Văn phòng"),
                        ),
                        DropdownMenuItem(
                          value: 'director',
                          child: Text("Ban Giám đốc"),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text("Admin Hệ thống"),
                        ),
                      ],
                      onChanged: (val) => setState(() => selectedRole = val!),
                    ),
                    const SizedBox(height: 12),
                    hierarchyAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const Text("Lỗi tải phân cấp"),
                      data: (hierarchyList) {
                        return employeesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (e, s) => const Text("Lỗi tải NV"),
                          data: (employees) {
                            final allowedManagerRoles = hierarchyList
                                .where((h) => h['role'] == selectedRole)
                                .map((h) => h['managed_by_role'] as String)
                                .toList();

                            // LOGIC LỌC:
                            // - Cùng Role hợp lệ
                            // - Không phải chính mình
                            // - Nếu là quản lý cấp trung (team_leader, section_head), phải cùng bộ phận HOẶC phòng ban
                            final validManagers = employees.where((e) {
                              if (e.id == profile.id) return false;
                              if (!allowedManagerRoles.contains(e.role))
                                return false;

                              if (e.role == 'team_leader' ||
                                  e.role == 'section_head') {
                                bool matchDept =
                                    selectedDepartmentId == null ||
                                    e.departmentId == selectedDepartmentId;
                                bool matchDiv =
                                    selectedDivisionId == null ||
                                    e.divisionId == selectedDivisionId;
                                return matchDept && matchDiv;
                              }
                              return true; // director/admin không bị giới hạn bộ phận
                            }).toList();

                            // Reset nếu manager đang chọn không còn hợp lệ
                            if (selectedManagerId != null &&
                                !validManagers.any(
                                  (m) => m.id == selectedManagerId,
                                )) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => setState(() => selectedManagerId = null),
                              );
                            }

                            return DropdownButtonFormField<String>(
                              value: selectedManagerId,
                              decoration: const InputDecoration(
                                labelText: "Người quản lý trực tiếp",
                              ),
                              items: validManagers
                                  .map(
                                    (manager) => DropdownMenuItem(
                                      value: manager.id,
                                      child: Text(
                                        "${manager.fullName} (${manager.role})",
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => selectedManagerId = val),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text("Trạng thái hoạt động"),
                      value: isActive,
                      activeColor: Colors.green,
                      onChanged: (val) => setState(() => isActive = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await ref
                      .read(employeeActionProvider)
                      .updateProfile(
                        id: profile.id,
                        fullName: nameCtrl.text.trim(),
                        empCode: codeCtrl.text.trim(),
                        role: selectedRole,
                        isActive: isActive,
                        departmentId: selectedDepartmentId,
                        divisionId: selectedDivisionId,
                        managerId: selectedManagerId,
                        email: emailCtrl.text.trim(), // Lưu email
                        phoneNumber: phoneCtrl.text.trim(), // Lưu SĐT
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? "Cập nhật thành công!" : "Lỗi cập nhật",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("LƯU"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(); // MỚI THÊM: Ô nhập SĐT
    String selectedRole = 'worker';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Thêm Nhân Viên Mới"),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Họ và tên"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(labelText: "Mã NV"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Email đăng nhập",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: "Mật khẩu (ít nhất 6 ký tự)",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                      ),
                      keyboardType: TextInputType.phone,
                    ), // THÊM UI CHO SĐT
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Phân quyền (Role)",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'worker',
                          child: Text("Nhân viên"),
                        ),
                        DropdownMenuItem(
                          value: 'team_leader',
                          child: Text("Tổ trưởng"),
                        ),
                        DropdownMenuItem(
                          value: 'section_head',
                          child: Text("Trưởng công đoạn"),
                        ),
                        DropdownMenuItem(
                          value: 'office_staff',
                          child: Text("NV Văn phòng"),
                        ),
                        DropdownMenuItem(
                          value: 'director',
                          child: Text("Ban Giám đốc"),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text("Admin Hệ thống"),
                        ),
                      ],
                      onChanged: (val) => setState(() => selectedRole = val!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty ||
                      codeCtrl.text.isEmpty ||
                      emailCtrl.text.isEmpty ||
                      passwordCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng nhập đủ thông tin (trừ SĐT)"),
                      ),
                    );
                    return;
                  }
                  final success = await ref
                      .read(employeeActionProvider)
                      .addEmployee(
                        fullName: nameCtrl.text.trim(),
                        empCode: codeCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        password: passwordCtrl.text.trim(),
                        role: selectedRole,
                        phoneNumber: phoneCtrl.text.trim(), // Truyền SĐT
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? "Thêm thành công!" : "Thêm thất bại.",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("TẠO MỚI"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Hàm helper để hiển thị dialog xác nhận chung
  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Hủy"),
          ),
          isDestructive
              ? TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(
                    confirmText,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ElevatedButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(confirmText),
                ),
        ],
      ),
    );
  }
}
