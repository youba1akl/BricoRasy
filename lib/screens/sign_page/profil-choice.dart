import 'package:bricorasy/screens/sign_page/signup-screen.dart';
import 'package:bricorasy/theme/theme.dart';
import 'package:bricorasy/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class Profilchoice extends StatefulWidget {
  const Profilchoice({super.key});

  @override
  State<Profilchoice> createState() => _ProfilchoiceState();
}

class _ProfilchoiceState extends State<Profilchoice> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signupscreen(role: 'simple'),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: 180,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 10, right: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2.0,
                        spreadRadius: 0.5,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 70,
                        color: lightMode.primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Simpel User",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: lightMode.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signupscreen(role: 'artisan'),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: 180,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 5, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2.0,
                        spreadRadius: 0.5,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.engineering,
                        size: 70,
                        color: lightMode.primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Artisan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: lightMode.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
