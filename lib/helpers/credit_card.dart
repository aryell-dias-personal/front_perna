
import 'package:flutter/cupertino.dart';
import 'package:perna/constants/constants.dart';
import 'package:intl/intl.dart';

class MaskedTextController extends TextEditingController {
  MaskedTextController({
    String text, 
    this.mask, 
    Map<String, RegExp> translator
  }) : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      final String previous = _lastUpdatedText;
      if (beforeChange(previous, this.text)) {
        updateText(this.text);
        afterChange(previous, this.text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(this.text);
  }

  String mask;

  Map<String, RegExp> translator;

  void afterChange(String previous, String next) {}
  bool beforeChange(String previous, String next) => true;

  String _lastUpdatedText = '';

  void updateText(String text) {
    if (text != null) {
      this.text = _applyMask(mask, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    updateText(text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    final String text = _lastUpdatedText;
    selection = TextSelection.fromPosition(TextPosition(
      offset: (text ?? '').length
    ));
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return <String, RegExp>{
      'A': RegExp('[A-Za-z]'), 
      '0': RegExp('[0-9]'), 
      '@': RegExp('[A-Za-z0-9]'), 
      '*': RegExp('.*')
    };
  }

  // TODO: verificar esse cara  aqui
  String _applyMask(String mask, String value) {
    final StringBuffer resultBuffer = StringBuffer();

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      if (maskCharIndex == mask.length) {
        break;
      }

      if (valueCharIndex == value.length) {
        break;
      }

      final String maskChar = mask[maskCharIndex];
      final String valueChar = value[valueCharIndex];

      if (maskChar == valueChar) {
        resultBuffer.write(maskChar);
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      if (translator.containsKey(maskChar)) {
        if (translator[maskChar].hasMatch(valueChar)) {
          resultBuffer.write(valueChar);
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      resultBuffer.write(maskChar);
      maskCharIndex += 1;
      continue;
    }

    return resultBuffer.toString();
  }
}

CardType detectCCType(String cardNumber) {
  CardType cardType = CardType.otherBrand;

  if (cardNumber.isEmpty) {
    return cardType;
  }

  cardNumPatterns.forEach(
    (CardType type, Set<List<String>> patterns) {
      for (final List<String> patternRange in patterns) {
        String ccPatternStr = cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
        final int rangeLen = patternRange[0].length;
        if (rangeLen < cardNumber.length) {
          ccPatternStr = ccPatternStr.substring(0, rangeLen);
        }

        if (patternRange.length > 1) {
          final int ccPrefixAsInt = int.parse(ccPatternStr);
          final int startPatternPrefixAsInt = int.parse(patternRange[0]);
          final int endPatternPrefixAsInt = int.parse(patternRange[1]);
          if (ccPrefixAsInt >= startPatternPrefixAsInt 
            && ccPrefixAsInt <= endPatternPrefixAsInt
          ) {
            cardType = type;
            break;
          }
        } else {
          if (ccPatternStr == patternRange[0]) {
            cardType = type;
            break;
          }
        }
      }
    },
  );

  return cardType;
}

Widget getCardTypeIcon(String cardNumber, Function(bool, String) isAmexCallback) {
  Widget icon;
  final CardType cardType = detectCCType(cardNumber);
  if (cardType == CardType.otherBrand) {
    icon = const SizedBox(
      height: 48,
      width: 48,
    );
    isAmexCallback(false, '');
  } else {
    icon = Image.asset(
      cardTypeIconAsset[cardType],
      height: 48,
      width: 48
    );
    isAmexCallback(
      cardType == CardType.americanExpress, 
      cardTypeToBrand[cardType]
    );
  }
  return icon;
}

String formatAmount(int amount, String currency, Locale locale) {
  final String localeName = 
    '${locale.languageCode}_${locale.countryCode.toUpperCase()}';
  final NumberFormat format = NumberFormat.simpleCurrency(locale: localeName);
  return format.format(amount/100);
}