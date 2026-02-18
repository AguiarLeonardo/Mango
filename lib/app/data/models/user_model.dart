class UserModel {
  String? names;
  String? surnames;
  String? documentType;
  String? documentNumber;
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
  
  // NUEVO ATRIBUTO
  List<String> favorites; 

  UserModel({
    this.names,
    this.surnames,
    this.documentType = 'V-',
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
    this.favorites = const [], // Inicializado vacío por defecto
  });

  // Si tienes un fromMap o fromJson, agrégalo así:
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      names: map['names'],
      // ... tus otros campos ...
      favorites: List<String>.from(map['favorites'] ?? []), // Convierte el array de Supabase a List<String>
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'names': names,
      'surnames': surnames,
      'document_id': "$documentType$documentNumber", 
      'phone_prefix': phonePrefix,
      'phone_number': phoneNumber,
      'state': state,
      'city': city,
      // ... tus otros campos ...
      'favorites': favorites, // Lo enviamos a Supabase
    };
  }
}