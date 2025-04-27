import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class TaskFormScreen extends StatefulWidget {
  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _dateStartCtrl = TextEditingController();
  final _dateEndCtrl = TextEditingController();

  final _picker = ImagePicker();
  List<XFile> _images = [];

  bool _submitting = false;
  String? _selectedType;

  final List<String> _taskTypes = [
    'Jardinage',
    'Décoration',
    'Nettoyage',
    'Réparations',
    'Montage meubles',
    'Ménage',
    'Déménagement',
    'Transport',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _dateStartCtrl.text = DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ctrl.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (img != null) setState(() => _images.add(img));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final uri = Uri.parse('http://10.0.2.2:8000/api/annonces/bricole');
    final req =
        http.MultipartRequest('POST', uri)
          ..fields['localisation'] = _locationCtrl.text
          ..fields['titre'] = _titleCtrl.text
          ..fields['type_annonce'] = _selectedType!
          ..fields['prix'] = _priceCtrl.text
          ..fields['description'] = _descriptionCtrl.text
          ..fields['date_creation'] = _dateStartCtrl.text
          ..fields['date_expiration'] = _dateEndCtrl.text;

    for (var img in _images) {
      req.files.add(await http.MultipartFile.fromPath('photo', img.path));
    }

    try {
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Annonce créée avec succès!')));
        Navigator.pop(context);
      } else {
        throw Exception('Erreur: ${res.body}');
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
      appBar: AppBar(title: Text('Créer une annonce'), centerTitle: true),
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
                    decoration: InputDecoration(
                      labelText: 'Localisation',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                  ),
                  SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Titre',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                  ),
                  SizedBox(height: 16),

                  // Type
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _taskTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                    validator: (v) => v == null ? 'Choisissez un type' : null,
                  ),
                  SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceCtrl,
                    decoration: InputDecoration(
                      labelText: 'Prix (€)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                  ),
                  SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  // Creation Date
                  TextFormField(
                    controller: _dateStartCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date de création',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDate(_dateStartCtrl),
                  ),
                  SizedBox(height: 16),

                  // Expiration Date
                  TextFormField(
                    controller: _dateEndCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date d\'expiration',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _selectDate(_dateEndCtrl),
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                  ),
                  SizedBox(height: 16),

                  // Images
                  Text('Images', style: Theme.of(context).textTheme.titleSmall),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._images.map(
                        (img) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Submit
                  _submitting
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Créer', style: TextStyle(fontSize: 16)),
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
