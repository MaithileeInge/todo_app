import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:todo_app/home.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
// import 'package:toast/toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'ohmLU2zR8fUbGssrHhkcH1jxzAGxf9KJEXOfJS0K';
  final keyClientKey = 'NjcyeIdjcLfSSuDvlkSAgrcLLXRZWpZ4uXHHpDQU';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(brightness: Brightness.dark, primaryColor: Colors.purple),
    );
  }
}
