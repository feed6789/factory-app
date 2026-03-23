import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../controllers/feedback_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class FeedbackSubmissionPage extends ConsumerStatefulWidget {
  // 1. KHAI BÁO isStandalone Ở ĐÂY
  final bool isStandalone;

  const FeedbackSubmissionPage({super.key, this.isStandalone = true});

  @override
  ConsumerState<FeedbackSubmissionPage> createState() =>
      _FeedbackSubmissionPageState();
}

class _FeedbackSubmissionPageState
    extends ConsumerState<FeedbackSubmissionPage> {
  final _contentCtrl = TextEditingController();
  String _selectedType = 'Sáng kiến cải tiến';

  // 2. KHAI BÁO _isAnonymous Ở ĐÂY
  bool _isAnonymous = false;

  final List<String> _types = [
    'Sáng kiến cải tiến',
    'Báo cáo Lỗi / Hỏng hóc',
    'Khó khăn trong công việc',
    'Khác',
  ];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
            }
          },
          onError: (val) {
            setState(() => _isListening = false);
          },
        );

        if (available) {
          setState(() {
            _isListening = true;
            _previousText = _contentCtrl.text;
            if (_previousText.isNotEmpty && !_previousText.endsWith(' ')) {
              _previousText += ' ';
            }
          });
          _speech.listen(
            onResult: (val) => setState(() {
              _contentCtrl.text = _previousText + val.recognizedWords;
            }),
            localeId: 'vi_VN',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không hỗ trợ nhận diện giọng nói hoặc chưa cấp quyền.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        setState(() => _isListening = false);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loại ý kiến:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedType,
                items: _types
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Giao diện Checkbox Ẩn Danh
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: CheckboxListTile(
              title: const Text(
                "Gửi ẩn danh",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              subtitle: const Text(
                "Quản lý sẽ không thấy tên và mã nhân viên của bạn.",
                style: TextStyle(fontSize: 12),
              ),
              value: _isAnonymous, // Sử dụng biến ở đây
              activeColor: Colors.deepOrange,
              onChanged: (val) => setState(() => _isAnonymous = val ?? false),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Nội dung chi tiết:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              TextField(
                controller: _contentCtrl,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText:
                      "Mô tả chi tiết ý kiến của bạn...\n(Có thể bấm biểu tượng Micro để nói)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: FloatingActionButton.small(
                  heroTag: 'mic_btn',
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  onPressed: _listen,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text(
                "GỬI Ý KIẾN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_contentCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập nội dung.')),
                  );
                  return;
                }

                final profile = await ref.read(currentProfileProvider.future);
                if (profile == null) return;

                final success = await ref
                    .read(feedbackActionProvider)
                    .submitFeedback(
                      userId: profile.id,
                      type: _selectedType,
                      content: _contentCtrl.text.trim(),
                      isAnonymous: _isAnonymous,
                    );

                if (context.mounted) {
                  if (success) {
                    _contentCtrl.clear();
                    setState(() => _isAnonymous = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cảm ơn bạn đã đóng góp ý kiến!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // 3. GỌI widget.isStandalone CHUẨN XÁC Ở ĐÂY
                    if (widget.isStandalone) {
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gửi thất bại, vui lòng thử lại.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );

    // 4. KIỂM TRA ĐIỀU KIỆN RENDER CÓ APPBAR HAY KHÔNG
    if (!widget.isStandalone) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đóng Góp Ý Kiến",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: body,
    );
  }
}
