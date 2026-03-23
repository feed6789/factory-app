import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/attendance_controller.dart';
import 'widgets/attendance_row_card.dart';
import '../../../core/services/sync_service.dart'; // IMPORT THÊM FILE NÀY

class TabChamCongNgay extends ConsumerWidget {
  final String currentUserId;

  const TabChamCongNgay({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final asyncData = ref.watch(attendanceControllerProvider);

    // Lắng nghe số lượng bản ghi đang kẹt
    final pendingCount = ref.watch(pendingSyncCountProvider);

    return Column(
      children: [
        // --- CẢNH BÁO ĐỒNG BỘ OFFLINE ---
        if (pendingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.shade100,
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Đang có $pendingCount bản ghi chờ đồng bộ lên server.",
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 13,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text("Đồng bộ ngay"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đang thử đồng bộ...")),
                    );
                    final success = await ref
                        .read(syncServiceProvider)
                        .syncPendingData();
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Đã đồng bộ dữ liệu thành công!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "❌ Chưa có kết nối mạng. Vui lòng thử lại sau.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

        // ... (Phần UI chọn ngày giữ nguyên) ...
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      ref
                          .read(attendanceControllerProvider.notifier)
                          .changeDate(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.blue.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
                icon: const Icon(Icons.refresh, color: Colors.black87),
                onPressed: () => ref.invalidate(attendanceControllerProvider),
              ),
            ],
          ),
        ),

        // ... (Phần danh sách nhân viên giữ nguyên) ...
        Expanded(
          child: asyncData.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text("Lỗi tải dữ liệu:\n$err")),
            data: (danhSachNV) {
              if (danhSachNV.isEmpty) {
                return const Center(
                  child: Text("Không có nhân viên nào trong bộ phận này."),
                );
              }
              return ListView.builder(
                itemCount: danhSachNV.length,
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemBuilder: (context, index) {
                  return AttendanceRowCard(rowData: danhSachNV[index]);
                },
              );
            },
          ),
        ),

        // --- NÚT LƯU BẢNG CÔNG (ĐÃ CHỈNH SỬA LOGIC) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            label: const Text(
              "LƯU BẢNG CÔNG",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // Thay vì void, ta nhận về trạng thái
              final result = await ref
                  .read(attendanceControllerProvider.notifier)
                  .submitData(currentUserId);

              if (context.mounted) {
                Navigator.pop(context); // Đóng loading dialog

                if (result == "online_success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Đã lưu dữ liệu lên hệ thống Nhà Máy!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (result == "offline_saved") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "⚠️ Mất mạng! Đã lưu cục bộ vào máy. Hãy bấm Đồng bộ khi có mạng.",
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 4),
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
            },
          ),
        ),
      ],
    );
  }
}
