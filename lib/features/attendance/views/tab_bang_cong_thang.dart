import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/attendance_controller.dart';
import '../models/timesheet_model.dart';
import '../../admin/controllers/department_controller.dart';

class TabBangCongThang extends ConsumerWidget {
  const TabBangCongThang({super.key});

  // --- HÀM TÍNH MÀU SẮC (Giữ nguyên logic cực xịn của bạn) ---
  Map<String, dynamic> _getCellStyle(
    String symbol,
    bool isSunday,
    bool isWorking,
  ) {
    Color bg = Colors.white;
    Color text = Colors.black87;
    FontWeight weight = FontWeight.bold;

    if (symbol == '' || symbol == '-') {
      bg = Colors.grey.shade100;
      text = Colors.grey;
      weight = FontWeight.normal;
    } else if (isWorking) {
      bg = const Color(0xFFE8F5E9); // Xanh nhạt
      text = Colors.green.shade900;
    } else {
      bg = const Color(0xFFFFEBEE); // Đỏ nhạt
      text = Colors.red.shade900;
    }

    if (isSunday && (symbol == '' || symbol == '-')) {
      bg = const Color(0xFFFFF3E0);
      text = Colors.red.shade300;
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

    // Đã đổi tên thành monthlyAttendanceProvider để dùng Future
    final timesheetsAsync = ref.watch(monthlyAttendanceProvider);

    // Lấy cấu hình động từ Riverpod
    final shiftConfigs = ref.watch(shiftConfigsProvider).valueOrNull ?? [];
    final statusConfigs =
        ref.watch(attendanceStatusConfigsProvider).valueOrNull ?? [];

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
        // ... (Giữ nguyên thanh AppBar chọn ngày của bạn) ...
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
                  if (picked != null)
                    ref.read(selectedMonthProvider.notifier).state = picked;
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
            ],
          ),
        ),

        Expanded(
          child: employeesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text("Lỗi tải nhân viên: $err")),
            data: (employees) {
              if (employees.isEmpty)
                return const Center(child: Text("Chưa có nhân viên."));

              return timesheetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text("Lỗi tải bảng công: $err"),
                ), // Lỗi Timeout đã biến mất!
                data: (timesheetMap) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cột tên nhân viên (Giữ nguyên)
                      SizedBox(
                        width: nameColumnWidth,
                        child: Column(
                          children: [
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

                      // Bảng chấm công ngang
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: daysInMonth * cellWidth,
                            child: Column(
                              children: [
                                // Dòng Header Ngày trong tháng (Giữ nguyên)
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

                                // Các dòng dữ liệu chấm công
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: employees.length,
                                    itemBuilder: (context, empIndex) {
                                      final empId = employees[empIndex].id;
                                      final empTimesheets =
                                          timesheetMap[empId] ?? {};

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
                                          final cellData = empTimesheets[day];

                                          // LOGIC TÍNH KÝ HIỆU ĐỘNG
                                          String symbol = '-';
                                          bool isWorking = false;

                                          if (cellData != null) {
                                            // Tìm trạng thái công trong cấu hình
                                            final currentStatusConfig =
                                                statusConfigs.firstWhere(
                                                  (s) =>
                                                      s['name'] ==
                                                      cellData.status,
                                                  orElse: () => {
                                                    'name': cellData.status,
                                                    'symbol': '',
                                                    'is_working_day': true,
                                                  }, // Tránh null
                                                );

                                            // Lấy giá trị boolean an toàn (Nếu null mặc định là false)
                                            // Note: Bạn có thể cập nhật bảng attendance_status_configs để set Có mặt = is_working_day là true
                                            isWorking =
                                                currentStatusConfig['is_working_day'] ==
                                                    true ||
                                                cellData.status == 'Có mặt';

                                            if (isWorking) {
                                              // Nếu là ngày đi làm (VD: Có mặt), lấy ký hiệu của Ca Làm Việc
                                              final currentShiftConfig =
                                                  shiftConfigs.firstWhere(
                                                    (s) =>
                                                        s['name'] ==
                                                        cellData.shiftType,
                                                    orElse: () => {
                                                      'symbol': 'X',
                                                    },
                                                  );
                                              symbol =
                                                  (currentShiftConfig['symbol']
                                                      ?.toString() ??
                                                  'X');
                                            } else {
                                              // Nếu là ngày nghỉ (VD: Nghỉ phép, đi trễ), lấy ký hiệu của Trạng thái công
                                              symbol =
                                                  (currentStatusConfig['symbol']
                                                      ?.toString() ??
                                                  '-');
                                            }
                                          }

                                          final style = _getCellStyle(
                                            symbol,
                                            isSun,
                                            isWorking,
                                          );
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
