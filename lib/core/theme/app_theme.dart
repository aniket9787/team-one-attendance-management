
import 'package:flutter/material.dart';

class AppColors {
static const primary = Color(0xFF2563EB);
static const secondary = Color(0xFF4F46E5);

static const background = Color(0xFFF8FAFC);

static const surface = Colors.white;

static const success = Color(0xFF16A34A);

static const warning = Color(0xFFF59E0B);

static const error = Color(0xFFDC2626);

static const textPrimary =
Color(0xFF111827);

static const textSecondary =
Color(0xFF6B7280);

static const border =
Color(0xFFE5E7EB);
}

class AppTheme {
static ThemeData get lightTheme {
final colorScheme =
ColorScheme.fromSeed(
seedColor: AppColors.primary,
brightness: Brightness.light,
);

return ThemeData(
useMaterial3: true,

colorScheme: colorScheme,

scaffoldBackgroundColor:
AppColors.background,

cardColor: AppColors.surface,

appBarTheme: const AppBarTheme(
centerTitle: false,
elevation: 0,
backgroundColor:
AppColors.surface,
surfaceTintColor:
AppColors.surface,
),

cardTheme: CardThemeData(
color: AppColors.surface,
elevation: 1,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
20,
),
),
),

inputDecorationTheme:
InputDecorationTheme(
filled: true,
fillColor: Colors.white,

border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
16,
),
borderSide:
BorderSide.none,
),

enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
16,
),
borderSide:
BorderSide.none,
),

focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
16,
),
borderSide:
const BorderSide(
color:
AppColors.primary,
),
),
),

elevatedButtonTheme:
ElevatedButtonThemeData(
style:
ElevatedButton.styleFrom(
backgroundColor:
AppColors.primary,
foregroundColor:
Colors.white,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
14,
),
),

minimumSize:
const Size(
double.infinity,
52,
),
),
),

textTheme:
const TextTheme(
headlineSmall: TextStyle(
fontWeight:
FontWeight.bold,
color:
AppColors.textPrimary,
),

titleLarge: TextStyle(
fontWeight:
FontWeight.w600,
color:
AppColors.textPrimary,
),

bodyLarge: TextStyle(
color:
AppColors.textPrimary,
),

bodyMedium: TextStyle(
color:
AppColors.textSecondary,
),
),
);
}
}
