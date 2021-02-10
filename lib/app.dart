import 'package:flutter/material.dart';
import 'package:timer_mgr/homepage/home_page.dart';
import 'package:timer_mgr/oauth_creds.dart';

class TimerApp extends StatelessWidget {
  TimerApp(List<String> args) {
    if (args.length > 0) handleArgs(args);
  }
void handleArgs(List<String> args) {
  args.forEach((element) {
    var parts = element.split('=');
    if (parts.length > 1) {
      switch (parts[0]) {
        case 'harvestId':
          OAuthCredentials.args['harvestId'] = parts[1];
          break;
        case 'harvestSecret':
          OAuthCredentials.args['harvestSecret'] = parts[1];
          break;
      }
    }
  });
}
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
