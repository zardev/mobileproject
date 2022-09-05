import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Widget horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = SizedBox(width: 10.0);
const Widget horizontalSpaceRegular = SizedBox(width: 18.0);
const Widget horizontalSpaceMedium = SizedBox(width: 25.0);
const Widget horizontalSpaceLarge = SizedBox(width: 50.0);

const Widget verticalSpaceTiny = SizedBox(height: 5.0);
const Widget verticalSpaceSmall = SizedBox(height: 10.0);
const Widget verticalSpaceRegular = SizedBox(height: 18.0);
const Widget verticalSpaceMedium = SizedBox(height: 25.0);
const Widget verticalSpaceLarge = SizedBox(height: 50.0);

BoxDecoration circleBoxDecoration(Color color) {
  return new BoxDecoration(
    color: color, //new Color.fromRGBO(255, 0, 0, 0.0),
    borderRadius: new BorderRadius.only(
      topLeft:  const  Radius.circular(30.0),
      topRight: const  Radius.circular(30.0),
      bottomRight: const  Radius.circular(30.0),
      bottomLeft: const  Radius.circular(30.0),
    ),
  );
}

// Screen Size helpers

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenWidthPercentage(BuildContext context, {double percentage = 1}) => screenWidth(context) * percentage;
double screenHeightPercentage(BuildContext context, {double percentage = 1}) => screenHeight(context) * percentage;

Text h1(String title, [Color textColor = Colors.black]) =>
    Text(title, style: TextStyle(fontSize: 24, color: textColor));
Text h2(String title, [Color textColor = Colors.black]) =>
    Text(title, style: TextStyle(fontSize: 20, color: textColor));
Text h3(String title, [Color textColor = Colors.black]) =>
    Text(title, style: TextStyle(fontSize: 16, color: textColor));

Divider titleDivider() => Divider(
  height: 5,
  thickness: 3,
  color: Colors.black87,
);

ActionSnackbar(BuildContext context, String content) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  duration: Duration(seconds: 1),
  content: Row(
    children: [
      Text(content),
      SizedBox(width: 10),
    ],
  ),
),
);

TextFormField AuthenticationFormField(TextEditingController controller, FocusNode focusNode, String text) {
  if(text != "Password") {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: text,
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  } else {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: text,
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}