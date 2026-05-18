// lib/models/testimonial.dart
/// Testimonial model
/// Represents a customer review displayed on the home screen.
class Testimonial {
  final String id;
  final String authorName;
  final String content;
  final int rating;
  final String? imageUrl;

  const Testimonial({
    required this.id,
    required this.authorName,
    required this.content,
    required this.rating,
    this.imageUrl,
  });

  /// Creates a Testimonial from a Supabase JSON map.
  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] as String,
      authorName: 'Customer',
      content: json['body'] as String,
      rating: json['rating'] as int,
      imageUrl: null,
    );
  }
}
