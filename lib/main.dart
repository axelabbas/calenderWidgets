import 'package:calendarevents/ui/screens/calenderTimeline.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const timelineScreen(),
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData.dark(),
  ));
}
