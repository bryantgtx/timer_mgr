import 'package:flutter/material.dart';
import 'package:timer_mgr/homepage/home_page.dart';

class TimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Timer Manager'),
    );
  }
}
