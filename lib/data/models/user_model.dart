class UserModel {
  String names;
  String surnames;
  String email;
  String phonePrefix;
  String phoneNumber;
  String idType; // V- o E-
  String idNumber;
  String address;
  String? state;
  String? city;
  String? municipality;
  String username;
  String password;
  bool acceptedTerms;

  UserModel({
    this.names = '',
    this.surnames = '',
    this.email = '',
    this.phonePrefix = '0412',
    this.phoneNumber = '',
    this.idType = 'V-',
    this.idNumber = '',
    this.address = '',
    this.state,
    this.city,
    this.municipality,
    this.username = '',
    this.password = '',
    this.acceptedTerms = false,
  });
}