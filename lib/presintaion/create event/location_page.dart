import 'package:flutter/material.dart';

import '../../my_widget/my_colors.dart';
import '../../service/supabase_service.dart';

class LocationPage extends StatelessWidget {
  final EventFormData formData;
  final VoidCallback onNext;
  final _formKey = GlobalKey<FormState>();

  LocationPage({super.key, required this.formData, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Search Location",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onSaved: (val) => formData.locationName = val,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text("or", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 24),

            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.primary),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.my_location),
                  SizedBox(width: 8),
                  Text("Select on Map (Coming Soon)"),
                ],
              ),
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  onNext();
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
}
