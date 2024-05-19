import 'package:chat_app/widgets/task_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
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
    tz.initializeTimeZones();
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: database.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              (snapshot.data! as DatabaseEvent).snapshot.value != null) {
            final tasks = Map<String, dynamic>.from(
                (snapshot.data! as DatabaseEvent).snapshot.value
                    as Map<dynamic, dynamic>);

            return ListView(
              children: tasks.keys.map((String key) {
                final task = Map<String, dynamic>.from(tasks[key]);
                return Card(
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['description']),
                        if (task['deadline'] != null)
                          Text(
                            'Deadline: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(task['deadline']))}',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    trailing: Checkbox(
                      value: task['status'] ?? false,
                      onChanged: (value) {
                        database.child(key).update({'status': value});
                      },
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
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
                      if (result == true) {
                        setState(() {}); // Refresh the task list
                      }
                    },
                  ),
                );
              }).toList(),
            );
          } else {
            return const Center(
              child: Text('No tasks available'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                database: database,
                flutterLocalNotificationsPlugin:
                    flutterLocalNotificationsPlugin,
              ),
            ),
          );
          if (result == true) {
            setState(() {}); // Refresh the task list
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
