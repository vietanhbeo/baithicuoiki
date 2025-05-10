import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../models/task_model.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task; // Nếu task khác null thì ở chế độ chỉnh sửa
  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  // Các trường dữ liệu của form
  String title = "";
  String description = "";
  String status = "To do";
  int priority = 1;
  DateTime? dueDate;
  String? assignedTo;
  String category = "";
  String attachmentsString = "";
  bool completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      title = widget.task!.title;
      description = widget.task!.description;
      status = widget.task!.status;
      priority = widget.task!.priority;
      dueDate = widget.task!.dueDate;
      assignedTo = widget.task!.assignedTo;
      category = widget.task!.category ?? "";
      attachmentsString = widget.task!.attachments?.join(",") ?? "";
      completed = widget.task!.completed;
    }
  }

  Future<void> _pickDueDate() async {
    DateTime initialDate = dueDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final now = DateTime.now();
      // Chuyển attachments từ chuỗi nhập vào thành List<String>
      List<String> attachments = attachmentsString.trim().isNotEmpty
          ? attachmentsString.split(',').map((s) => s.trim()).toList()
          : [];
      if (widget.task == null) {
        // Tạo mới công việc
        final newTask = TaskModel(
          id: Uuid().v4(),
          title: title,
          description: description,
          status: status,
          priority: priority,
          dueDate: dueDate,
          createdAt: now,
          updatedAt: now,
          assignedTo: assignedTo,
          createdBy: "currentUserId", // Thay bằng ID người dùng hiện tại
          category: category.isNotEmpty ? category : null,
          attachments: attachments.isNotEmpty ? attachments : null,
          completed: completed,
        );
        await dbHelper.insertTask(newTask);
      } else {
        // Cập nhật công việc đã có
        final updatedTask = TaskModel(
          id: widget.task!.id,
          title: title,
          description: description,
          status: status,
          priority: priority,
          dueDate: dueDate,
          createdAt: widget.task!.createdAt,
          updatedAt: now,
          assignedTo: assignedTo,
          createdBy: widget.task!.createdBy,
          category: category.isNotEmpty ? category : null,
          attachments: attachments.isNotEmpty ? attachments : null,
          completed: completed,
        );
        await dbHelper.updateTask(updatedTask);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Cho phép nội dung chạy qua phía sau AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar trong suốt
        elevation: 0,
        title: Text(widget.task == null ? "Thêm Công việc" : "Chỉnh sửa Công việc"),
      ),
      // Container full màn hình với gradient nền
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tiêu đề
                      TextFormField(
                        initialValue: title,
                        decoration: const InputDecoration(
                          labelText: "Tiêu đề",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập tiêu đề công việc";
                          }
                          return null;
                        },
                        onSaved: (value) => title = value!,
                      ),
                      const SizedBox(height: 16),
                      // Mô tả
                      TextFormField(
                        initialValue: description,
                        decoration: const InputDecoration(
                          labelText: "Mô tả",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập mô tả";
                          }
                          return null;
                        },
                        onSaved: (value) => description = value!,
                      ),
                      const SizedBox(height: 16),
                      // Trạng thái
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: "Trạng thái",
                          border: OutlineInputBorder(),
                        ),
                        items: ["To do", "In progress", "Done", "Cancelled"]
                            .map((stat) => DropdownMenuItem(
                          value: stat,
                          child: Text(stat),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Độ ưu tiên
                      DropdownButtonFormField<int>(
                        value: priority,
                        decoration: const InputDecoration(
                          labelText: "Độ ưu tiên",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 1, child: Text("Thấp")),
                          DropdownMenuItem(value: 2, child: Text("Trung bình")),
                          DropdownMenuItem(value: 3, child: Text("Cao")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            priority = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Hạn hoàn thành
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Hạn hoàn thành",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickDueDate,
                          ),
                          hintText: dueDate != null
                              ? dueDate!.toString().split(" ")[0]
                              : "Chọn ngày",
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giao cho người dùng khác
                      TextFormField(
                        initialValue: assignedTo,
                        decoration: const InputDecoration(
                          labelText: "Giao cho (User ID)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onSaved: (value) => assignedTo = value,
                      ),
                      const SizedBox(height: 16),
                      // Danh mục
                      TextFormField(
                        initialValue: category,
                        decoration: const InputDecoration(
                          labelText: "Danh mục",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        onSaved: (value) => category = value ?? "",
                      ),
                      const SizedBox(height: 16),
                      // Tệp đính kèm
                      TextFormField(
                        initialValue: attachmentsString,
                        decoration: const InputDecoration(
                          labelText: "Tệp đính kèm (nhập link, cách nhau bởi dấu phẩy)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_file),
                        ),
                        onSaved: (value) => attachmentsString = value ?? "",
                      ),
                      const SizedBox(height: 20),
                      // Nút submit
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          widget.task == null ? "Thêm Công việc" : "Cập nhật Công việc",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
