// File: lib/features/attendance/views/leave_approval_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_nm/features/attendance/controllers/leave_controller.dart';
import 'package:printing/printing.dart';
import 'leave_pdf_generator.dart';

// Danh sách các loại đơn để lọc
const List<String> LEAVE_TYPES = [
  'Tất cả',
  'Nghỉ phép',
  'Nghỉ ốm',
  'Xếp loại nhân viên',
  'Đi trễ / Về sớm',
];

class LeaveApprovalPage extends ConsumerStatefulWidget {
  const LeaveApprovalPage({super.key});

  @override
  ConsumerState<LeaveApprovalPage> createState() => _LeaveApprovalPageState();
}

class _LeaveApprovalPageState extends ConsumerState<LeaveApprovalPage> {
  String selectedFilter = 'Tất cả'; // Biến lưu trạng thái bộ lọc

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Quản Lý Đơn Từ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orangeAccent,
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: "Chờ Duyệt"),
              Tab(icon: Icon(Icons.history), text: "Lịch Sử Đã Duyệt"),
            ],
          ),
          actions: [
            // BỘ LỌC ĐẶT TRÊN APPBAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.filter_list, color: Colors.blue),
                    items: LEAVE_TYPES
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedFilter = val!),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildTabContent(
              ref.watch(pendingLeaveRequestsProvider),
              isHistory: false,
            ),
            _buildTabContent(
              ref.watch(processedLeaveRequestsProvider),
              isHistory: true,
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng UI chung cho cả 2 Tab, có tích hợp bộ lọc
  Widget _buildTabContent(
    AsyncValue<List<Map<String, dynamic>>> asyncData, {
    required bool isHistory,
  }) {
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text("Lỗi: $err")),
      data: (allRequests) {
        // LOGIC BỘ LỌC
        final requests = selectedFilter == 'Tất cả'
            ? allRequests
            : allRequests
                  .where((req) => req['leave_type'] == selectedFilter)
                  .toList();

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "Không có đơn từ nào (${selectedFilter}).",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final profile = req['profiles'];
            final startTime = DateTime.parse(req['start_time']);
            final endTime = DateTime.parse(req['end_time']);

            final startDateStr = DateFormat('dd/MM/yyyy').format(startTime);
            final endDateStr = DateFormat('dd/MM/yyyy').format(endTime);
            final startTimeStr = DateFormat('HH:mm').format(startTime);
            final endTimeStr = DateFormat('HH:mm').format(endTime);

            String timeDisplay = startDateStr == endDateStr
                ? "Ngày $startDateStr ($startTimeStr - $endTimeStr)"
                : "Từ $startTimeStr $startDateStr đến $endTimeStr $endDateStr";

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${profile['full_name']} (Mã: ${profile['employee_code']})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // NẾU LÀ LỊCH SỬ -> HIỂN THỊ CHIP TRẠNG THÁI
                        if (isHistory)
                          Chip(
                            label: Text(
                              req['status'] == 'approved'
                                  ? 'Đã duyệt'
                                  : 'Từ chối',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: req['status'] == 'approved'
                                ? Colors.green
                                : Colors.red,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.access_time,
                      "Thời gian: ",
                      timeDisplay,
                      Colors.blue.shade700,
                    ),
                    _buildInfoRow(
                      Icons.category,
                      "Loại đơn: ",
                      req['leave_type'],
                      Colors.black87,
                    ),
                    if (req['place_of_leave'] != null &&
                        req['place_of_leave'].toString().isNotEmpty)
                      _buildInfoRow(
                        Icons.place,
                        "Nơi nghỉ: ",
                        req['place_of_leave'],
                        Colors.black87,
                      ),
                    _buildInfoRow(
                      Icons.message,
                      "Lý do: ",
                      req['reason'],
                      Colors.black87,
                    ),

                    if (isHistory && req['status'] == 'approved') ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Tải / In PDF",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () async {
                              // Gọi hàm tạo PDF
                              final pdfBytes =
                                  await LeavePdfGenerator.generateLeavePdf(req);

                              // Mở màn hình Preview PDF (Cho phép tải xuống, in qua máy in Wifi/Bluetooth)
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        title: const Text("Xem trước File PDF"),
                                      ),
                                      body: PdfPreview(
                                        build: (format) => pdfBytes,
                                        allowSharing:
                                            true, // Nút Share gửi qua Zalo/Email
                                        allowPrinting:
                                            true, // Nút Print in trực tiếp
                                        pdfFileName:
                                            "Giay_Nghi_Phep_${req['profiles']['full_name']}.pdf",
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],

                    // NẾU LÀ CHỜ DUYỆT -> HIỂN THỊ NÚT BẤM
                    if (!isHistory) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text(
                              "Từ chối",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () => ref
                                .read(leaveActionProvider)
                                .updateRequestStatus(req['id'], 'rejected'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Duyệt Đơn"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => ref
                                .read(leaveActionProvider)
                                .updateRequestStatus(req['id'], 'approved'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
