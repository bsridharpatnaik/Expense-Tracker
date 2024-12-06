import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/screens/webview.dart';
import 'package:flutter/material.dart';
import '../handlers/http_request_handler.dart';
import 'dashboard/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool hidePass = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WebViewPage(),
          ),
        );
        return Future.value(false);
      },
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: Image.asset(
                      'assets/evergreen.png',
                    )),
                const Text(
                  ' Login',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                // Text(
                //   'Please register with registered account.',
                //   style: TextStyle(
                //       fontSize: 16,
                //       fontWeight: FontWeight.w800,
                //       color: Colors.grey.shade400
                //   ),
                // ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  ' Username',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_rounded),
                    hintText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  ' Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                TextField(
                  controller: passController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            hidePass = !hidePass;
                          });
                        },
                        child: Icon(hidePass
                            ? Icons.visibility
                            : Icons.visibility_off)),
                    hintText: 'Password',
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: hidePass,
                ),
                const SizedBox(
                  height: 25,
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        final username = userNameController.text;
                        final password = passController.text;
                        signIn(username, password);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Constants.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  signIn(String userName, String password) async {
    Map<String, dynamic> respJson =
        await HttpRequestHandler(context).signInRequest(userName, password);
    if (respJson['status'] == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (Route<dynamic> route) =>
            false, // Removes all previous routes from the stack
      );
    } else {
      print("Not Authorised");
    }
  }
}
