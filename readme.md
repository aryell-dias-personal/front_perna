# Bem vindo ao FRONT_PERNA

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

```List myList = new ArrayList();``

ao invés de

```List<String> myList = new ArrayList<String>();```

no Java.