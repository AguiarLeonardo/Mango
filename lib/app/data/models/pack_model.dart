/// Enum que representa los posibles estados de un pack.
enum PackStatus {
  available,
  soldOut,
  hidden;

  static PackStatus fromString(String value) {
    return PackStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PackStatus.available,
    );
  }
}

class PackModel {
  final String id; // String (UUID)
  final String businessId;
  final String title;
  final double price;
  final int quantityAvailable;
  
  // ✅ NUEVA VARIABLE: Cantidad total original del pack
  final int quantityTotal; 

  final DateTime pickupStart;
  final DateTime pickupEnd;
  final String? imageUrl;
  final String? businessName;
  final PackStatus status;
  
  // Para saber si el pack está oculto o activo
  final bool isActive;

  PackModel({
    required this.id,
    required this.businessId,
    required this.title,
    required this.price,
    required this.quantityAvailable,
    required this.quantityTotal, // ✅ Añadido al constructor
    required this.pickupStart,
    required this.pickupEnd,
    this.imageUrl,
    this.businessName,
    this.status = PackStatus.available,
    this.isActive = true, // Por defecto asume que está activo
  });

  // 🔹 LO QUE FALTABA: copyWith
  // Te permite clonar un objeto cambiando solo algunas propiedades.
  // Súper útil para actualizar el 'quantityAvailable' cuando alguien hace una reserva.
  PackModel copyWith({
    String? id,
    String? businessId,
    String? title,
    double? price,
    int? quantityAvailable,
    int? quantityTotal, // ✅ Añadido al copyWith
    DateTime? pickupStart,
    DateTime? pickupEnd,
    String? imageUrl,
    String? businessName,
    PackStatus? status,
    bool? isActive, 
  }) {
    return PackModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      price: price ?? this.price,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantityTotal: quantityTotal ?? this.quantityTotal, // ✅ Añadido
      pickupStart: pickupStart ?? this.pickupStart,
      pickupEnd: pickupEnd ?? this.pickupEnd,
      imageUrl: imageUrl ?? this.imageUrl,
      businessName: businessName ?? this.businessName,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive, 
    );
  }

  factory PackModel.fromJson(Map<String, dynamic> json) {
    return PackModel(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',

      // 🔹 LUPA: Añadí .toString() porsiaca llega como número de alguna forma
      title: json['title']?.toString() ?? 'Pack sin nombre',

      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantityAvailable: (json['quantity_available'] as num?)?.toInt() ?? 0,
      
      // ✅ Añadido: Leemos quantity_total de la base de datos
      quantityTotal: (json['quantity_total'] as num?)?.toInt() ?? 0,

      // 🔹 FIX (LUPA): Si 'pickup_start' era null, hacer null.toString() creaba
      // el string "null", lo cual no es limpio. Ahora validamos primero.
      pickupStart: json['pickup_start'] != null
          ? DateTime.tryParse(json['pickup_start'].toString()) ?? DateTime.now()
          : DateTime.now(),

      pickupEnd: json['pickup_end'] != null
          ? DateTime.tryParse(json['pickup_end'].toString()) ?? DateTime.now()
          : DateTime.now(),

      // 🔹 LUPA: Añadido .toString() para evitar casteos extraños
      imageUrl: json['image_url']?.toString(),

      businessName: (json['businesses'] != null && json['businesses'] is Map)
          ? json['businesses']['commercial_name']?.toString()
          : null,
      status: PackStatus.fromString(json['status']?.toString() ?? 'available'),
      
      // Leemos is_active de la base de datos (si viene nulo, asumimos true)
      isActive: json['is_active'] ?? true, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'title': title,
      'price': price,
      'quantity_available': quantityAvailable,
      'quantity_total': quantityTotal, // ✅ Añadido para cuando envíes datos a Supabase
      'pickup_start': pickupStart.toIso8601String(),
      'pickup_end': pickupEnd.toIso8601String(),
      'image_url': imageUrl,
      'status': status.name,
      'is_active': isActive, 
    };
  }
}