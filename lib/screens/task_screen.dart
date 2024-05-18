import '../task_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'task_details_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final DatabaseReference database =
      FirebaseDatabase.instance.ref().child('tasks');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotificationPlugin();
    tz.initializeTimeZones();
  }

  void _initializeNotificationPlugin() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Widget _buildTaskList() {
    return StreamBuilder<DatabaseEvent>(
      stream: database.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No tasks found.'));
        }

        final Map<dynamic, dynamic> tasks =
            Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
        return ListView(
          children: tasks.entries.map((entry) {
            final String key = entry.key;
            final Map task = entry.value as Map;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Card(
                child: ListTile(
                  title: Text(task['title']),
                  subtitle: Text(
                    task['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      task['status']
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    onPressed: () {
                      database.child(key).update({'status': !task['status']});
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(
                          database: database,
                          flutterLocalNotificationsPlugin:
                              flutterLocalNotificationsPlugin,
                          taskKey: key,
                          task: task,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                database: database,
                flutterLocalNotificationsPlugin:
                    flutterLocalNotificationsPlugin,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
