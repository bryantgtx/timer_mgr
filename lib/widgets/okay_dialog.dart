import 'package:flutter/material.dart';
import 'package:timer_mgr/resources/strings.dart';

class OkayDialog extends StatelessWidget {
  final String title;
  final String content;

  OkayDialog(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(title),
      content: new Text(content),
      actions: <Widget>[
        new ElevatedButton(
          child: Text(Strings.okayDialogButton),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}