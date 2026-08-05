import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final service = NotificationService();

  List<Map<String, dynamic>> notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    notifications = await service.getNotifications();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text("No notifications."),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (_, index) {
                    final notification = notifications[index];

                    return ListTile(
                      leading: Icon(
                        notification["is_read"]
                            ? Icons.notifications_none
                            : Icons.notifications,
                      ),
                      title: Text(notification["title"]),
                      subtitle: Text(notification["message"]),
                      onTap: () async {
                        await service.markAsRead(notification["id"]);
                        loadNotifications();
                      },
                    );
                  },
                ),
    );
  }
}
