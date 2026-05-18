class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.totalPkr,
    required this.paymentMethod,
    required this.itemCount,
  });

  final String id;
  final int totalPkr;
  final String paymentMethod;
  final int itemCount;
}
