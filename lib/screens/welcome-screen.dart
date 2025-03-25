import 'package:bricorasy/screens/signin-screen.dart';
import 'package:bricorasy/screens/signup-screen.dart';
import 'package:bricorasy/widgets/custom_scaffold.dart';
import 'package:bricorasy/widgets/welcome_button.dart';
import 'package:flutter/material.dart';

class Welcomescreen extends StatelessWidget {
  const Welcomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome Back!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text:
                            '\nEnter personnal details to your employee account',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign In',
                      onTap: Signinscreen(),
                      color: Colors.transparent,
                      colorText: Colors.white,
                    )
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign Up',
                      onTap: Signupscreen(),
                      color:Colors.white ,
                      colorText: Color(0xff335090),
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
