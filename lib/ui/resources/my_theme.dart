import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  iconTheme: const IconThemeData(
    size: 30,
    color: AppColors.primary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  appBarTheme: AppBarTheme(
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 25,
    ),
    elevation: 0,
    toolbarHeight: 50.h,
    backgroundColor: AppColors.primary,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    bodySmall: GoogleFonts.novaFlat(
      fontSize: 12.sp,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.novaFlat(
      fontSize: 18.sp,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: GoogleFonts.novaSquare(
      fontSize: 22.sp,
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    ),
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
  appBarTheme: AppBarTheme(
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 25,
    ),
    color: AppColors.primary,
    elevation: 0,
    toolbarHeight: 50.h,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    bodySmall: GoogleFonts.novaFlat(
      fontSize: 12.sp,
      color: Colors.white,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: GoogleFonts.novaFlat(
      fontSize: 18.sp,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: GoogleFonts.novaSquare(
      fontSize: 22.sp,
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    ),
  ),
);
