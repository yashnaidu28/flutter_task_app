
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    if (widget.task != null) {
      _title = widget.task!['title'];
      _description = widget.task!['description'];
      _expectedDuration = widget.task!['expectedDuration'] ?? '';
      _deadline = widget.task!['deadline'] != null
          ? DateTime.parse(widget.task!['deadline'])
          : null;
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
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _deadline = DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final taskData = {
        'title': _title,
        'description': _description,
        'deadline': _deadline?.toIso8601String(),
        'expectedDuration': _expectedDuration,
      };

      if (widget.taskKey != null) {
        await widget.database.child(widget.taskKey!).set(taskData);
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        await widget.database.push().set(taskData);
        Navigator.pop(context, true); // Return true to indicate success
      }

      if (_deadline != null) {
        await _scheduleNotification();
      }
    }
  }

  Future<void> _scheduleNotification() async {
    if (_deadline != null) {
      final deadlineTZ = tz.TZDateTime.from(_deadline!, tz.local);
      final scheduledDate = deadlineTZ.subtract(Duration(minutes: 10));

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await widget.flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Task Reminder',
        'Your task "$_title" is due in 10 minutes.',
        scheduledDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'Add Task'),
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
                    borderRadius: BorderRadius.circular(12.0),
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
                    borderRadius: BorderRadius.circular(12.0),
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
                    borderRadius: BorderRadius.circular(12.0),
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
                      suffixIcon: Icon(Icons.timer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
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
