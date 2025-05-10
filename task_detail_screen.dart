import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;
  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  // Widget hỗ trợ hiển thị một dòng thông tin chi tiết theo định dạng: Label: Value
  Widget _buildDetailItem({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: labelStyle ??
                  const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Định nghĩa một số style cho label và nội dung
    final labelStyle = const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent);
    final contentStyle = const TextStyle(fontSize: 16, color: Colors.black87);

    return Scaffold(
      extendBodyBehindAppBar: true, // Mở rộng body nằm sau AppBar
      appBar: AppBar(
        backgroundColor: Colors
            .transparent, // AppBar trong suốt để gradient nền hiển thị đầy đủ
        elevation: 0,
        title: const Text("Chi tiết Công việc"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Điều hướng sang màn hình chỉnh sửa công việc
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
              );
            },
          ),
        ],
      ),
      // Container full màn hình với gradient làm nền
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Sử dụng SingleChildScrollView để đảm bảo nội dung cuộn nếu quá nhiều
        child: SingleChildScrollView(
          // thêm padding trên đủ chỗ cho AppBar
          padding: const EdgeInsets.only(
              top: kToolbarHeight + 80, left: 16, right: 16, bottom: 16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề chính của công việc
                  Center(
                    child: Text(
                      task.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                      label: "Mô tả:",
                      value: task.description,
                      labelStyle: labelStyle,
                      valueStyle: contentStyle),
                  _buildDetailItem(
                      label: "Trạng thái:",
                      value: task.status,
                      labelStyle: labelStyle,
                      valueStyle: contentStyle),
                  _buildDetailItem(
                      label: "Độ ưu tiên:",
                      value: task.priority.toString(),
                      labelStyle: labelStyle,
                      valueStyle: contentStyle),
                  if (task.dueDate != null)
                    _buildDetailItem(
                      label: "Hạn hoàn thành:",
                      value: task.dueDate!.toString().split(" ")[0],
                      labelStyle: labelStyle,
                      valueStyle: contentStyle,
                    ),
                  _buildDetailItem(
                      label: "Người tạo:",
                      value: task.createdBy,
                      labelStyle: labelStyle,
                      valueStyle: contentStyle),
                  if (task.attachments != null && task.attachments!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tệp đính kèm:", style: labelStyle),
                          const SizedBox(height: 4),
                          ...task.attachments!.map((link) => Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(link, style: contentStyle),
                          )),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
