import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/address.dart';

class AddressService {
  final _client = Supabase.instance.client;

  /// Returns the user's default address, or null if none is saved.
  Future<Address?> fetchDefaultAddress(String userId) async {
    try {
      final data = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (data == null) return null;
      return Address.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  /// Replaces (or creates) the user's default address.
  /// Deletes any existing default first to satisfy the unique partial index,
  /// then inserts the new one with is_default = true.
  Future<void> saveDefaultAddress({
    required String userId,
    required String fullName,
    required String phone,
    required String streetAddress,
    required String area,
    required String city,
  }) async {
    await _client
        .from('addresses')
        .delete()
        .eq('user_id', userId)
        .eq('is_default', true);

    await _client.from('addresses').insert({
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'street_address': streetAddress,
      'area': area,
      'city': city,
      'is_default': true,
    });
  }
}
