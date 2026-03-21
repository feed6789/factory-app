import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/attendance_controller.dart';
import '../models/timesheet_model.dart';

class TabBangCongThang extends ConsumerWidget {
  const TabBangCongThang({super.key});

  // --- HÀM TÍNH MÀU SẮC (Giữ nguyên logic cực xịn của bạn) ---
  Map<String, dynamic> _getCellStyle(String symbol, bool isSunday) {
    Color bg = Colors.white;
    Color text = Colors.black87;
    FontWeight weight = FontWeight.normal;

    switch (symbol) {
      case 'X':
        bg = const Color(0xFFC8E6C9);
        text = Colors.green.shade900;
        weight = FontWeight.bold;
        break;
      case 'S':
        bg = const Color(0xFFBBDEFB);
        text = Colors.blue.shade900;
        weight = FontWeight.bold;
        break;
      case 'C':
        bg = const Color(0xFFFFF9C4);
        text = Colors.orange.shade900;
        weight = FontWeight.bold;
        break;
      case 'Đ':
        bg = const Color(0xFFE1BEE7);
        text = Colors.purple.shade900;
        weight = FontWeight.bold;
        break;
      case 'P':
        bg = Colors.grey.shade300;
        text = Colors.blue.shade800;
        weight = FontWeight.bold;
        break;
      case 'OM':
        bg = const Color(0xFFFFCDD2);
        text = Colors.red.shade900;
        weight = FontWeight.bold;
        break;
      case 'KP':
        bg = Colors.red.shade400;
        text = Colors.white;
        weight = FontWeight.bold;
        break;
      case '-':
        bg = Colors.grey.shade100;
        text = Colors.grey;
        break;
      default:
        if (isSunday) {
          bg = const Color(0xFFFFF3E0);
          text = Colors.red.shade300;
        }
    }
    return {'bg': bg, 'text': text, 'weight': weight};
  }

  // --- HÀM RÚT GỌN KÝ HIỆU ---
  String _getSymbol(TimesheetModel? cellData) {
    if (cellData == null) return '';
    String tt = cellData.status;
    String ca = cellData.shiftType;

    if (tt == 'Có mặt') {
      if (ca == 'Ca Ngày') return 'X';
      if (ca == 'Sáng') return 'S';
      if (ca == 'Chiều') return 'C';
      if (ca == 'Đêm') return 'Đ';
      if (ca == 'Nửa Ngày') return '/';
      return 'X'; // Mặc định
    } else {
      if (tt == 'Nghỉ phép') return 'P';
      if (tt == 'Nghỉ ốm') return 'OM';
      if (tt == 'Nghỉ không phép') return 'KP';
      return '-'; // Ngày nghỉ
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(selectedMonthProvider);
    final employeesAsync = ref.watch(departmentEmployeesProvider);
    final timesheetsAsync = ref.watch(monthlyAttendanceStreamProvider);

    int daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    const double cellWidth = 45.0;
    const double cellHeight = 40.0;
    const double nameColumnWidth = 150.0;

    return Column(
      children: [
        // --- HEADER: CHỌN THÁNG ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: currentMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    ref.read(selectedMonthProvider.notifier).state = picked;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: Colors.purple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tháng ${DateFormat('MM/yyyy').format(currentMonth)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Nút xuất Excel (Sau này bạn có thể gắp logic export cũ vào đây)
              IconButton(
                icon: const Icon(Icons.file_download, color: Colors.green),
                tooltip: "Xuất file Excel",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Chức năng xuất Excel sẽ tích hợp sau."),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // --- BODY: BẢNG DATA THỜI GIAN THỰC ---
        Expanded(
          // Dùng Consumer lồng nhau để bắt trạng thái của cả 2 AsyncValue
          child: employeesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text("Lỗi tải nhân viên: $err")),
            data: (employees) {
              if (employees.isEmpty)
                return const Center(child: Text("Chưa có nhân viên."));

              return timesheetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text("Lỗi tải bảng công: $err")),
                data: (timesheetMap) {
                  // --- VẼ BẢNG CÔNG NGHIỆP ---
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CỘT 1: CỐ ĐỊNH TÊN NHÂN VIÊN
                      SizedBox(
                        width: nameColumnWidth,
                        child: Column(
                          children: [
                            // Header góc trái trên
                            Container(
                              height: cellHeight,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                  right: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child: const Text(
                                "NHÂN VIÊN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // Danh sách tên (Cuộn dọc)
                            Expanded(
                              child: ListView.builder(
                                itemCount: employees.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: cellHeight,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                        right: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      employees[index].fullName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CỘT 2: CÁC NGÀY TRONG THÁNG (CUỘN NGANG + DỌC)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: daysInMonth * cellWidth,
                            child: Column(
                              children: [
                                // Header Ngày (1 -> 30/31)
                                Row(
                                  children: List.generate(daysInMonth, (index) {
                                    int day = index + 1;
                                    bool isSun =
                                        DateTime(
                                          currentMonth.year,
                                          currentMonth.month,
                                          day,
                                        ).weekday ==
                                        7;
                                    return Container(
                                      width: cellWidth,
                                      height: cellHeight,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSun
                                            ? Colors.orange.shade50
                                            : Colors.grey.shade100,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "$day",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isSun
                                              ? Colors.red
                                              : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                // Lưới Dữ Liệu Chấm Công
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: employees.length,
                                    itemBuilder: (context, empIndex) {
                                      final empId = employees[empIndex].id;
                                      final empTimesheets =
                                          timesheetMap[empId] ??
                                          {}; // Lấy map các ngày của NV này

                                      return Row(
                                        children: List.generate(daysInMonth, (
                                          dayIndex,
                                        ) {
                                          int day = dayIndex + 1;
                                          bool isSun =
                                              DateTime(
                                                currentMonth.year,
                                                currentMonth.month,
                                                day,
                                              ).weekday ==
                                              7;

                                          // Tìm dữ liệu chấm công của ngày này
                                          final cellData = empTimesheets[day];
                                          final symbol = _getSymbol(cellData);
                                          final style = _getCellStyle(
                                            symbol,
                                            isSun,
                                          );

                                          // Đánh dấu ô có Tăng ca (Viền gạch chân cam mỏng chẳng hạn)
                                          bool hasOvertime =
                                              cellData?.overtimeStart != null &&
                                              cellData!
                                                  .overtimeStart!
                                                  .isNotEmpty;

                                          return Container(
                                            width: cellWidth,
                                            height: cellHeight,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: style['bg'],
                                              border: Border(
                                                right: BorderSide(
                                                  color: Colors.grey.shade200,
                                                  width: 0.5,
                                                ),
                                                bottom: BorderSide(
                                                  color: hasOvertime
                                                      ? Colors.orange.shade400
                                                      : Colors.grey.shade200,
                                                  width: hasOvertime
                                                      ? 2.0
                                                      : 0.5,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              symbol,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: style['weight'],
                                                color: style['text'],
                                              ),
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
