class PromoCode {
  const PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.usedCount,
    required this.isActive,
    this.maxUses,
    this.maxDiscountPkr,
    this.validFrom,
    this.validUntil,
  });

  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final int usedCount;
  final bool isActive;
  final int? maxUses;
  final int? maxDiscountPkr;
  final DateTime? validFrom;
  final DateTime? validUntil;

  // Returns the discount amount in PKR for a given subtotal.
  // Percentage discounts are capped by maxDiscountPkr when set.
  // Result is clamped to [0, subtotalPkr] so it never exceeds the order value.
  int discountFor(int subtotalPkr) {
    if (subtotalPkr <= 0) return 0;
    int amount;
    if (discountType == 'fixed') {
      amount = discountValue.round();
    } else {
      amount = (subtotalPkr * discountValue / 100).round();
      if (maxDiscountPkr != null && amount > maxDiscountPkr!) {
        amount = maxDiscountPkr!;
      }
    }
    return amount.clamp(0, subtotalPkr);
  }

  String get displayLabel {
    if (discountType == 'fixed') return 'Rs. ${discountValue.round()} off';
    final pct = discountValue % 1 == 0
        ? '${discountValue.round()}%'
        : '$discountValue%';
    return maxDiscountPkr != null
        ? '$pct off (max Rs. $maxDiscountPkr)'
        : '$pct off';
  }

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] as String,
      discountValue: double.parse(json['discount_value'].toString()),
      usedCount: json['used_count'] as int,
      isActive: json['is_active'] as bool,
      maxUses: json['max_uses'] as int?,
      maxDiscountPkr: json['max_discount_pkr'] as int?,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'] as String)
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
    );
  }
}
