// lib/services/settings_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/carousel_slide.dart';
import '../models/testimonial.dart';

class SettingsService {
  final SupabaseClient _client;

  SettingsService(this._client);

  /// Fetches active carousel slides in display order.
  Future<List<CarouselSlide>> fetchCarouselSlides() async {
    final data = await _client
        .from('carousel_slides')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);
    return (data as List).map((json) => CarouselSlide.fromJson(json)).toList();
  }

  /// Fetches recent reviews for the home screen.
  Future<List<Testimonial>> fetchTestimonials() async {
    final data = await _client
        .from('reviews')
        .select()
        .order('created_at', ascending: false)
        .limit(10);
    return (data as List).map((json) => Testimonial.fromJson(json)).toList();
  }

  /// Fetches the announcement bar text from the site_content table.
  /// Returns null if the announcement is not set or disabled.
  Future<String?> fetchAnnouncement() async {
    try {
      final data = await _client
          .from('site_content')
          .select()
          .eq('key', 'announcement_bar')
          .maybeSingle();

      if (data == null) return null;

      // The column might be named 'value', 'text', or 'content'
      final text = data['value'] ?? data['content'] ?? data['text'];
      return text?.toString();
    } catch (e) {
      // If the table or row doesn't exist, just return null
      // instead of crashing the whole home screen.
      return null;
    }
  }
}
