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
      id: parsedJson['id'] as String,
      cardNumber: parsedJson['cardNumber'] as String,
      expiryDate: parsedJson['expiryDate'] as String,
      cardHolderName: parsedJson['cardHolderName'] as String,
      cvvCode: parsedJson['cvvCode'] as String,
      brand: parsedJson['brand'] as String
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