import 'package:flutter/material.dart';

class TacheCustom extends StatelessWidget {
  const TacheCustom({super.key, this.title, this.detail});
  final String? title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0XFF335090),
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 0,
              offset: Offset(2, 1),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              detail!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
