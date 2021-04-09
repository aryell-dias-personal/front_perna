class BankAccount {
  BankAccount(
      {this.accountHolderName,
      this.accountHolderType,
      this.bankName,
      this.countryCode,
      this.email,
      this.currency,
      this.accountNumber,
      // NOTE: routing_number é `codigo do banco-agencia` no brasil (fora é só um número ou string)
      this.routingNumber});

  factory BankAccount.fromJson(Map<String, dynamic> parsedJson) {
    return BankAccount(
      accountHolderName: parsedJson['accountHolderName'] != null
          ? parsedJson['accountHolderName'] as String
          : null,
      accountHolderType: parsedJson['accountHolderType'] != null
          ? parsedJson['accountHolderType'] as String
          : null,
      bankName: parsedJson['bankName'] != null
          ? parsedJson['bankName'] as String
          : null,
      accountNumber: parsedJson['accountNumber'] != null
          ? parsedJson['accountNumber'] as String
          : null,
      countryCode: parsedJson['countryCode'] != null
          ? parsedJson['countryCode'] as String
          : null,
      email: parsedJson['email'] != null
          ? parsedJson['email'] as String
          : null,
      currency: parsedJson['currency'] != null
          ? parsedJson['currency'] as String
          : null,
      routingNumber: parsedJson['routingNumber'] != null
          ? parsedJson['routingNumber'] as String
          : null,
    );
  }

  String accountHolderName;
  String accountHolderType;
  String bankName;
  String accountNumber;
  String countryCode;
  String email;
  String currency;
  String routingNumber;

  BankAccount copyWith(
          {String accountHolderName,
          String accountHolderType,
          String bankName,
          String accountNumber,
          String countryCode,
          String email,
          String currency,
          String routingNumber}) =>
      BankAccount(
          accountHolderName: accountHolderName ?? this.accountHolderName,
          accountHolderType: accountHolderType ?? this.accountHolderType,
          bankName: bankName ?? this.bankName,
          accountNumber: accountNumber ?? this.accountNumber,
          countryCode: countryCode ?? this.countryCode,
          email: email ?? this.email,
          currency: currency ?? this.currency,
          routingNumber: routingNumber ?? this.routingNumber);

  dynamic toJson() => <String, dynamic>{
        'accountHolderName': accountHolderName,
        'accountHolderType': accountHolderType,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'countryCode': countryCode,
        'email': email,
        'currency': currency,
        'routingNumber': routingNumber,
      };
}
