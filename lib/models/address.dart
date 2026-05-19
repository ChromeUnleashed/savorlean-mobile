class Address {
  const Address({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.streetAddress,
    required this.area,
    required this.city,
    required this.isDefault,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String streetAddress;
  final String area;
  final String city;
  final bool isDefault;
  final DateTime createdAt;

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      streetAddress: map['street_address'] as String,
      area: map['area'] as String,
      city: map['city'] as String,
      isDefault: map['is_default'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
