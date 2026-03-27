import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/production_report_controller.dart';

class DataEntryPage extends StatelessWidget {
  const DataEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text(
            "Nhập Số Liệu & Cấu Hình",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orangeAccent,
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: "Nhập Liệu Hàng Ngày"),
              Tab(icon: Icon(Icons.settings), text: "Cấu Hình Tủ Điện"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DataEntryTab(), _CabinetManagementTab()],
        ),
      ),
    );
  }
}

class _DataEntryTab extends ConsumerStatefulWidget {
  const _DataEntryTab();
  @override
  ConsumerState<_DataEntryTab> createState() => _DataEntryTabState();
}

class _DataEntryTabState extends ConsumerState<_DataEntryTab> {
  String? _selectedCabinetId;
  final _readingCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cabinetsAsync = ref.watch(electricalCabinetsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.orange, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Nhập số điện tiêu thụ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                "Tên thiết bị / Tủ điện:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              cabinetsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text(
                  "Lỗi tải danh sách tủ: $e",
                  style: const TextStyle(color: Colors.red),
                ),
                data: (cabinets) => DropdownButtonFormField<String>(
                  value: _selectedCabinetId,
                  hint: const Text("-- Chọn thiết bị --"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: cabinets
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCabinetId = val),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Chỉ số tiêu thụ (kWh):",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _readingCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: "Nhập số điện (VD: 150.5)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  suffixText: "kWh",
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "LƯU SỐ LIỆU",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_selectedCabinetId != null &&
                        _readingCtrl.text.isNotEmpty) {
                      final value = double.tryParse(_readingCtrl.text) ?? 0.0;
                      final success = await ref
                          .read(productionReportActionProvider)
                          .upsertElectricityReading(
                            _selectedCabinetId!,
                            value,
                            DateTime.now(),
                          );
                      if (mounted) {
                        if (success) {
                          _readingCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ Đã lưu thành công!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ Lỗi khi lưu dữ liệu!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabinetManagementTab extends ConsumerWidget {
  const _CabinetManagementTab();

  void _showAddCabinetDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Thêm Tủ Điện/Máy móc"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Tên thiết bị (*)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(
                labelText: "Khu vực / Phân xưởng",
                border: OutlineInputBorder(),
              ),
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
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await ref
                    .read(productionReportActionProvider)
                    .addCabinet(nameCtrl.text, locationCtrl.text);
                if (context.mounted) Navigator.pop(c);
              }
            },
            child: const Text("LƯU"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinetsAsync = ref.watch(electricalCabinetsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: cabinetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi: $e")),
        data: (cabinets) {
          if (cabinets.isEmpty)
            return const Center(child: Text("Chưa có thiết bị nào."));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cabinets.length,
            itemBuilder: (context, index) {
              final cabinet = cabinets[index];
              return Card(
                color: Colors.white,
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.electrical_services,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    cabinet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    cabinet.location ?? "Chưa có vị trí",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        onPressed: () => _showAddCabinetDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Thêm Thiết Bị"),
      ),
    );
  }
}
