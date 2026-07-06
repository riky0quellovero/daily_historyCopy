import'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      surface: Color.fromARGB(255, 253, 251, 243),  //background
      primary: Color.fromARGB(255, 253, 251, 243),  //background
      onPrimary: Colors.black,                      //text icons etc.
      secondary: Color.fromARGB(255, 253, 232, 208),//container background
      tertiary: Color.fromARGB(255, 173, 22, 37),   //highlighting, borders
      outline: Color.fromARGB(255, 169, 169, 169),  //background texts
      error: Color.fromARGB(255, 239, 68, 68),      //error color for text fields
      onSecondary: Color.fromARGB(255, 146, 140, 140), //dividers etc.
      onTertiary: Color.fromARGB(255, 127, 127, 127)   //others
    ),
);