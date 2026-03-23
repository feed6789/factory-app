import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/feedback_controller.dart';

class FeedbackManagementTab extends ConsumerWidget {
  const FeedbackManagementTab({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xem xét';
      case 'reviewed':
        return 'Đang xử lý';
      case 'resolved':
        return 'Đã giải quyết';
      default:
        return 'Không rõ';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(feedbackListProvider);

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi tải dữ liệu: $e")),
      data: (feedbacks) {
        if (feedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "Chưa có ý kiến đóng góp nào.",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final fb = feedbacks[index];
            final profile = fb['profiles'];
            final dateStr = DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format(DateTime.parse(fb['created_at']).toLocal());
            final isAnonymous = fb['is_anonymous'] == true;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isAnonymous
                                    ? Colors.grey.shade300
                                    : Colors.blue.shade100,
                                // SỬA LỖI ICON Ở ĐÂY (Dùng Icons.person_off thay cho mask_outlined)
                                child: Icon(
                                  isAnonymous ? Icons.person_off : Icons.person,
                                  color: isAnonymous
                                      ? Colors.grey.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile['full_name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontStyle: isAnonymous
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              fb['status'],
                            ).withOpacity(0.1),
                            border: Border.all(
                              color: _getStatusColor(fb['status']),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: fb['status'],
                              icon: const Icon(Icons.arrow_drop_down, size: 16),
                              style: TextStyle(
                                color: _getStatusColor(fb['status']),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              items: ['pending', 'reviewed', 'resolved'].map((
                                s,
                              ) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(_getStatusText(s)),
                                );
                              }).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  ref
                                      .read(feedbackActionProvider)
                                      .updateFeedbackStatus(
                                        fb['id'],
                                        newStatus,
                                      );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fb['feedback_type'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fb['content'],
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
