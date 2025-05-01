import 'dart:async';

import 'package:bricorasy/screens/sign_page/signup-form.dart';
import 'package:bricorasy/services/auth_services.dart';

import '../../theme/theme.dart';
import '../../widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class Doublesignscreen extends StatefulWidget {
  final String role;
  final String fullname;
  final String email;
  final String password;

  const Doublesignscreen({
    super.key,
    required this.role,
    required this.fullname,
    required this.email,
    required this.password,
  });

  @override
  _DoublesignscreenState createState() => _DoublesignscreenState();
}

class _DoublesignscreenState extends State<Doublesignscreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  Widget _otpTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
  }) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1, // Un seul caractère par champ
        obscureText: false, // Le texte ne sera pas masqué
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        focusNode: focusNode,
        onChanged: (value) {
          // Si un champ est rempli, on passe au suivant
          if (value.isNotEmpty && nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  int _secondsRemaining = 0;
  late Timer _timer;
  bool _isResendEnabled = true;

  // fonction pour renvoyé le code OTP
  Future<void> _resendOtp() async {
    if (_isResendEnabled) {
      bool otpSent = await AuthService.sendOtp(widget.email);

      if (otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP renvoyé avec succès')),
        );

        setState(() {
          _isResendEnabled = false;
          _secondsRemaining = 60;
        });

        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du renvoi de l\'OTP')),
        );
      }
    }
  }

  // fonction si le code il est renvoyé tu ne peut pas cliquer sur resend juste apres 1min
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 5)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 80.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Get Your Code',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Please enter the 4 digit code that\n',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: 'sent to your email address.',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 65.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _otpTextField(
                              controller: _controller1,
                              focusNode: _focusNode1,
                              nextFocusNode: _focusNode2,
                            ),
                            _otpTextField(
                              controller: _controller2,
                              focusNode: _focusNode2,
                              nextFocusNode: _focusNode3,
                            ),
                            _otpTextField(
                              controller: _controller3,
                              focusNode: _focusNode3,
                              nextFocusNode: _focusNode4,
                            ),
                            _otpTextField(
                              controller: _controller4,
                              focusNode: _focusNode4,
                              nextFocusNode: null,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'If you don\'t receive code?',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isResendEnabled) {
                              _resendOtp();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: lightColorScheme.primary,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40.0),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          String otp =
                              _controller1.text +
                              _controller2.text +
                              _controller3.text +
                              _controller4.text;

                          if (otp.length == 4) {
                            // Envoyer la vérification OTP au serveur
                            bool otpVerified = await AuthService.verifyOtp(
                              widget.email,
                              otp,
                            );

                            if (otpVerified) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Code OTP vérifié avec succès'),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => FormSignUp(
                                        role: widget.role,
                                        fullname: widget.fullname,
                                        email: widget.email,
                                        password: widget.password,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Code OTP incorrect. Veuillez réessayer.',
                                  ),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Veuillez entrer un code valide.',
                                ),
                              ),
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightColorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Verify and Proceed',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
