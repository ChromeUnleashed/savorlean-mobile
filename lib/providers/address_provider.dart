import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/address.dart';
import '../providers/auth_provider.dart';
import '../services/address_service.dart';

part 'address_provider.g.dart';

@riverpod
Future<Address?> defaultAddress(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return AddressService().fetchDefaultAddress(user.id);
}
