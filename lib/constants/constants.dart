const int maxCardNumber = 10;
const String emailUserInfo = 'https://www.googleapis.com/auth/userinfo.email';
const String encodedNamesSeparetor = '<{*_-_*}>';

enum CardType {
  otherBrand,
  mastercard,
  visa,
  americanExpress,
  discover,
}

const Map<CardType, String> cardTypeToBrand = <CardType, String>{
  CardType.visa: 'Visa',
  CardType.americanExpress: 'American Express',
  CardType.mastercard: 'MasterCard',
  CardType.discover: 'Discover',
};

const Map<String, CardType> brandToCardType = <String, CardType>{
  'Visa': CardType.visa,
  'American Express': CardType.americanExpress,
  'MasterCard': CardType.mastercard,
  'Discover': CardType.discover,
};

const Map<CardType, String> cardTypeIconAsset = <CardType, String>{
  CardType.visa: 'icons/visa.png',
  CardType.americanExpress: 'icons/amex.png',
  CardType.mastercard: 'icons/mastercard.png',
  CardType.discover: 'icons/discover.png',
};

Map<CardType, Set<List<String>>> cardNumPatterns =
    <CardType, Set<List<String>>>{
  CardType.visa: <List<String>>{
    <String>['4'],
  },
  CardType.americanExpress: <List<String>>{
    <String>['34'],
    <String>['37'],
  },
  CardType.discover: <List<String>>{
    <String>['6011'],
    <String>['622126', '622925'],
    <String>['644', '649'],
    <String>['65']
  },
  CardType.mastercard: <List<String>>{
    <String>['51', '55'],
    <String>['2221', '2229'],
    <String>['223', '229'],
    <String>['23', '26'],
    <String>['270', '271'],
    <String>['2720'],
  },
};

enum MenuOption { logout, clear }
enum MarkerType { origin, destiny }

String defaultLanguageCode = 'en';
String defaultCountryCode = 'US';
String defaultCurrencyName = 'US';