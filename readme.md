# Bem vindo ao FRONT_PERNA

[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
## Antes de rodar

- Garanta que o Firestore esteja ativo

- Garanta que o Authentication esteja ativo

> Nota: `googleAppID` é o `ID do aplicativo` no firestore

> Nota: `googleAppID` é o `ID do Número` do projeto

- Dê acesso a apiKey gerada pelo firebase a apis necessárias: *Token Service API*, *Directions API*, *Places API*, *Maps SDK for Android*, *Legacy Cloud Source Repositories API*, *Identity Toolkit API*, *Maps Static API*

- colocar key de `Chave de API da Web` em `apiKey` do FlavorConfig

- colocar key de `Chave de API da Web` em `app/src/main/AndroidManifest.xml`

> Nota: se você já tiver rodado e quiser trocar as credenciais lembre de rodar um `flutter clean` primeiro
## Gerencia de ambientes

para gerar/testar o app de um ambiente especifico mude o `FlavorConfig` no `main.dart` na pasta raiz.

Exemplo:

```dart
FlavorConfig(
    name: "DEVELOP",
    variables: {
        'paymentPublishableKey': 'pk_test_51IOaRiEHLjxuMcanAIUxWIvwpU90K6GWskTx0iGsHliV7LtxPKZBoBOfj1rfoRIzxt5Xp6EYw1ZFqTHwlnU6t1WL00VfoidTNJ',
        'appName': 'perna-app',
        'projectID': 'perna-app',
        'gcmSenderID': '172739913177',
        'baseUrl': 'https://us-east1-perna-app.cloudfunctions.net/perna-app-dev-',
        'apiKey': 'AIzaSyCI3N12gg2CfJWVAyJ6BwFB8KnWIWhETfA',
        'googleAppID': '1:172739913177:android:38f4c6eb4f67cb674b25c8',
        'merchantId': 'Test',
        'androidPayMode': 'test'
    },
);
```

## para gerar um apk assinado

- gere uma chave

```sh
PATH-TO-KEYTOOL -genkey -v -keystore release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
PATH-TO-KEYTOOL -exportcert -alias release -keystore PATH-TO-KEYSTORE -list -v
```

> PATH-TO-KEYTOOL normalmente é dentro da pasta jre do android studio

> gere em uma pasta que possua acesso a escrita

> se liga na AndroidDebugKey, gerada pelo android studio, ela precisa tar no firebase pra testar

para aryell, por exemplo:

PATH-TO-KEYTOOL= C:/Arquivos\ de\ Programas/Android/Android\ Studio/jre/bin/keytool.exe

PATH-TO-KEYSTORE= ~/release.keystore

- use do android studio e chave gerada para um buddle assinado;

- para verificar use:

```sh
./gradlew signingReport 
```

## Algumas observações:

- Não esquece que os icones são do https://www.flaticon.com/authors/smashicons e do https://www.flaticon.com/authors/freepik.
- uses unchecked or unsafe operations warnings durante a compilação são causados pelo uso de 

```List myList = new ArrayList();```

ao invés de

```List<String> myList = new ArrayList<String>();```

no Java.

- Pode ser importante no futuro atividades em background checa esse link:
> https://github.com/transistorsoft/flutter_background_geolocation/wiki/Android-Headless-Mode#flutter--112