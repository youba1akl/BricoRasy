// lib/widgets/tarif_custom.dart
import 'package:flutter/material.dart';

class TarifCustom extends StatelessWidget {
  const TarifCustom({super.key, this.title, this.prix});
  final String? title;
  final String? prix;

  @override
  Widget build(BuildContext context) {
    // REMOVE Flexible from here
    return Container( // Container is now the root
      decoration: BoxDecoration(
        color: Color(0XFFE6E6E6), // Consider using themed colors
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        boxShadow: [ /* ... */ ],
      ),
      margin: EdgeInsets.symmetric(vertical: 5), // horizontal: 0 is default
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Use Expanded for Text if it can be long
            child: Text(
              title ?? "Service",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8), // Add spacing
          Row(
            children: [
              Text(
                prix ?? "N/A",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Text(
                ' DA', // Added space before DA
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}