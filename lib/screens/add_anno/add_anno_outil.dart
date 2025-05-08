import 'dart:convert'; // For error parsing
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
  final _durationCtrl = TextEditingController(); // Duration specific to tools
  final _descriptionCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(); // Creation date

  String? _selectedCategory;
  bool _submitting = false;

  final _picker = ImagePicker();
  final List<XFile> _images = [];

  final List<String> _categories = [
    'Outil jardinage',
    'Outil construction',
    'Électrique', // Added category
    'Manuel', // Added category
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateTime.now().toIso8601String().split('T')[0];
  }

   @override
  void dispose() {
    _locationCtrl.dispose();
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _descriptionCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (img != null) {
       if (_images.length < 5) { // Limit images
          setState(() => _images.add(img));
       } else {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Vous ne pouvez ajouter que 5 images maximum.'), backgroundColor: Colors.orange),
          );
       }
    }
  }

  // Using same date picker as other forms
  Future<void> _selectDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ctrl.text = picked.toIso8601String().split('T')[0];
      setState(() {});
    }
  }

  // --- Submit Form ---
  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
     if (_selectedCategory == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie.'), backgroundColor: Colors.orange),
      );
      return;
    }
     if (_images.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une image.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _submitting = true);

    // Use 127.0.0.1 as requested
    final uri = Uri.parse('http://10.0.2.2:5000/api/annonce/outil');
    final req = http.MultipartRequest('POST', uri)
      ..fields['localisation'] = _locationCtrl.text
      ..fields['titre'] = _titleCtrl.text
      ..fields['type_annonce'] = _selectedCategory!
      ..fields['prix'] = _priceCtrl.text.replaceAll(',', '.')
      ..fields['duree_location'] = _durationCtrl.text // Duration field
      ..fields['description'] = _descriptionCtrl.text
      ..fields['date_creation'] = _dateCtrl.text;
      // TODO: Add user ID

    for (var img in _images) {
      req.files.add(await http.MultipartFile.fromPath('photo', img.path));
    }

    try {
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce créée avec succès!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
         print("Submit Error: ${res.statusCode} ${res.body}");
         String errorMessage = 'Erreur lors de la création (${res.statusCode})';
         try {
            final body = jsonDecode(res.body);
            if (body['message'] != null) {
               errorMessage = body['message'];
            }
         } catch (_) {}
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
         );
      }
    } catch (e) {
       print("Submit Exception: ${e.toString()}");
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la connexion: ${e.toString()}')),
      );
    } finally {
       if (mounted) {
          setState(() => _submitting = false);
       }
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color cardColor = Theme.of(context).cardColor;

    // Reusable input decoration
    InputDecoration inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: onSurfaceVariantColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: cardColor.withAlpha(150),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ajouter un Outil"), // Updated title
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? cardColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location
              TextFormField(
                controller: _locationCtrl,
                decoration: inputDecoration("Localisation", Icons.location_on_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? "Localisation obligatoire" : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: inputDecoration("Nom de l'outil", Icons.title), // Adjusted label
                validator: (v) => v == null || v.trim().isEmpty ? "Nom obligatoire" : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: inputDecoration("Catégorie", Icons.category_outlined),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? "Choisissez une catégorie" : null,
                 dropdownColor: cardColor,
              ),
              const SizedBox(height: 18),

              // Price
              TextFormField(
                controller: _priceCtrl,
                decoration: inputDecoration("Prix de location (DA / jour)", Icons.local_offer_outlined), // Adjusted label
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Prix obligatoire';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Duration
              TextFormField(
                controller: _durationCtrl,
                decoration: inputDecoration("Durée max. location (jours)", Icons.timer_outlined), // Changed icon
                keyboardType: TextInputType.number,
                validator: (v) {
                   if (v == null || v.trim().isEmpty) return 'Durée obligatoire';
                   if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Durée invalide';
                   return null;
                }
              ),
              const SizedBox(height: 18),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                decoration: inputDecoration('Description (optionnel)', Icons.description_outlined),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              // Creation Date (Maybe not needed if backend sets it?)
              // If needed, uncomment:
              // TextFormField(
              //   controller: _dateCtrl,
              //   readOnly: true,
              //   decoration: inputDecoration('Date de création', Icons.calendar_today_outlined),
              //   onTap: () => _selectDate(_dateCtrl),
              // ),
              // const SizedBox(height: 24),

              // Images Section
              Text(
                'Ajouter des Images (max 5)',
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._images.map((img) => Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(img.path),
                              width: 80, height: 80, fit: BoxFit.cover,
                            ),
                          ),
                          InkWell(
                             onTap: () => setState(() => _images.remove(img)),
                             child: Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                   color: Colors.black.withOpacity(0.6),
                                   shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                             ),
                          )
                        ],
                      )),
                  if (_images.length < 5)
                    InkWell(
                       onTap: _pickImage,
                       borderRadius: BorderRadius.circular(8),
                       child: Container(
                         width: 80, height: 80,
                         decoration: BoxDecoration(
                           color: Colors.grey[200],
                           borderRadius: BorderRadius.circular(8),
                           border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid)
                         ),
                         child: Icon(Icons.add_a_photo_outlined, color: Colors.grey[700], size: 30),
                       ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Submit Button
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Ajouter l\'outil'), // Adjusted text
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}