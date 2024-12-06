import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:expense_tracker/screens/spashscreen.dart';
import 'package:expense_tracker/screens/webview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver(), // Existing observer
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 2), () {
      initApplication();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }

  initApplication() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => WebViewPage()));
  }

}
