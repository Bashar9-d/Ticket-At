import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../my_widget/my_colors.dart';
import '../my_widget/my_routes.dart';
import '../service/supabase_service.dart';

class MyTicket extends StatefulWidget {
  const MyTicket({super.key});

  @override
  State<MyTicket> createState() => _MyTicketState();
}

class _MyTicketState extends State<MyTicket> {
  final _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset("assets/Logo2.svg"),
        ),
        title: const Text(
          "My Tickets",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _service.getMyTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.airplane_ticket_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Looking for your tickets?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Explore events"),
                  ),
                ],
              ),
            );
          }

          final tickets = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildTicketCard(tickets[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final event = ticket['events'];
    final String ticketId = ticket['id'];
    final String status = ticket['status'] ?? 'valid';

    DateTime? startTime = event['start_time'] != null
        ? DateTime.parse(event['start_time'])
        : null;
    String dateStr = startTime != null
        ? DateFormat('MMM d, yyyy').format(startTime)
        : "TBA";
    String timeStr = startTime != null
        ? DateFormat('hh:mm a').format(startTime)
        : "";

    Color statusColor = status == 'valid'
        ? Colors.green
        : (status == 'expired' ? Colors.red : Colors.grey);
    String statusText = status == 'valid'
        ? "Valid"
        : (status == 'expired' ? "Expired" : "Used");

    return GestureDetector(
      onTap: () => _showQRCodeDialog(ticket, event),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? "No Title",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _iconText(
                    Icons.location_on_outlined,
                    event['location'] ?? "Unknown Location",
                  ),
                  const SizedBox(height: 4),
                  _iconText(
                    Icons.calendar_today_outlined,
                    "$dateStr • $timeStr",
                  ),
                  const SizedBox(height: 12),

                  // الحالة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status == 'valid'
                              ? Icons.check_circle_outline
                              : Icons.info_outline,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                QrImageView(
                  data: ticketId,
                  version: QrVersions.auto,
                  size: 60.0,
                  foregroundColor: MyColors.primary,
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showQRCodeDialog(
    Map<String, dynamic> ticket,
    Map<String, dynamic> event,
  ) {
    final String ticketId = ticket['id'];
    DateTime? startTime = event['start_time'] != null
        ? DateTime.parse(event['start_time'])
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                QrImageView(
                  data: ticketId,
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: MyColors.primary,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: MyColors.primary,
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  ticketId.substring(0, 8).toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 20),

                Text(
                  event['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  "Standard Ticket",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 15),

                Text(
                  event['location'] ?? "",
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                if (startTime != null)
                  Text(
                    DateFormat('MMM d, yyyy | hh:mm a').format(startTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
