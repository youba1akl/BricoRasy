import 'dart:io';
import 'dart:convert'; // For error parsing
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:bricorasy/services/auth_services.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

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
  final _mailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _picker = ImagePicker();
  final List<XFile> _images = [];

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

  @override
  void dispose() {
    _locationCtrl.dispose();
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _dateStartCtrl.dispose();
    _dateEndCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (img != null && _images.length < 5) {
      setState(() => _images.add(img));
    } else if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez ajouter que 5 images maximum.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir un type d\'annonce.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une image.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final uri = Uri.parse('http://10.0.2.2:5000/api/annonce/bricole');
    final req =
        http.MultipartRequest('POST', uri)
          ..fields['localisation'] = _locationCtrl.text
          ..fields['titre'] = _titleCtrl.text
          ..fields['type_annonce'] = _selectedType!
          ..fields['prix'] = _priceCtrl.text.replaceAll(',', '.')
          ..fields['description'] = _descriptionCtrl.text
          ..fields['date_creation'] = _dateStartCtrl.text
          ..fields['date_expiration'] = _dateEndCtrl.text
          ..fields['mail'] = _mailCtrl.text
          ..fields['phone'] = _phoneCtrl.text;

    for (var img in _images) {
      req.files.add(await http.MultipartFile.fromPath('photo', img.path));
    }

    try {
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce créée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la connexion: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color onSurfaceVariant =
        Theme.of(context).colorScheme.onSurfaceVariant;
    final Color cardBg = Theme.of(context).cardColor;

    InputDecoration inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: onSurfaceVariant.withOpacity(0.7)),
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
        fillColor: cardBg.withAlpha(150),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 12.0,
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('Créer une annonce Bricole'),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? cardBg,
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
                decoration: inputDecoration(
                  'Localisation',
                  Icons.location_on_outlined,
                ),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Localisation obligatoire'
                            : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: inputDecoration('Titre de l\'annonce', Icons.title),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Titre obligatoire'
                            : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _phoneCtrl,
                decoration: inputDecoration('phone', Icons.title),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'numero obligatoire'
                            : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _mailCtrl,
                decoration: inputDecoration('mail', Icons.title),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'mail obligatoire'
                            : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: inputDecoration(
                  'Type de service',
                  Icons.category_outlined,
                ),
                items:
                    _taskTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? 'Choisissez un type' : null,
                dropdownColor: cardBg,
              ),
              const SizedBox(height: 18),

              // Price
              TextFormField(
                controller: _priceCtrl,
                decoration: inputDecoration(
                  'Prix (DA)',
                  Icons.local_offer_outlined,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Prix obligatoire';
                  if (double.tryParse(v.replaceAll(',', '.')) == null)
                    return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                decoration: inputDecoration(
                  'Description (optionnel)',
                  Icons.description_outlined,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateStartCtrl,
                      readOnly: true,
                      decoration: inputDecoration(
                        'Date de création',
                        Icons.calendar_today_outlined,
                      ),
                      onTap: () => _selectDate(_dateStartCtrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dateEndCtrl,
                      readOnly: true,
                      decoration: inputDecoration(
                        'Date d\'expiration',
                        Icons.event_busy_outlined,
                      ),
                      onTap: () => _selectDate(_dateEndCtrl),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Date d\'expiration obligatoire'
                                  : null,
                    ),
                  ),
                ],
              ),

              // --- Images wrap ---
              const SizedBox(height: 24),
              Text(
                'Ajouter des images (max 5)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length < 5 ? _images.length + 1 : 5,
                  itemBuilder: (context, index) {
                    // "Add" button
                    if (index == _images.length && _images.length < 5) {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    // Preview image
                    final img = _images[index];
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(img.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap:
                                () => setState(() => _images.removeAt(index)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              // --- end images wrap ---

              // Submit button
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Créer l\'annonce'),
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
