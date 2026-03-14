/// Enum que representa los posibles estados de una orden.
enum OrderStatus {
  pending,
  completed,
  cancelled,
  expiredNoShow;

  /// Convierte un String de la BD al enum correspondiente.
  /// Mapea 'expired_no_show' (snake_case de Supabase) → expiredNoShow.
  static OrderStatus fromString(String value) {
    if (value == 'expired_no_show') return OrderStatus.expiredNoShow;
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Serializa el enum a su representación en la BD.
  String toDbString() {
    if (this == OrderStatus.expiredNoShow) return 'expired_no_show';
    return name;
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String packId;
  final String businessId;
  final String code;
  final OrderStatus status;
  final DateTime createdAt;

  // Datos del pack asociado (join)
  final String? packTitle;
  final String? packImageUrl;
  final double? packPrice;
  final DateTime? pickupStart;
  final DateTime? pickupEnd;

  // Datos del negocio asociado (join)
  final String? businessName;

  OrderModel({
    required this.id,
    required this.userId,
    required this.packId,
    required this.businessId,
    required this.code,
    required this.status,
    required this.createdAt,
    this.packTitle,
    this.packImageUrl,
    this.packPrice,
    this.pickupStart,
    this.pickupEnd,
    this.businessName,
  });

  // ─── Lógica de Negocio (US 2) ───
  /// Solo se puede cancelar si la orden está pendiente
  /// y faltan más de 2 horas para el inicio de recogida.
  bool get canCancel =>
      status == OrderStatus.pending &&
      pickupStart != null &&
      DateTime.now().isBefore(pickupStart!.subtract(const Duration(hours: 2)));

  // ─── Serialización ───
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final pack = json['packs'] as Map<String, dynamic>? ?? {};
    final business = pack['businesses'] as Map<String, dynamic>? ?? {};

    final DateTime createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ??
            DateTime.now()
        : DateTime.now();

    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      packId: json['pack_id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      code:
          json['code']?.toString() ?? json['pickup_code']?.toString() ?? '---',
      status: OrderStatus.fromString(json['status']?.toString() ?? 'pending'),
      createdAt: createdAt,
      packTitle: pack['title']?.toString(),
      packImageUrl: pack['image_url']?.toString(),
      packPrice: (pack['price'] as num?)?.toDouble(),
      pickupStart: _parsePickupTime(pack['pickup_start']),
      pickupEnd: _parsePickupTime(pack['pickup_end']),
      businessName: business['commercial_name']?.toString(),
    );
  }

  /// Parsea un campo de hora de recogida de Supabase.
  /// Se asume que ahora llega como un TIMESTAMPTZ válido (ISO-8601 full)
  /// y lo convertimos a la zona horaria local del dispositivo.
  static DateTime? _parsePickupTime(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString();

    final direct = DateTime.tryParse(str);
    if (direct != null) {
      return direct.toLocal(); // Convertimos cualquier UTC/ISO a hora local
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pack_id': packId,
      'business_id': businessId,
      'code': code,
      'status': status.toDbString(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? packId,
    String? businessId,
    String? code,
    OrderStatus? status,
    DateTime? createdAt,
    String? packTitle,
    String? packImageUrl,
    double? packPrice,
    DateTime? pickupStart,
    DateTime? pickupEnd,
    String? businessName,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packId: packId ?? this.packId,
      businessId: businessId ?? this.businessId,
      code: code ?? this.code,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      packTitle: packTitle ?? this.packTitle,
      packImageUrl: packImageUrl ?? this.packImageUrl,
      packPrice: packPrice ?? this.packPrice,
      pickupStart: pickupStart ?? this.pickupStart,
      pickupEnd: pickupEnd ?? this.pickupEnd,
      businessName: businessName ?? this.businessName,
    );
  }
}
