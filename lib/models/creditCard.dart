class CreditCard {
  CreditCard({
    this.id,
    this.cardNumber, 
    this.expiryDate, 
    this.cardHolderName, 
    this.cvvCode,
    this.brand,
    this.isCvvFocused
  });

  factory CreditCard.fromJson(Map<String, dynamic> parsedJson){
    return CreditCard(
      id: parsedJson['id'],
      cardNumber: parsedJson['cardNumber'],
      expiryDate: parsedJson['expiryDate'],
      cardHolderName: parsedJson['cardHolderName'],
      cvvCode: parsedJson['cvvCode'],
      brand: parsedJson['brand']
    );
  }

  String id = '';
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String brand = '';
  bool isCvvFocused = false;
}