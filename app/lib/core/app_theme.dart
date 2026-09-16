import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const accent = Color(0xfffe2c55);

  static ThemeData get dark => ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: Colors.black,
    textTheme: ThemeData.dark(
      useMaterial3: true,
    ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: Color(0xff181818),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xff242424)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xff111116),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
  );

  /// The reference uses white surfaces for inbox, balance and account menus.
  static ThemeData get light => ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: accent,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xfff1f1f2),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xffeeeeee)),
  );
}
