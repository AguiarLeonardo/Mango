class BusinessModel {
  String commercialName;
  String shortDesc;
  String? category;
  String address;
  String phonePrefix;
  String phoneNumber;
  String legalName;
  String rif;
  String repName;
  bool acceptedTerms;
  String? rifImagePath; // Ruta de la foto del RIF

  BusinessModel({
    this.commercialName = '',
    this.shortDesc = '',
    this.category,
    this.address = '',
    this.phonePrefix = '0412',
    this.phoneNumber = '',
    this.legalName = '',
    this.rif = '',
    this.repName = '',
    this.acceptedTerms = false,
    this.rifImagePath,
  });
} 