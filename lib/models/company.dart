class Company {
  Company(
      {this.employees,
      this.manager,
      this.bankAccountId,
      this.businessType,
      this.address,
      this.companyName,
      this.companyNumber,
      this.structure,
      this.phone,
      this.country,
      this.currency});

  factory Company.fromJson(Map<String, dynamic> parsedJson) {
    return Company(
      employees: parsedJson['employees']
          ?.map<String>((dynamic employee) => '$employee')
          ?.toList() as List<String>,
      manager: parsedJson['manager'] != null
          ? parsedJson['manager'] as String
          : null,
      businessType: parsedJson['businessType'] != null
          ? parsedJson['businessType'] as String
          : null,
      bankAccountId: parsedJson['bankAccountId'] != null
          ? parsedJson['bankAccountId'] as String
          : null,
      address: parsedJson['address'] != null
          ? parsedJson['address'] as String
          : null,
      structure: parsedJson['structure'] != null
          ? parsedJson['structure'] as String
          : null,
      companyName: parsedJson['companyName'] != null
          ? parsedJson['companyName'] as String
          : null,
      companyNumber: parsedJson['companyNumber'] != null
          ? parsedJson['companyNumber'] as String
          : null,
      phone: parsedJson['phone'] != null ? parsedJson['phone'] as String : null,
      country: parsedJson['country'] != null
          ? parsedJson['country'] as String
          : null,
      currency: parsedJson['currency'] != null
          ? parsedJson['currency'] as String
          : null,
    );
  }

  Company copyWith({
    List<String> employees,
    String manager,
    String bankAccountId,
    String businessType,
    String address,
    String companyName,
    String structure,
    String country,
    String companyNumber,
    String phone,
    String currency,
  }) =>
      Company(
          employees: employees ?? this.employees,
          manager: manager ?? this.manager,
          bankAccountId: bankAccountId ?? this.bankAccountId,
          businessType: businessType ?? this.businessType,
          address: address ?? this.address,
          companyName: companyName ?? this.companyName,
          structure: structure ?? this.structure,
          country: country ?? this.country,
          companyNumber: companyNumber ?? this.companyNumber,
          phone: phone ?? this.phone,
          currency: currency ?? this.currency);

  List<String> employees;
  String manager;
  String bankAccountId;
  String businessType;
  String address;
  String companyName;
  String structure;
  String country;
  String companyNumber;
  String phone;
  String currency;

  dynamic toJson() => <String, dynamic>{
        'employees': employees,
        'manager': manager,
        'bankAccountId': bankAccountId,
        'businessType': businessType,
        'address': address,
        'companyName': companyName,
        'structure': structure,
        'country': country,
        'companyNumber': companyNumber,
        'phone': phone,
        'currency': currency,
      };
}
