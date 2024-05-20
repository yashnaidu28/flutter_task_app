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
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
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
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
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
                  final description = task['description'] as String;
                  final displayDescription = description.length > 40
                      ? '${description.substring(0, 40)}...'
                      : description;

                  return Card(
                    child: ListTile(
                      title: Text(task['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayDescription),
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
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
      ),
    );
  }
}
