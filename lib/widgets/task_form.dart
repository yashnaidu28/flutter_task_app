import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class AddTaskScreen extends StatefulWidget {
  final DatabaseReference database;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final String? taskKey;
  final Map? task;

  AddTaskScreen({
    required this.database,
    required this.flutterLocalNotificationsPlugin,
    this.taskKey,
    this.task,
  });

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _expectedDuration;
  DateTime? _deadline;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!['title'];
      _description = widget.task!['description'];
      _expectedDuration = widget.task!['expectedDuration'] ?? '';
      _deadline = widget.task!['deadline'] != null ? DateTime.parse(widget.task!['deadline']) : null;
      _isCompleted = widget.task!['status'] ?? false;
    } else {
      _title = '';
      _description = '';
      _expectedDuration = '';
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _deadline = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _scheduleNotification(DateTime deadline) async {
    final DateTime scheduledTime = deadline.subtract(const Duration(minutes: 10));
    final tz.TZDateTime scheduledNotificationDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Reminder',
      'You have a task due in 10 minutes',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final taskData = {
        'title': _title,
        'description': _description,
        'deadline': _deadline?.toIso8601String(),
        'expectedDuration': _expectedDuration,
        'status': _isCompleted,
      };

      if (widget.taskKey != null) {
        await widget.database.child(widget.taskKey!).set(taskData);
      } else {
        await widget.database.push().set(taskData);
      }

      if (_deadline != null) {
        await _scheduleNotification(_deadline!);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'Add Task',),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),  // Rounded borders
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),  // Rounded borders
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _expectedDuration,
                decoration: InputDecoration(
                  labelText: 'Expected Duration (e.g., 2 hours)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),  // Rounded borders
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expected duration';
                  }
                  return null;
                },
                onSaved: (value) {
                  _expectedDuration = value!;
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDeadline(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _deadline == null
                          ? 'Set Deadline'
                          : 'Deadline: ${DateFormat('yyyy-MM-dd – kk:mm').format(_deadline!)}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),  // Rounded borders
                      ),
                      suffixIcon: Icon(Icons.timer),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task != null ? 'Update Task' : 'Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
