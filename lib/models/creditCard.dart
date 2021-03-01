class CreditCard {
  CreditCard({this.cardNumber, this.expiryDate, this.cardHolderName, this.cvvCode, this.isCvvFocused});

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String brand = '';
  bool isCvvFocused = false;
}