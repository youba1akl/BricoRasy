import 'package:bricorasy/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      child: Text("Sign Up", style: TextStyle(color: Colors.white)),
    );
  }
}
