import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/views/main_navigation_page.dart';

// --- PROVIDERS ---
final materialsProvider = FutureProvider.family<List<dynamic>, String?>((
  ref,
  departmentId,
) async {
  var query = ref.read(supabaseProvider).from('factory_materials').select();
  if (departmentId != null) {
    query = query.or('department_id.eq.$departmentId,department_id.is.null');
  }
  final res = await query.order('name');
  return res;
});

final machinesProvider = FutureProvider((ref) async {
  final res = await ref
      .read(supabaseProvider)
      .from('factory_machines')
      .select();
  return res;
});

final transactionsProvider = FutureProvider.family<List<dynamic>, String?>((
  ref,
  departmentId,
) async {
  var query = ref
      .read(supabaseProvider)
      .from('material_transactions')
      .select(
        '*, factory_materials!inner(name, category, department_id), profiles(full_name), factory_machines(name)',
      );

  if (departmentId != null) {
    query = query.or(
      'factory_materials.department_id.eq.$departmentId,factory_materials.department_id.is.null',
    );
  }

  final res = await query.order('created_at', ascending: false);
  return res;
});

// --- GIAO DIỆN CHÍNH ---
class InventoryMainPage extends ConsumerWidget {
  const InventoryMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản Lý Vật Tư"),
          backgroundColor: Colors.brown.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.table_chart), text: "Bảng Vật Tư"),
              Tab(icon: Icon(Icons.history), text: "Lịch Sử Nhập/Xuất"),
              Tab(icon: Icon(Icons.settings), text: "Cấu Hình"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MaterialTableTab(),
            TransactionHistoryTab(),
            SettingsInventoryTab(),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: BẢNG GIỐNG EXCEL ---
class MaterialTableTab extends ConsumerWidget {
  const MaterialTableTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final departmentId =
        (profile?.role == 'admin' || profile?.role == 'director')
        ? null
        : profile?.departmentId;

    final materialsAsync = ref.watch(materialsProvider(departmentId));

    return materialsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi: $e")),
      data: (data) {
        if (data.isEmpty)
          return const Center(
            child: Text(
              "Chưa có danh mục vật tư nào. Hãy qua Tab Cấu hình để tạo.",
            ),
          );

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Cho phép cuộn ngang như Excel
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
              border: TableBorder.all(color: Colors.grey.shade300),
              columns: const [
                DataColumn(
                  label: Text(
                    'Loại VT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tên Vật Tư',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ĐVT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Đầu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Nhập',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Xuất',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Còn Lại',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Hành Động',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item['category'])),
                    DataCell(
                      Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text(item['unit'])),
                    DataCell(Text(item['initial_qty'].toString())),
                    DataCell(
                      Text(
                        item['total_import'].toString(),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    DataCell(
                      Text(
                        item['total_export'].toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    DataCell(
                      Text(
                        item['current_qty'].toString(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _showTransactionDialog(
                              context,
                              ref,
                              item,
                              'IMPORT',
                            ),
                            child: const Text(
                              "Nhập",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _showTransactionDialog(
                              context,
                              ref,
                              item,
                              'EXPORT',
                            ),
                            child: const Text(
                              "Xuất",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // --- DIALOG NHẬP/XUẤT ---
  void _showTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> material,
    String type,
  ) {
    final isImport = type == 'IMPORT';
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now(); // Ngày ghi mặc định hôm nay
    String? selectedMachineId;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          final machinesAsync = ref.watch(machinesProvider);

          return AlertDialog(
            title: Text(
              isImport
                  ? "Nhập Kho: ${material['name']}"
                  : "Xuất Kho: ${material['name']}",
              style: TextStyle(
                color: isImport ? Colors.blue : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chọn ngày (Mặc định hôm nay, có thể sửa)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Ngày giao dịch"),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate:
                            DateTime.now(), // Không cho chọn ngày tương lai
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          "Số lượng ${isImport ? 'nhập' : 'xuất'} (${material['unit']})",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nếu là Xuất Kho thì mới hiện Dropdown chọn Máy Móc
                  if (!isImport)
                    machinesAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => const Text("Lỗi tải máy móc"),
                      data: (machines) => DropdownButtonFormField<String>(
                        value: selectedMachineId,
                        hint: const Text("Máy móc sử dụng..."),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: machines
                            .map(
                              (m) => DropdownMenuItem(
                                value: m['id'].toString(),
                                child: Text(m['name'].toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedMachineId = val),
                      ),
                    ),
                  if (!isImport) const SizedBox(height: 12),

                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: "Ghi chú",
                      border: OutlineInputBorder(),
                    ),
                  ),
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
                  backgroundColor: isImport ? Colors.blue : Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (qtyCtrl.text.isEmpty) return;

                  // Lấy user thực hiện
                  final profile = await ref.read(currentProfileProvider.future);

                  try {
                    // Ghi vào bảng Log
                    await ref
                        .read(supabaseProvider)
                        .from('material_transactions')
                        .insert({
                          'material_id': material['id'],
                          'trans_type': type,
                          'quantity': double.parse(qtyCtrl.text),
                          'trans_date': DateFormat(
                            'yyyy-MM-dd',
                          ).format(selectedDate),
                          'machine_id': selectedMachineId,
                          'notes': noteCtrl.text,
                          'recorded_by': profile?.id,
                        });

                    // Database Trigger (đã chạy ở Bước 1) sẽ TỰ ĐỘNG cộng trừ số lượng vào bảng factory_materials.

                    if (context.mounted) {
                      Navigator.pop(c);
                      ref.invalidate(materialsProvider); // Load lại bảng tính
                      ref.invalidate(transactionsProvider); // Load lại lịch sử
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lưu thành công!")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                  }
                },
                child: const Text("Xác Nhận"),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- TAB 2: LỊCH SỬ NHẬP XUẤT ---
class TransactionHistoryTab extends ConsumerWidget {
  const TransactionHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final departmentId =
        (profile?.role == 'admin' || profile?.role == 'director')
        ? null
        : profile?.departmentId;
    final transAsync = ref.watch(transactionsProvider(departmentId));

    return transAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi: $e")),
      data: (data) {
        if (data.isEmpty)
          return const Center(child: Text("Chưa có giao dịch nào."));
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final t = data[index];
            final isImport = t['trans_type'] == 'IMPORT';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isImport
                      ? Colors.blue.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    isImport ? Icons.download : Icons.upload,
                    color: isImport ? Colors.blue : Colors.red,
                  ),
                ),
                title: Text(
                  "${t['factory_materials']['name']} (${t['factory_materials']['category']})",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ngày: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(t['trans_date']))} | Ghi bởi: ${t['profiles']['full_name']}",
                    ),
                    if (!isImport && t['factory_machines'] != null)
                      Text(
                        "Máy: ${t['factory_machines']['name']}",
                        style: const TextStyle(color: Colors.brown),
                      ),
                    if (t['notes'] != null && t['notes'].toString().isNotEmpty)
                      Text("Ghi chú: ${t['notes']}"),
                  ],
                ),
                trailing: Text(
                  "${isImport ? '+' : '-'}${t['quantity']}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isImport ? Colors.blue : Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- PROVIDER PHỤ: Lấy danh sách nhân viên để cấp quyền ---
final inventoryUsersProvider = FutureProvider((ref) async {
  final res = await ref
      .read(supabaseProvider)
      .from('profiles')
      .select('id, full_name, employee_code, can_manage_inventory, role')
      .order('full_name');
  return res;
});

// --- TAB 3: CẤU HÌNH (ĐÃ HOÀN THIỆN TÍNH NĂNG) ---
class SettingsInventoryTab extends ConsumerWidget {
  const SettingsInventoryTab({super.key});

  // 1. DIALOG THÊM VẬT TƯ
  void _showAddMaterialDialog(BuildContext context, WidgetRef ref) {
    final categoryCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final initialQtyCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(
          "Tạo Mới Vật Tư",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(
                  labelText: "Loại Vật Tư (VD: Dây đai, Nhựa...)",
                ),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên Vật Tư (VD: 270L)",
                ),
              ),
              TextField(
                controller: unitCtrl,
                decoration: const InputDecoration(
                  labelText: "Đơn vị tính (VD: Dây, Cái, Kg)",
                ),
              ),
              TextField(
                controller: initialQtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số lượng ban đầu (Tồn kho hiện tại)",
                ),
              ),
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
              backgroundColor: Colors.brown.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || unitCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Vui lòng nhập tên và đơn vị tính"),
                  ),
                );
                return;
              }
              try {
                final initialQty = double.tryParse(initialQtyCtrl.text) ?? 0;

                // Ghi vào database Supabase
                await ref
                    .read(supabaseProvider)
                    .from('factory_materials')
                    .insert({
                      'category': categoryCtrl.text.trim(),
                      'name': nameCtrl.text.trim(),
                      'unit': unitCtrl.text.trim(),
                      'initial_qty': initialQty,
                      'current_qty':
                          initialQty, // Ban đầu: Số lượng còn lại = Đầu kỳ
                    });

                if (context.mounted) {
                  Navigator.pop(c);
                  ref.invalidate(
                    materialsProvider,
                  ); // Tải lại bảng tính ở Tab 1
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Đã thêm vật tư thành công!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌ Lỗi: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("LƯU VẬT TƯ"),
          ),
        ],
      ),
    );
  }

  // 2. DIALOG THÊM MÁY MÓC
  void _showAddMachineDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(
          "Thêm Máy Móc",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Tên / Mã Máy (VD: Máy Đùn 01)",
              ),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Mô tả / Vị trí"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              try {
                await ref
                    .read(supabaseProvider)
                    .from('factory_machines')
                    .insert({
                      'name': nameCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                    });

                if (context.mounted) {
                  Navigator.pop(c);
                  ref.invalidate(machinesProvider); // Tải lại danh sách máy móc
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Đã thêm máy thành công!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌ Lỗi: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("LƯU MÁY MÓC"),
          ),
        ],
      ),
    );
  }

  // 3. DIALOG CẤP QUYỀN THỦ KHO
  void _showManageInventoryAccessDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(
          "Phân Quyền Thủ Kho",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          height: 400,
          // Dùng Consumer để tự động load danh sách nhân viên realtime
          child: Consumer(
            builder: (context, ref, child) {
              final usersAsync = ref.watch(inventoryUsersProvider);

              return usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Lỗi tải danh sách: $e")),
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final u = users[index];
                      // Admin mặc định có quyền, không cho tắt
                      final isAdmin = u['role'] == 'admin';

                      return SwitchListTile(
                        title: Text(
                          "${u['full_name']} (${u['employee_code']})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Chức vụ: ${u['role']}"),
                        value: isAdmin
                            ? true
                            : (u['can_manage_inventory'] == true),
                        activeColor: Colors.blue,
                        onChanged: isAdmin
                            ? null
                            : (val) async {
                                try {
                                  // Cập nhật cờ can_manage_inventory trực tiếp vào Supabase
                                  await ref
                                      .read(supabaseProvider)
                                      .from('profiles')
                                      .update({'can_manage_inventory': val})
                                      .eq('id', u['id']);

                                  // Load lại danh sách hiển thị
                                  ref.invalidate(inventoryUsersProvider);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Lỗi cập nhật: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    if (profile == null) return const SizedBox();

    final isGlobalAdmin = profile.role == 'admin';
    final permissions =
        ref.watch(rolePermissionsProviderUser(profile.role)).valueOrNull ?? [];

    // KIỂM TRA QUYỀN TRƯỚC KHI HIỂN THỊ
    final canManagePermissions =
        isGlobalAdmin || permissions.contains('vat_tu_cap_quyen');
    final canConfigGeneral =
        isGlobalAdmin || permissions.contains('vat_tu_cau_hinh_chung');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (canConfigGeneral) ...[
          const Text(
            "Thiết lập Dữ liệu Nền",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            leading: const Icon(Icons.category, color: Colors.brown, size: 30),
            title: const Text(
              "Tạo Mới Danh Mục Vật Tư",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Tên, Loại, Đơn vị tính, Số lượng đầu kỳ"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            // BẬT TÍNH NĂNG Ở ĐÂY
            onTap: () => _showAddMaterialDialog(context, ref),
          ),
          const SizedBox(height: 12),

          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            leading: const Icon(
              Icons.precision_manufacturing,
              color: Colors.orange,
              size: 30,
            ),
            title: const Text(
              "Danh Sách Máy Móc",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Khai báo các máy móc để chọn khi xuất kho"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            // BẬT TÍNH NĂNG Ở ĐÂY
            onTap: () => _showAddMachineDialog(context, ref),
          ),
          const SizedBox(height: 12),
        ],
        if (canManagePermissions)
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            leading: const Icon(
              Icons.manage_accounts,
              color: Colors.blue,
              size: 30,
            ),
            title: const Text(
              "Cấp Quyền Quản Lý Kho",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "Chọn nhân viên (ví dụ Thủ Kho) được quyền quản lý bảng này",
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            // BẬT TÍNH NĂNG Ở ĐÂY
            onTap: () => _showManageInventoryAccessDialog(context, ref),
          ),
      ],
    );
  }
}
