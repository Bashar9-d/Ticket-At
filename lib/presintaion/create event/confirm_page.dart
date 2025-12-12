import 'package:flutter/material.dart';

import '../../my_widget/my_colors.dart';
import '../../service/supabase_service.dart';
import 'create_event_screen.dart';

class ConfirmPage extends StatelessWidget {
  final EventFormData formData;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const ConfirmPage(
      {super.key, required this.formData, required this.onConfirm, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSectionTitle("General"),
                _buildSummaryItem(Icons.image, "Images uploaded",
                    isChecked: formData.imageFile != null),
                _buildSummaryItem(
                    Icons.title, "Title", subtitle: formData.title),
                _buildSummaryItem(Icons.description, "Description",
                    subtitle: formData.description),
                const Divider(),

                _buildSectionTitle("Location"),
                _buildSummaryItem(Icons.location_on,
                    formData.locationName ?? "No location selected"),
                const Divider(),

                _buildSectionTitle("Details"),
                _buildSummaryItem(Icons.email, formData.email),
                _buildSummaryItem(Icons.phone, formData.contactNumber),
                _buildSummaryItem(Icons.confirmation_number, "Total Tickets",
                    subtitle: "${formData.totalTickets}"),
                _buildSummaryItem(Icons.access_time, "Date & Time",
                    subtitle: "Start: ${formData.startTime.toString().substring(
                        0, 16)}\nEnd: ${formData.endTime.toString().substring(
                        0, 16)}"),

              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    label: const Text("Previous"),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: MyColors.primary),
                        foregroundColor: MyColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Confirm"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSummaryItem(IconData icon, String? title,
      {String? subtitle, bool isChecked = false}) {
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon, color: MyColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(
          subtitle, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
      trailing: isChecked
          ? Icon(Icons.check_circle, color: MyColors.primary)
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}