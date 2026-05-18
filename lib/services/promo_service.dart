import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/promo_code.dart';

class PromoException implements Exception {
  const PromoException(this.message);
  final String message;
}

class PromoService {
  final SupabaseClient _client;
  PromoService(this._client);

  Future<PromoCode> validate(String code) async {
    final data = await _client
        .from('promo_codes')
        .select()
        .eq('code', code.trim().toUpperCase())
        .maybeSingle();

    if (data == null) throw const PromoException('Invalid promo code.');

    final promo = PromoCode.fromJson(data);

    if (!promo.isActive) {
      throw const PromoException('This promo code is no longer active.');
    }

    final now = DateTime.now();
    if (promo.validFrom != null && now.isBefore(promo.validFrom!)) {
      throw const PromoException('This promo code is not yet valid.');
    }
    if (promo.validUntil != null && now.isAfter(promo.validUntil!)) {
      throw const PromoException('This promo code has expired.');
    }
    if (promo.maxUses != null && promo.usedCount >= promo.maxUses!) {
      throw const PromoException(
        'This promo code has reached its usage limit.',
      );
    }

    return promo;
  }
}
