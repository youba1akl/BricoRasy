import 'package:flutter/material.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: TextField(
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.format_align_left_rounded), 
          hintText: "Search",
          border: OutlineInputBorder( 
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
