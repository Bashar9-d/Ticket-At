import 'package:flutter/material.dart';

import '../my_widget/my_colors.dart';
import '../service/supabase_service.dart';

class EventDashboard extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDashboard({super.key, required this.event});

  @override
  State<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  final _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['title'] ?? "Event details"),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.event['image_url'] != null)
              Image.network(
                widget.event['image_url'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: MyColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${widget.event['location'] ?? 'undefined'}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.event['description'] ?? "There is no description"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Divider(thickness: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "List of registered attendees:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            FutureBuilder(
              future: _service.getEventAttendees(widget.event['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "An error occurred while retrieving data:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text("No one has registered yet")),
                  );
                }

                final attendees = snapshot.data as List;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attendees.length,
                  itemBuilder: (context, index) {
                    final ticket = attendees[index];
                    final isAttended = ticket['status'] == 'attended';
                    final ticketId = ticket['id'].toString();
                    final displayId = ticketId.length > 5
                        ? ticketId.substring(0, 5)
                        : ticketId;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          isAttended ? Colors.green[100] : Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            color: isAttended ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: Text("Visitor #${index + 1}"),
                        subtitle: Text("Ticket number: ...$displayId"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAttended ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAttended ? "Attended" : "Not Attended",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}