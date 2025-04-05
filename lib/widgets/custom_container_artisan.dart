import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart';
import 'package:flutter/material.dart';

class CustomContainerArtisan extends StatefulWidget {
  const CustomContainerArtisan({
    super.key,
    this.fullname,
    this.job,
    this.localisation,
  });
  final String? fullname;
  final String? job;
  final String? localisation;

  @override
  State<CustomContainerArtisan> createState() => _CustomContainerArtisanState();
}

String capitalizeWords(String text) {
  return text
      .split(' ')
      .map(
        (word) =>
            word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '',
      )
      .join(' ');
}

class _CustomContainerArtisanState extends State<CustomContainerArtisan> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.all(5),
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 1,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Artisanprofilscreen()),
          );
        },
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Color(0XFF335090),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white,
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'assets/images/exemple.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 17),
                    Text(
                      capitalizeWords(widget.fullname!),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          capitalizeWords(widget.job!),
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(' - ', style: TextStyle(color: Colors.white60)),
                        Text(
                          capitalizeWords(widget.localisation!),
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border, size: 28, color: Colors.white60),
                    const SizedBox(height: 4),
                    Text(
                      '4.5',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
