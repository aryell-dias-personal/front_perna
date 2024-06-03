# Bem vindo ao FRONT_PERNA

[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
## Antes de rodar

- Não esqueça de baixar o `google-services.json`

- Garanta que o Firestore esteja ativo

- Garanta que o Authentication esteja ativo

> Nota: `googleAppID` é o `ID do aplicativo` no firestore

> Nota: `googleAppID` é o `ID do Número` do projeto

- Dê acesso a apiKey gerada pelo firebase a apis necessárias: *Token Service API*, *Directions API*, *Places API*, *Maps SDK for Android*, *Legacy Cloud Source Repositories API*, *Identity Toolkit API*, *Maps Static API*

- colocar key de `Chave de API da Web` em `apiKey` do FlavorConfig

- colocar key de `Chave de API da Web` em `local.properties` com nome `API_KEY`
> Nota: leia mais em https://entwicklernotizen.de/blog/how-to-handle-secret-api-keys-in-flutter-for-android-and-i-os/

> Nota: se você já tiver rodado e quiser trocar as credenciais lembre de rodar um `flutter clean` primeiro
## Gerencia de ambientes

para gerar/testar o app de um ambiente especifico mude o `FlavorConfig` no `main.dart` na pasta raiz.

Exemplo:

```dart
FlavorConfig(
    name: "DEVELOP",
    variables: {
        'paymentPublishableKey': '',
        'appName': '',
        'projectID': '',
        'gcmSenderID': '',
        'baseUrl': '',
        'apiKey': '',
        'googleAppID': '',
        'merchantId': '',
        'androidPayMode': ''
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

- Pode ser importante no futuro para fazer a bolha flutuante:
> https://github.com/KohlsAdrian/bubble_overlay
