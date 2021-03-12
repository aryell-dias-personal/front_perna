import 'package:flutter/cupertino.dart';
import 'package:perna/constants/constants.dart';

class CardBrand extends StatelessWidget {
  const CardBrand({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 48,
        width: 48,
        child: brandToCardType.containsKey(brand)
            ? Image.asset(cardTypeIconAsset[brandToCardType[brand]]!,
                height: 48, width: 48)
            : const SizedBox());
  }
}
