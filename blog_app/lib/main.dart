import 'package:flutter/material.dart';
import './message_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Blog',
      home: MessageListScreen(),
    );
  }
}
