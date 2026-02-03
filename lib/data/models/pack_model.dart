class PackModel {
  final String id;
  final String businessId;
  final String title;
  final String? description;
  final String? category;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final int quantityTotal;
  final int quantityAvailable;
  final String status;
  final DateTime pickupStart;
  final DateTime pickupEnd;

  PackModel({
    required this.id,
    required this.businessId,
    required this.title,
    this.description,
    this.category,
    this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.quantityTotal,
    required this.quantityAvailable,
    required this.status,
    required this.pickupStart,
    required this.pickupEnd,
  });

  factory PackModel.fromMap(Map<String, dynamic> map) {
    return PackModel(
      id: map['id'],
      businessId: map['business_id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      imageUrl: map['image_url'],
      price: (map['price'] as num).toDouble(),
      originalPrice: map['original_price'] != null ? (map['original_price'] as num).toDouble() : null,
      quantityTotal: map['quantity_total'],
      quantityAvailable: map['quantity_available'],
      status: map['status'],
      pickupStart: DateTime.parse(map['pickup_start']),
      pickupEnd: DateTime.parse(map['pickup_end']),
    );
  }
}
