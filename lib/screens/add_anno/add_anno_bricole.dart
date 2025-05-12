import 'dart:io';
import 'dart:convert'; // For error parsing
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:bricorasy/services/auth_services.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
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
    // Prefill date
    _dateStartCtrl.text = DateTime.now().toIso8601String().split('T')[0];
    // Prefill phone & mail from logged-in user
    final user = AuthService.currentUser;
    if (user != null) {
      _phoneCtrl.text = user.phone;
      _mailCtrl.text = user.id;
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _dateStartCtrl.dispose();
    _dateEndCtrl.dispose();
    _mailCtrl.dispose();
    _phoneCtrl.dispose();
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
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (img != null) {
      if (_images.length < 5) {
        setState(() => _images.add(img));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous ne pouvez ajouter que 5 images maximum.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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

    final uri = Uri.parse('http://127.0.0.1:5000/api/annonce/bricole');
    final req =
        http.MultipartRequest('POST', uri)
          ..fields['localisation'] = _locationCtrl.text
          ..fields['titre'] = _titleCtrl.text
          ..fields['type_annonce'] = _selectedType!
          ..fields['prix'] = _priceCtrl.text.replaceAll(',', '.')
          ..fields['description'] = _descriptionCtrl.text
          ..fields['date_creation'] = _dateStartCtrl.text
          ..fields['date_expiration'] = _dateEndCtrl.text
          ..fields['phone'] = _phoneCtrl.text
          ..fields['idc'] = _mailCtrl.text
          ..headers.addAll(AuthService.authHeader);

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
        var errorMessage = 'Erreur lors de la création (${res.statusCode})';
        try {
          final body = jsonDecode(res.body);
          if (body['message'] != null) errorMessage = body['message'];
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Échec de la connexion: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final cardBg = Theme.of(context).cardColor;

    InputDecoration inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: onVariant.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                decoration: inputDecoration('Téléphone', Icons.phone_outlined),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Numéro obligatoire'
                            : null,
              ),
              const SizedBox(height: 18),
              // Email (invisible)
              Visibility(
                visible: false,
                maintainState: true, // conserve la valeur dans _mailCtrl
                maintainAnimation: true,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _mailCtrl,

                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Email obligatoire'
                                  : null,
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: inputDecoration(
                  'Type d\'annonce',
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
              const SizedBox(height: 24),
              Text(
                'Ajouter des images (max 5)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._images.map((img) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _images.remove(img)),
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  if (_images.length < 5)
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
