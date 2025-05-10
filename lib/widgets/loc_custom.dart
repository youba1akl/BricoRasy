import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LocCustom extends StatefulWidget {
  const LocCustom({super.key});

  @override
  State<LocCustom> createState() => _LocCustomState();
}

class _LocCustomState extends State<LocCustom> {
  List<String> communes = [];
  final List<String> jobCategories = ['Plombier', 'Électricien', 'Peintre'];

  String? selectedCommune;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadCommunes();
  }

  Future<void> loadCommunes() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/bejaia.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> communeList = jsonData['communes'];

      setState(() {
        communes = communeList.cast<String>();
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Localisation & Job")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Afficher les communes après avoir chargé les données JSON
            if (communes.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Commune'),
                value: selectedCommune,
                items:
                    communes
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCommune = value;
                  });
                },
              ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Catégorie de job'),
              value: selectedCategory,
              items:
                  jobCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (selectedCommune != null && selectedCategory != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Commune: $selectedCommune, Job: $selectedCategory",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Veuillez remplir tous les champs"),
                    ),
                  );
                }
              },
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}
