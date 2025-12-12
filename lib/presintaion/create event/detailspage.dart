import 'package:flutter/material.dart';
import '../../my_widget/my_colors.dart';
import '../../service/supabase_service.dart';

class DetailsPage extends StatefulWidget {
  final EventFormData formData;
  final VoidCallback onNext;

  const DetailsPage({super.key, required this.formData, required this.onNext});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        widget.formData.startTime = dateTime;
      } else {
        widget.formData.endTime = dateTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildTextField(
              "Email Address",
              (v) => widget.formData.email = v,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              "Contact Number",
              (v) => widget.formData.contactNumber = v,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              "WhatsApp Number (Optional)",
              (v) => widget.formData.whatsappNumber = v,
              keyboardType: TextInputType.phone,
            ),

            _buildTextField(
              "Number of Available Tickets",
              (v) => widget.formData.totalTickets = int.tryParse(v),
              keyboardType: TextInputType.number,
            ),


            const SizedBox(height: 24),

            const Text(
              "Time & Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(true),
                    child: Text(
                      widget.formData.startTime == null
                          ? "Start Time"
                          : widget.formData.startTime.toString().substring(
                              0,
                              16,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(false),
                    child: Text(
                      widget.formData.endTime == null
                          ? "End Time"
                          : widget.formData.endTime.toString().substring(0, 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField(
              "Add Social Links",
              (v) => widget.formData.socialLink = v,
            ),
            Row(
              children: [
                Icon(Icons.facebook, color: MyColors.primary),
                SizedBox(width: 10),
                Icon(Icons.video_library, color: MyColors.primary),
                SizedBox(width: 10),
                Icon(Icons.link, color: MyColors.primary),
              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (widget.formData.startTime == null ||
                      widget.formData.endTime == null ||
                      widget.formData.totalTickets == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please fill date, time and ticket count",
                        ),
                      ),
                    );
                    return;
                  }
                  widget.onNext();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onSaved, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onSaved: (val) => onSaved(val!),
            validator: (val) =>
                (val == null || val.isEmpty) ? "Required" : null,
          ),
        ],
      ),
    );
  }
}
