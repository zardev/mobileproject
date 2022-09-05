import 'package:flutter/cupertino.dart';

const Color kcPrimaryColor = Color(0xff22A45D);
const Color kcSecondaryColor = Color(0xff3d7cde);
const Color kcThirdColor = Color(0xffc92bb6);
const Color kcMediumGreyColor = Color(0xff868686);

List<Color> colorListByImportance = [
  kcPrimaryColor,
  kcSecondaryColor,
  kcThirdColor
];

const TextStyle ktsMediumGreyBodyText = TextStyle(
  color: kcMediumGreyColor,
  fontSize: kBodyTextSize,
);

const double kBodyTextSize = 16;