import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/material_request_controller.dart';
// Import provider lấy phân quyền (đã có ở màn hình chính)
import '../../home/views/main_navigation_page.dart';

class MaterialRequestPage extends ConsumerWidget {
  const MaterialRequestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Lỗi: $e"))),
      data: (profile) {
        if (profile == null) return const SizedBox();

        // Nếu là admin thì auto full quyền, nếu không thì lấy danh sách quyền từ DB
        final isGlobalAdmin = profile.role == 'admin';
        final permissionsAsync = ref.watch(
          rolePermissionsProviderUser(profile.role),
        );

        return permissionsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) => Scaffold(body: Center(child: Text("Lỗi quyền: $e"))),
          data: (allowedFeatures) {
            // CHIA QUYỀN HIỂN THỊ TABS
            final canCreate =
                isGlobalAdmin || allowedFeatures.contains('de_xuat_tao');
            final canApprove =
                isGlobalAdmin || allowedFeatures.contains('de_xuat_duyet');
            final canManageCatalog =
                isGlobalAdmin || allowedFeatures.contains('de_xuat_danh_muc');

            List<Tab> tabs = [];
            List<Widget> tabViews = [];

            if (canCreate) {
              tabs.addAll(const [
                Tab(icon: Icon(Icons.add_shopping_cart), text: "Tạo Đề Xuất"),
                Tab(icon: Icon(Icons.history), text: "Phiếu Của Tôi"),
              ]);
              tabViews.addAll([
                CreateRequestTab(userProfile: profile),
                MyRequestsTab(userId: profile.id),
              ]);
            }
            if (canApprove) {
              tabs.add(
                const Tab(icon: Icon(Icons.fact_check), text: "Duyệt Phiếu"),
              );
              tabViews.add(const ApproveRequestsTab());
            }
            if (canManageCatalog) {
              tabs.add(
                const Tab(icon: Icon(Icons.category), text: "Danh Mục VTPT"),
              );
              tabViews.add(const CatalogSettingsTab());
            }

            if (tabs.isEmpty)
              return const Scaffold(
                body: Center(
                  child: Text("Bạn không có quyền dùng tính năng này."),
                ),
              );

            return DefaultTabController(
              length: tabs.length,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "Đề Xuất Vật Tư",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.teal.shade700,
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

// ==========================================
// TAB 1: NHÂN VIÊN TẠO ĐỀ XUẤT (Giữ nguyên logic cũ)
// ==========================================
class CreateRequestTab extends ConsumerStatefulWidget {
  final dynamic userProfile;
  const CreateRequestTab({super.key, required this.userProfile});

  @override
  ConsumerState<CreateRequestTab> createState() => _CreateRequestTabState();
}

class _CreateRequestTabState extends ConsumerState<CreateRequestTab> {
  List<Map<String, dynamic>> selectedItems = [];

  void _showAddItemDialog() {
    String? selectedCatalogId;
    final qtyCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          final catalogsAsync = ref.watch(materialCatalogsProvider);
          return AlertDialog(
            title: const Text("Thêm VTPT vào phiếu"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  catalogsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => const Text("Lỗi tải danh mục"),
                    data: (catalogs) => DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedCatalogId,
                      hint: const Text("Chọn vật tư..."),
                      items: catalogs
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat['id'].toString(),
                              child: Text(
                                "${(cat as Map<String, dynamic>)['name']} (${cat['origin']} - ${cat['unit']})",
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedCatalogId = val),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Số lượng đề nghị",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: purposeCtrl,
                    decoration: const InputDecoration(
                      labelText: "Mục đích sử dụng",
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
                onPressed: () {
                  if (selectedCatalogId == null || qtyCtrl.text.isEmpty) return;
                  final catalogs =
                      ref.read(materialCatalogsProvider).valueOrNull ?? [];
                  final selectedCat =
                      catalogs.firstWhere(
                            (cat) => (cat as Map)['id'] == selectedCatalogId,
                          )
                          as Map;

                  this.setState(() {
                    selectedItems.add({
                      'catalog_id': selectedCat['id'],
                      'name': selectedCat['name'],
                      'origin': selectedCat['origin'],
                      'unit': selectedCat['unit'],
                      'request_qty': double.parse(qtyCtrl.text),
                      'purpose': purposeCtrl.text,
                      'approved_qty': 0,
                    });
                  });
                  Navigator.pop(c);
                },
                child: const Text("Thêm"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                "Người đề xuất: ${widget.userProfile.fullName}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedItems.isEmpty
              ? const Center(
                  child: Text("Chưa có VTPT nào. Hãy bấm 'Thêm Vật Tư'."),
                )
              : ListView.builder(
                  itemCount: selectedItems.length,
                  itemBuilder: (c, i) {
                    final item = selectedItems[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text("${item['name']} -[${item['origin']}]"),
                        subtitle: Text(
                          "SL: ${item['request_qty']} ${item['unit']} | Mục đích: ${item['purpose']}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              setState(() => selectedItems.removeAt(i)),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Thêm Vật Tư"),
                  onPressed: _showAddItemDialog,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text("GỬI PHIẾU"),
                  onPressed: selectedItems.isEmpty
                      ? null
                      : () async {
                          final success = await ref
                              .read(materialRequestActionProvider)
                              .submitRequest(
                                widget.userProfile.id,
                                widget.userProfile.departmentId ?? '',
                                selectedItems,
                              );
                          if (success && context.mounted) {
                            setState(() => selectedItems.clear());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Đã gửi phiếu đề xuất!"),
                              ),
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TAB 2: QUẢN LÝ DUYỆT PHIẾU (Giữ nguyên)
// ==========================================
class ApproveRequestsTab extends ConsumerWidget {
  const ApproveRequestsTab({super.key});

  void _showApproveDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> request,
  ) {
    final noteCtrl = TextEditingController();
    final numberCtrl = TextEditingController(text: request['request_number']);
    List<dynamic> items = List.from(request['items']);

    List<TextEditingController> qtyCtrls = items.map((item) {
      return TextEditingController(text: item['request_qty'].toString());
    }).toList();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Duyệt Phiếu: ${request['profiles']['full_name']}"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: numberCtrl,
                  decoration: const InputDecoration(
                    labelText: "Đề xuất số (Mã chính thức)",
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Chi tiết vật tư:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const Divider(),
                ...List.generate(items.length, (index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${item['name']}\n(Xin: ${item['request_qty']} ${item['unit']})",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: qtyCtrls[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "SL Duyệt",
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: "Ghi chú của quản lý",
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ref
                .read(materialRequestActionProvider)
                .processRequest(
                  request['id'],
                  'rejected',
                  numberCtrl.text,
                  noteCtrl.text,
                  items,
                )
                .then((_) => Navigator.pop(c)),
            child: const Text("TỪ CHỐI", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              for (int i = 0; i < items.length; i++) {
                items[i]['approved_qty'] =
                    double.tryParse(qtyCtrls[i].text) ?? 0;
              }
              ref
                  .read(materialRequestActionProvider)
                  .processRequest(
                    request['id'],
                    'approved',
                    numberCtrl.text,
                    noteCtrl.text,
                    items,
                  )
                  .then((_) => Navigator.pop(c));
            },
            child: const Text("DUYỆT PHIẾU"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(pendingMaterialRequestsProvider);
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text("Lỗi: $e"),
      data: (requests) {
        if (requests.isEmpty)
          return const Center(child: Text("Không có phiếu nào cần duyệt."));
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (c, i) {
            final req = requests[i] as Map<String, dynamic>;
            final date = DateFormat(
              'dd/MM/yyyy',
            ).format(DateTime.parse(req['created_at']));
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.pending, color: Colors.white),
                ),
                title: Text(
                  "Người xin: ${req['profiles']['full_name']} - Bộ phận: ${req['departments']?['name'] ?? ''}",
                ),
                subtitle: Text(
                  "Ngày: $date | Số món: ${(req['items'] as List).length}",
                ),
                trailing: ElevatedButton(
                  onPressed: () => _showApproveDialog(context, ref, req),
                  child: const Text("Duyệt"),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// TAB 3: DANH SÁCH PHIẾU CỦA TÔI (Giữ nguyên)
// ==========================================
class MyRequestsTab extends ConsumerWidget {
  final String userId;
  const MyRequestsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(myMaterialRequestsProvider(userId));
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text("Lỗi: $e"),
      data: (requests) {
        if (requests.isEmpty)
          return const Center(child: Text("Bạn chưa tạo phiếu nào."));
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (c, i) {
            final req = requests[i] as Map<String, dynamic>;
            final isApprove = req['status'] == 'approved';
            final isPending = req['status'] == 'pending_leader';

            return ExpansionTile(
              leading: Icon(
                isApprove
                    ? Icons.check_circle
                    : (isPending ? Icons.schedule : Icons.cancel),
                color: isApprove
                    ? Colors.green
                    : (isPending ? Colors.orange : Colors.red),
              ),
              title: Text("Phiếu: ${req['request_number']}"),
              subtitle: Text(
                "Trạng thái: ${isApprove ? 'Đã duyệt' : (isPending ? 'Đang chờ' : 'Từ chối')}",
              ),
              children: [
                Container(
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (req['manager_notes'] != null)
                        Text(
                          "Ghi chú QL: ${req['manager_notes']}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      const Divider(),
                      ...(req['items'] as List)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("• ${item['name']}"),
                                  Text(
                                    "Xin: ${item['request_qty']} -> Duyệt: ${item['approved_qty']} ${item['unit']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ==========================================
// TAB 4: THÊM DANH MỤC (CÓ NÚT SỬA/XÓA)
// ==========================================
class CatalogSettingsTab extends ConsumerWidget {
  const CatalogSettingsTab({super.key});

  void _showAddOrEditDialog(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? item,
  }) {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: isEditing ? item['name'] : '');
    final originCtrl = TextEditingController(
      text: isEditing ? item['origin'] : '',
    );
    final unitCtrl = TextEditingController(text: isEditing ? item['unit'] : '');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEditing ? "Sửa Mã VTPT" : "Thêm Mã VTPT Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Tên & Quy cách (*)",
              ),
            ),
            TextField(
              controller: originCtrl,
              decoration: const InputDecoration(labelText: "Xuất xứ"),
            ),
            TextField(
              controller: unitCtrl,
              decoration: const InputDecoration(labelText: "Đơn vị tính (*)"),
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
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || unitCtrl.text.isEmpty) return;

              if (isEditing) {
                await ref
                    .read(materialRequestActionProvider)
                    .updateCatalog(
                      item['id'],
                      nameCtrl.text,
                      originCtrl.text,
                      unitCtrl.text,
                    );
              } else {
                await ref
                    .read(materialRequestActionProvider)
                    .addCatalog(nameCtrl.text, originCtrl.text, unitCtrl.text);
              }

              if (context.mounted) Navigator.pop(c);
            },
            child: const Text("LƯU"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(materialCatalogsProvider);
    return Scaffold(
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text("Lỗi: $e"),
        data: (catalogs) => ListView.builder(
          itemCount: catalogs.length,
          itemBuilder: (c, i) {
            final cat = catalogs[i] as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.api, color: Colors.teal),
              title: Text(
                cat['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Xuất xứ: ${cat['origin']} | ĐVT: ${cat['unit']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _showAddOrEditDialog(context, ref, item: cat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text("Xác nhận xóa"),
                          content: const Text("Xóa mã VTPT này?"),
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
                      );
                      if (confirm == true) {
                        final msg = await ref
                            .read(materialRequestActionProvider)
                            .deleteCatalog(cat['id']);
                        if (context.mounted && msg != "OK") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text("Thêm Mã VTPT"),
        onPressed: () => _showAddOrEditDialog(context, ref),
      ),
    );
  }
}
