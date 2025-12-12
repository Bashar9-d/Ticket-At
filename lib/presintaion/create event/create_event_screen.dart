import 'package:flutter/material.dart';

import '../../service/supabase_service.dart';
import '../../my_widget/my_colors.dart';
import 'confirm_page.dart';
import 'detailspage.dart';
import 'general_page.dart';
import 'location_page.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final EventFormData _formData = EventFormData();
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isDataLoaded = false;
  String? _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final eventData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (eventData != null) {
        _isEditMode = true;
        _eventId = eventData['id'].toString();

        _formData.title = eventData['title'];
        _formData.category = eventData['category'];
        _formData.description = eventData['description'];
        _formData.locationName = eventData['location'];
        _formData.email = eventData['email'];
        _formData.contactNumber = eventData['contact_number'];
        _formData.whatsappNumber = eventData['whatsapp'];
        _formData.socialLink = eventData['social_link'];
        _formData.totalTickets = eventData['total_tickets'];

        if (eventData['start_time'] != null) {
          _formData.startTime = DateTime.parse(eventData['start_time']);
        }
        if (eventData['end_time'] != null) {
          _formData.endTime = DateTime.parse(eventData['end_time']);
        }
      }
      _isDataLoaded = true;
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _submitEvent() async {
    setState(() => _isLoading = true);

    try {
      if (_isEditMode && _eventId != null) {
        await _supabaseService.updateEvent(_eventId!, _formData);
      } else {
        await _supabaseService.createEvent(_formData);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? "Event updated successfully! ✅" : "Event created successfully! ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception:", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _isEditMode ? "Edit Event" : "Create Event",
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors.primary))
          : Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                GeneralPage(formData: _formData, onNext: _nextPage),
                LocationPage(formData: _formData, onNext: _nextPage),
                DetailsPage(formData: _formData, onNext: _nextPage),
                ConfirmPage(
                  formData: _formData,
                  onConfirm: _submitEvent,
                  onBack: _previousPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stepItem(0, "General"),
          _stepItem(1, "Location"),
          _stepItem(2, "Details"),
          _stepItem(3, "Confirm"),
        ],
      ),
    );
  }

  Widget _stepItem(int index, String title) {
    bool isActive = index <= _currentPage;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isActive ? MyColors.primary : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: isActive ? MyColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}