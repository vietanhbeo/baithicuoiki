import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<TaskModel>> _taskListFuture;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _taskListFuture = dbHelper.getAllTasks();
    });
  }

  void _deleteTask(String id) async {
    await dbHelper.deleteTask(id);
    _loadTasks();
  }

  void _markAsComplete(TaskModel task) async {
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: "Done",
      priority: task.priority,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
      assignedTo: task.assignedTo,
      createdBy: task.createdBy,
      category: task.category,
      attachments: task.attachments,
      completed: true,
    );
    await dbHelper.updateTask(updatedTask);
    _loadTasks();
  }

  Widget _buildTaskItem(TaskModel task) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Trạng thái: ${task.status}",
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                "Độ ưu tiên: ${task.priority}",
                style: const TextStyle(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (task.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Hạn hoàn thành: ${task.dueDate!.toString().split(' ')[0]}",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _markAsComplete(task),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(task.id),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
          ).then((value) => _loadTasks());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar trong suốt
        elevation: 0,
        title: const Text("Danh sách Công việc"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Triển khai tìm kiếm/lọc công việc theo ý bạn
            },
          )
        ],
      ),
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
        // Sử dụng SafeArea để đảm bảo nội dung không bị che bởi các khu vực hệ thống
        child: SafeArea(
          child: FutureBuilder<List<TaskModel>>(
            future: _taskListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Không có công việc nào",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      _buildTaskItem(snapshot.data![index]),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskFormScreen()),
          ).then((value) => _loadTasks());
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
