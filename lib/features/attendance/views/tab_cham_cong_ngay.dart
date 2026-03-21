import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/attendance_controller.dart';
import 'widgets/attendance_row_card.dart';

// Đổi từ StatefulWidget sang ConsumerWidget
class TabChamCongNgay extends ConsumerWidget {
  final String currentUserId; // ID Supabase của Tổ trưởng đang đăng nhập

  const TabChamCongNgay({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe ngày hiện tại
    final selectedDate = ref.watch(selectedDateProvider);

    // Lắng nghe trạng thái dữ liệu (Loading, Lỗi, hoặc Đã có Data)
    final asyncData = ref.watch(attendanceControllerProvider);

    return Column(
      children: [
        // --- HEADER: CHỌN NGÀY VÀ LÀM MỚI ---
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
                      // Cập nhật ngày qua Controller
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
                onPressed: () {
                  // Làm mới dữ liệu
                  ref.invalidate(attendanceControllerProvider);
                },
              ),
            ],
          ),
        ),

        // --- BODY: HIỂN THỊ DANH SÁCH (SỨC MẠNH CỦA ASYNCVALUE) ---
        Expanded(
          // Câu lệnh .when() xử lý toàn bộ cờ isLoading cũ của bạn cực kỳ gọn gàng
          child: asyncData.when(
            // 1. Khi đang lấy dữ liệu từ Supabase
            loading: () => const Center(child: CircularProgressIndicator()),

            // 2. Khi Supabase trả về lỗi (mất mạng, sai quyền...)
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text("Lỗi tải dữ liệu:\n$err", textAlign: TextAlign.center),
                ],
              ),
            ),

            // 3. Khi lấy dữ liệu thành công
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

        // --- FOOTER: NÚT LƯU ---
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
              // Hiển thị vòng quay nhỏ mờ trên màn hình
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // Gọi Controller để Lưu (Upsert) lên Supabase
              await ref
                  .read(attendanceControllerProvider.notifier)
                  .submitData(currentUserId);

              // Tắt vòng quay
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Đã lưu dữ liệu lên hệ thống Nhà Máy!"),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
