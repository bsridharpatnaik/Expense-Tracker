import 'package:flutter/material.dart';

import '../constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primary,
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            color: Constants.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child:
                    Image.asset(
                      'assets/evergreen.png',
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
