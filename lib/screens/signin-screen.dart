import 'package:bricorasy/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(child: Text("Sign In",style: TextStyle(color: Colors.white)));
  }
}
