import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LeavePdfGenerator {
  static Future<Uint8List> generateLeavePdf(
    Map<String, dynamic> requestData,
  ) async {
    final pdf = pw.Document();

    // Tự động tải font hỗ trợ Tiếng Việt (Roboto) từ Google Fonts
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    // Xử lý dữ liệu
    final profile = requestData['profiles'];
    final startTime = DateTime.parse(requestData['start_time']).toLocal();
    final endTime = DateTime.parse(requestData['end_time']).toLocal();
    final createdAt = DateTime.parse(requestData['created_at']).toLocal();

    final startStr =
        "lúc ${DateFormat('HH').format(startTime)} giờ ${DateFormat('mm').format(startTime)} phút thứ ${startTime.weekday == 7 ? 'Chủ nhật' : (startTime.weekday + 1).toString()} ngày ${startTime.day} tháng ${startTime.month} năm ${startTime.year}";
    final endStr =
        "lúc ${DateFormat('HH').format(endTime)} giờ ${DateFormat('mm').format(endTime)} phút thứ ${endTime.weekday == 7 ? 'Chủ nhật' : (endTime.weekday + 1).toString()} ngày ${endTime.day} tháng ${endTime.month} năm ${endTime.year}";

    // Xử lý Lịch sử duyệt (Chữ ký)
    final history = requestData['approval_history'] as List<dynamic>? ?? [];
    Map<String, dynamic>? leaderSignature;
    Map<String, dynamic>? directorSignature;

    for (var h in history) {
      if (h['status'] == 'approved') {
        if (h['approver_role'] == 'team_leader' ||
            h['approver_role'] == 'section_head') {
          leaderSignature = h;
        } else if (h['approver_role'] == 'director' ||
            h['approver_role'] == 'admin') {
          directorSignature = h;
        }
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "TCT CP DỆT MAY HOÀ THỌ",
                        style: pw.TextStyle(font: fontRegular, fontSize: 12),
                      ),
                      pw.Text(
                        "NHÀ MÁY SỢI HOÀ THỌ 1",
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 12,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "CỘNG HOÀ XÃ HỘI CHỦ NGHĨA VIỆT NAM",
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                      ),
                      pw.Text(
                        "Độc lập - Tự do - Hạnh phúc",
                        style: pw.TextStyle(
                          font: fontItalic,
                          fontSize: 12,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // TIÊU ĐỀ
              pw.Center(
                child: pw.Text(
                  "GIẤY XIN NGHỈ PHÉP",
                  style: pw.TextStyle(font: fontBold, fontSize: 18),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "Kính gửi: - Ban giám đốc Nhà máy sợi 1",
                  style: pw.TextStyle(font: fontRegular, fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 30),

              // NỘI DUNG ĐƠN
              _buildRow(fontRegular, "Tôi tên là:", profile['full_name'] ?? ""),
              _buildRow(
                fontRegular,
                "Bộ phận:",
                profile['department_id'] != null
                    ? "SỢI CON - MÁY ỐNG - ĐẬU XE (Ví dụ)"
                    : "Chưa xác định",
              ), // Tương lai có thể query tên bộ phận
              _buildRow(fontRegular, "Xin nghỉ:", "Từ: $startStr"),
              _buildRow(fontRegular, "", "Đến: $endStr"),
              _buildRow(
                fontRegular,
                "Lý do nghỉ:",
                requestData['reason'] ?? "",
              ),
              _buildRow(
                fontRegular,
                "Nơi nghỉ:",
                requestData['place_of_leave'] ?? "",
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  "Kính đề nghị ban Giám đốc xem xét giải quyết.",
                  style: pw.TextStyle(font: fontRegular, fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),

              // NGÀY THÁNG LÀM ĐƠN
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Hoà Thọ, Ngày ${createdAt.day.toString().padLeft(2, '0')} tháng ${createdAt.month.toString().padLeft(2, '0')} năm ${createdAt.year}",
                  style: pw.TextStyle(font: fontRegular, fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),

              // CHỮ KÝ 3 BÊN
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSignatureBlock(
                    fontBold,
                    fontItalic,
                    fontRegular,
                    "Duyệt",
                    directorSignature,
                  ),
                  _buildSignatureBlock(
                    fontBold,
                    fontItalic,
                    fontRegular,
                    "Tổ trưởng",
                    leaderSignature,
                  ),
                  _buildSignatureBlock(
                    fontBold,
                    fontItalic,
                    fontRegular,
                    "Người viết đơn",
                    {
                      'approver_name': profile['full_name'],
                      'timestamp': requestData['created_at'],
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(pw.Font font, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureBlock(
    pw.Font fontBold,
    pw.Font fontItalic,
    pw.Font fontReg,
    String title,
    Map<String, dynamic>? signData,
  ) {
    if (signData == null) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 12)),
          pw.SizedBox(height: 60),
          pw.Text(
            "(Chưa duyệt)",
            style: pw.TextStyle(
              font: fontItalic,
              fontSize: 10,
              color: PdfColors.grey,
            ),
          ),
        ],
      );
    }

    final date = DateTime.parse(signData['timestamp']).toLocal();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 12)),
        pw.SizedBox(height: 40),
        pw.Text(
          signData['approver_name'],
          style: pw.TextStyle(font: fontItalic, fontSize: 11),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          "(Đã ký lúc $dateStr)",
          style: pw.TextStyle(font: fontItalic, fontSize: 10),
        ),
      ],
    );
  }
}
