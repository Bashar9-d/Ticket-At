import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventFormData {
  File? imageFile;
  String? title;
  String? category;
  String? description;
  String? locationName;
  String? email;
  String? contactNumber;
  String? whatsappNumber;
  int? totalTickets;
  DateTime? startTime;
  DateTime? endTime;
  String? socialLink;
  String? price;
}

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> createEvent(EventFormData data) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("You must be logged in to create an event");

    String? imageUrl;

    if (data.imageFile != null) {
      try {
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('events').upload(fileName, data.imageFile!);
        imageUrl = supabase.storage.from('events').getPublicUrl(fileName);
      } catch (e) {
        throw Exception("Failed to upload image: $e");
      }
    }

    final eventData = {
      'owner_id': user.id,
      'title': data.title,
      'type': data.category ?? 'General',
      'category': data.category,
      'description': data.description,
      'location': data.locationName,
      'email': data.email,
      'contact_number': data.contactNumber,
      'whatsapp': data.whatsappNumber,
      'total_tickets': data.totalTickets,
      'start_time': data.startTime?.toIso8601String(),
      'end_time': data.endTime?.toIso8601String(),
      'social_link': data.socialLink,
      'image_url': imageUrl,
    };

    try {
      await supabase.from('events').insert(eventData);
    } catch (e) {
      throw Exception("Failed to save data: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getMyEvents() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('events')
        .select()
        .eq('owner_id', user.id)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<String> verifyTicket(String ticketId) async {
    try {
      final response = await supabase
          .from('registrations')
          .select('*, events!inner(*)')
          .eq('id', ticketId)
          .single();

      final eventOwnerId = response['events']['owner_id'];
      final currentUser = supabase.auth.currentUser!.id;

      if (eventOwnerId != currentUser) {
        return "Error: You are not authorized to manage this event";
      }

      if (response['status'] == 'attended') {
        return "Warning: This ticket has already been used";
      }

      await supabase
          .from('registrations')
          .update({'status': 'attended'})
          .eq('id', ticketId);

      return "Verified successfully! ✅";
    } catch (e) {
      return "Invalid code or network error";
    }
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final data = await supabase
        .from('events')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> bookEvent(String eventId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("You must be logged in first");

    await supabase.from('registrations').insert({
      'event_id': eventId,
      'user_id': user.id,
      'status': 'valid',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMyTickets() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('registrations')
        .select('*, events(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> checkInAttendee(String ticketId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("You must be logged in");

    try {
      final response = await supabase
          .from('registrations')
          .select('*, events!inner(*)')
          .eq('id', ticketId)
          .single();

      final event = response['events'];

      if (event['owner_id'] != user.id) {
        return {
          'success': false,
          'message': 'This ticket does not belong to any of your events!',
          'eventTitle': event['title']
        };
      }

      if (response['status'] == 'attended') {
        return {
          'success': false,
          'message': 'Ticket already used (Attended)',
          'eventTitle': event['title']
        };
      }

      await supabase
          .from('registrations')
          .update({'status': 'attended'})
          .eq('id', ticketId);

      return {
        'success': true,
        'message': 'Valid Ticket! ✅',
        'eventTitle': event['title'],
        'attendeeName': 'Guest'
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid or non-existent ticket code',
        'eventTitle': 'Unknown'
      };
    }
  }

  Future<List<Map<String, dynamic>>> getEventAttendees(dynamic eventId) async {
    try {
      final data = await supabase
          .from('registrations')
          .select('*')
          .eq('event_id', eventId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }
  Future<void> updateEvent(String eventId, EventFormData data) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("You must be logged in");

    final Map<String, dynamic> updates = {
      'title': data.title,
      'type': data.category ?? 'General',
      'category': data.category,
      'description': data.description,
      'location': data.locationName,
      'email': data.email,
      'contact_number': data.contactNumber,
      'whatsapp': data.whatsappNumber,
      'total_tickets': data.totalTickets,
      'start_time': data.startTime?.toIso8601String(),
      'end_time': data.endTime?.toIso8601String(),
      'social_link': data.socialLink,
    };

    if (data.imageFile != null) {
      try {
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('events').upload(fileName, data.imageFile!);
        final imageUrl = supabase.storage.from('events').getPublicUrl(fileName);

        updates['image_url'] = imageUrl;
      } catch (e) {
        throw Exception("Failed to upload new image: $e");
      }
    }

    try {
      await supabase
          .from('events')
          .update(updates)
          .eq('id', eventId)
          .eq('owner_id', user.id);
    } catch (e) {
      throw Exception("Failed to update event: $e");
    }
  }
}