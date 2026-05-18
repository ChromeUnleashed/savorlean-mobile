// lib/models/carousel_slide.dart
/// CarouselSlide model
/// Represents a single slide in the home screen hero carousel.
class CarouselSlide {
  final String id;
  final String headline;
  final String? subHeadline;
  final String imageUrl;
  final String? ctaText;
  final String? ctaLink;

  const CarouselSlide({
    required this.id,
    required this.headline,
    this.subHeadline,
    required this.imageUrl,
    this.ctaText,
    this.ctaLink,
  });

  factory CarouselSlide.fromJson(Map<String, dynamic> json) {
    return CarouselSlide(
      id: json['id'] as String,
      headline: json['headline'] as String,
      subHeadline: json['sub_headline'] as String?,
      imageUrl: json['image_url'] as String,
      ctaText: json['cta_text'] as String?,
      ctaLink: json['cta_link'] as String?,
    );
  }
}
