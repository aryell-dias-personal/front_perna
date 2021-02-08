// remember, the functions used here should not be private
final String baseUrl = 'https://us-east1-perna-app.cloudfunctions.net/perna-app-dev-';
final String emailUserInfo = 'https://www.googleapis.com/auth/userinfo.email';

// Dado sensível
const String apiKey = 'AIzaSyCI3N12gg2CfJWVAyJ6BwFB8KnWIWhETfA';

final String encodedNamesSeparetor = '<{*_-_*}>';

enum MenuOption { logout, clear }
enum MarkerType { origin, destiny }