import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/resources/text_style.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  iconTheme: const IconThemeData(
    size: 30,
    color: AppColors.primary,
  ),
  scaffoldBackgroundColor: Colors.white,
  primaryColor: AppColors.primary,
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 25,
    ),
    elevation: 0,
    toolbarHeight: 80,
    backgroundColor: AppColors.primary,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    bodySmall: novaFlat12BlackLight(),
    bodyMedium: novaFlat18WhiteLight(),
    bodyLarge: novaSquare22WhiteLight(),
  ),
);
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  iconTheme: const IconThemeData(
    size: 30,
    color: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.dark,
  primaryColorDark: AppColors.primary,
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 25,
    ),
    color: AppColors.primary,
    elevation: 0,
    toolbarHeight: 80,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    bodySmall: novaFlat12WhiteDark(),
    bodyMedium: novaFlat18WhiteDark(),
    bodyLarge: novaSquare22WhiteDark(),
  ),
);


