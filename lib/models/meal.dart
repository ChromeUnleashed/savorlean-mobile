class Meal {
  final String id;
  final String slug;
  final String name;
  final String categoryId;
  final String? categoryName;
  final List<String> tags;
  final String description;
  final List<String> ingredients;
  final int caloriesKcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final List<String> images;
  final int pricePkr;
  final bool isAvailable;
  final bool isFeatured;
  final bool isBestseller;

  const Meal({
    required this.id,
    required this.slug,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.tags,
    required this.description,
    required this.ingredients,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.images,
    required this.pricePkr,
    required this.isAvailable,
    required this.isFeatured,
    required this.isBestseller,
  });

  String? get imageUrl => images.isNotEmpty ? images.first : null;

  factory Meal.fromJson(Map<String, dynamic> json) {
    final cat = json['categories'] as Map<String, dynamic>?;
    return Meal(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String,
      categoryName: cat?['name'] as String?,
      tags: List<String>.from(json['tags'] as List),
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      caloriesKcal: json['calories_kcal'] as int,
      proteinG: json['protein_g'] as int,
      carbsG: json['carbs_g'] as int,
      fatG: json['fat_g'] as int,
      images: List<String>.from(json['images'] as List),
      pricePkr: json['price_pkr'] as int,
      isAvailable: json['is_available'] as bool,
      isFeatured: json['is_featured'] as bool,
      isBestseller: json['is_bestseller'] as bool,
    );
  }
}
