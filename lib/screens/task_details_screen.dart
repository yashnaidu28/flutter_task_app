import 'package:chat_app/widgets/task_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatelessWidget {
  final DatabaseReference database;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final String taskKey;
  final Map task;

  const TaskDetailScreen({
    Key? key,
    required this.database,
    required this.flutterLocalNotificationsPlugin,
    required this.taskKey,
    required this.task,
  }) : super(key: key);

  Future<void> _deleteTask(BuildContext context) async {
    await database.child(taskKey).remove();
    Navigator.pop(context, true); // Return true to indicate deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTask(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Title', task['title']),
                    _buildDetailRow('Description', task['description']),
                    _buildDetailRow(
                        'Expected Duration', task['expectedDuration'] ?? 'N/A'),
                    _buildDetailRow(
                      'Deadline',
                      task['deadline'] != null
                          ? DateFormat('yyyy-MM-dd – kk:mm').format(
                              DateTime.parse(task['deadline'] as String))
                          : 'No deadline set',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskScreen(
                          database: database,
                          flutterLocalNotificationsPlugin:
                              flutterLocalNotificationsPlugin,
                          taskKey: taskKey,
                          task: task,
                        ),
                      ),
                    );
                    if (result == true) {
                      Navigator.pop(
                          context, true); // Return true to indicate update
                    }
                  },
                  child: const Text('Edit Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
