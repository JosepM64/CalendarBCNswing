import 'package:flutter/material.dart';
import 'screens/events_screen.dart';

void main() {
  runApp(const BCNSwingApp());
}

class BCNSwingApp extends StatelessWidget {
  const BCNSwingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BCN Swing Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const EventsScreen(),
    );
  }
}
