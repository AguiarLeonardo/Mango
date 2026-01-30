class BusinessModel {
  String commercialName;
  String shortDesc;
  String? category;
  
  // Ubicación (Faltaban estos campos en tu modelo original)
  String? state;
  String? city;
  String? municipality;
  String address;
  
  String phonePrefix;
  String phoneNumber;
  String legalName;
  String rif;
  String repName;
  bool acceptedTerms;
  String? rifImagePath; // Ruta local del archivo
  String? rifUrl;       // URL remota (después de subir a Supabase)

  BusinessModel({
    this.commercialName = '',
    this.shortDesc = '',
    this.category,
    this.state,
    this.city,
    this.municipality,
    this.address = '',
    this.phonePrefix = '0412',
    this.phoneNumber = '',
    this.legalName = '',
    this.rif = '',
    this.repName = '',
    this.acceptedTerms = false,
    this.rifImagePath,
    this.rifUrl,
  });

  /// Prepara los datos para enviarlos a la tabla 'businesses' de Supabase
  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'id': userId, // Vinculamos con el Auth ID
      'commercial_name': commercialName,
      'legal_name': legalName,
      'rif': rif,
      'rif_image_url': rifUrl, // Este campo se llenará después de subir la foto
      'category': category,
      'description': shortDesc,
      'phone_prefix': phonePrefix,
      'phone_number': phoneNumber,
      'state': state,
      'city': city,
      'municipality': municipality,
      'address': address,
      'rep_name': repName,
      'role': 'business',
    };
  }
}