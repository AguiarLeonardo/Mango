class UserModel {
  String? names;
  String? surnames;
  // NUEVOS CAMPOS
  String? documentType;   // V-, E-, P-
  String? documentNumber; // 12345678
  
  String? email;
  String? phonePrefix;
  String? phoneNumber;
  String? state;
  String? city;
  String? municipality;
  String? address;
  String? username;
  String? password;
  bool acceptedTerms = false;

  UserModel({
    this.names,
    this.surnames,
    this.documentType = 'V-', // Valor por defecto
    this.documentNumber,
    this.email,
    this.phonePrefix = '0412',
    this.phoneNumber,
    this.state,
    this.city,
    this.municipality,
    this.address,
    this.username,
    this.password,
    this.acceptedTerms = false,
  });

  Map<String, dynamic> toSupabaseMap() {
    return {
      'names': names,
      'surnames': surnames,
      // Guardamos el documento completo concatenado: "V-12345678"
      'document_id': "$documentType$documentNumber", 
      'phone_prefix': phonePrefix,
      'phone_number': phoneNumber,
      'state': state,
      'city': city,
      'municipality': municipality,
      'address': address,
      'username': username,
    };
  }
}