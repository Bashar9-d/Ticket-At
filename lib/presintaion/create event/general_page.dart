import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../my_widget/my_colors.dart';
import '../../service/supabase_service.dart';

class GeneralPage extends StatefulWidget {
  final EventFormData formData;
  final VoidCallback onNext;

  const GeneralPage({super.key, required this.formData, required this.onNext});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        widget.formData.imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            image: widget.formData.imageFile != null
                                ? DecorationImage(
                              image: FileImage(widget.formData.imageFile!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: widget.formData.imageFile == null
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.file_upload_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Upload Your Images",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        "Event Title",
                            (val) => widget.formData.title = val,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      _buildTextField(
                        "Event Category",
                            (val) => widget.formData.category = val,
                      ),
                      _buildTextField(
                        "Event Description",
                            (val) => widget.formData.description = val,
                        maxLines: 4,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (widget.formData.imageFile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please upload an image")),
                              );
                              return;
                            }
                            _formKey.currentState!.save();
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      String label,
      Function(String) onSaved, {
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onSaved: (val) => onSaved(val!),
            validator: validator,
          ),
        ],
      ),
    );
  }
}