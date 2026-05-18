// lib/providers/home_provider.dart
// Riverpod providers for the Home Screen data.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/carousel_slide.dart';
import '../models/testimonial.dart';
import '../services/settings_service.dart';

part 'home_provider.g.dart';

/// Provides a singleton instance of the SettingsService.
@riverpod
SettingsService settingsService(Ref ref) {
  return SettingsService(Supabase.instance.client);
}

/// A data class to hold all the combined data needed for the Home Screen.
class HomeData {
  final List<CarouselSlide> slides;
  final List<Testimonial> testimonials;
  final String? announcement;

  HomeData({
    required this.slides,
    required this.testimonials,
    this.announcement,
  });
}

/// Fetches all the data needed for the Home Screen concurrently.
@riverpod
Future<HomeData> homeData(Ref ref) async {
  final service = ref.watch(settingsServiceProvider);

  // Fetch everything concurrently for faster loading
  final results = await Future.wait([
    service.fetchCarouselSlides(),
    service.fetchTestimonials(),
    service.fetchAnnouncement(),
  ]);

  return HomeData(
    slides: results[0] as List<CarouselSlide>,
    testimonials: results[1] as List<Testimonial>,
    announcement: results[2] as String?,
  );
}
