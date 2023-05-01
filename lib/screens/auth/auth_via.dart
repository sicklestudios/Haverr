import 'package:flutter/material.dart';
import 'package:haverr/resources/colors.dart';
import 'package:haverr/screens/auth/phone_screen.dart';
import 'package:haverr/screens/login_screen.dart';
import 'package:haverr/screens/signup_screen.dart';

class AuthVia extends StatefulWidget {
  final bool isCreateAccount;
  const AuthVia({required this.isCreateAccount, super.key});

  @override
  State<AuthVia> createState() => _AuthViaState();
}

class _AuthViaState extends State<AuthVia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: mainColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PhoneAuthScreen(
                          isCreateAccount: widget.isCreateAccount)));
                },
                child: const Text("Phone")),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: mainColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => widget.isCreateAccount
                        ? const SignupScreen(
                            isPhoneNumber: false,
                          )
                        : const LoginScreen(),
                  ));
                },
                child: const Text("Email")),
          ),
        ]),
      ),
    );
  }
}
