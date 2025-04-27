import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddAnnoOutil extends StatefulWidget {
  const AddAnnoOutil({super.key});

  @override
  State<AddAnnoOutil> createState() => _AddAnnoOutilState();
}

class _AddAnnoOutilState extends State<AddAnnoOutil> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _locationCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String? _selectedCategory;
  bool _submitting = false;

  final _picker = ImagePicker();
  List<XFile> _images = [];

  final List<String> _categories = [
    'Outil jardinage',
    'Outil construction',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (img != null) {
      setState(() => _images.add(img));
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_dateCtrl.text),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dateCtrl.text = picked.toIso8601String().split('T')[0]);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final uri = Uri.parse('http://10.0.2.2:8000/api/annonces/outil');
    final req =
        http.MultipartRequest('POST', uri)
          ..fields['localisation'] = _locationCtrl.text
          ..fields['titre'] = _titleCtrl.text
          ..fields['type_annonce'] = _selectedCategory!
          ..fields['prix'] = _priceCtrl.text
          ..fields['duree_location'] = _durationCtrl.text
          ..fields['description'] = _descriptionCtrl.text
          ..fields['date_creation'] = _dateCtrl.text;

    for (var img in _images) {
      req.files.add(await http.MultipartFile.fromPath('photo', img.path));
    }

    try {
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce créée avec succès!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Erreur serveur: ${res.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la soumission : ${e.toString()}')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location d'outils"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      labelText: "Localisation",
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: "Titre",
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                  ),
                  const SizedBox(height: 16),

                  // Category
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Catégorie",
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator:
                        (v) => v == null ? "Choisissez une catégorie" : null,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: "Prix (€)",
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                  ),
                  const SizedBox(height: 16),

                  // Duration
                  TextFormField(
                    controller: _durationCtrl,
                    decoration: const InputDecoration(
                      labelText: "Durée de location (jours)",
                      prefixIcon: Icon(Icons.timelapse),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Obligatoire" : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Date
                  TextFormField(
                    controller: _dateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date de création',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),

                  // Images
                  Text('Images', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var img in _images)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  _submitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Créer',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
