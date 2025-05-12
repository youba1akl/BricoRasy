import 'dart:convert'; // For error parsing
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:bricorasy/services/auth_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddAnnoProf extends StatefulWidget {
  const AddAnnoProf({super.key});

  @override
  State<AddAnnoProf> createState() => _AddAnnoProfState();
}

class _AddAnnoProfState extends State<AddAnnoProf> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController(); // Creation date
  final _dateEndCtrl = TextEditingController(); // Expiration date
  final _mailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final List<String> _typeOptions = [
    'Plombier',
    'Maçon',
    'Jardinier',
    'Électricien',
    'Peintre',
    'Autre',
  ];
  List<String> _selectedTypes = [];

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Prefill dates
    _dateController.text = DateTime.now().toIso8601String().split('T')[0];
    // Prefill phone & email from logged-in user
    final user = AuthService.currentUser;
    if (user != null) {
      _phoneCtrl.text = user.phone;
      _mailCtrl.text = user.id;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
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
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null && _images.length < 5) {
      setState(() => _images.add(image));
    } else if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez ajouter que 5 images maximum.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showMultiSelectDialog() async {
    final temp = List<String>.from(_selectedTypes);
    final primary = Theme.of(context).primaryColor;
    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setStateDialog) => AlertDialog(
                  title: const Text('Sélectionnez le(s) métier(s)'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          _typeOptions.map((t) {
                            return CheckboxListTile(
                              title: Text(t),
                              value: temp.contains(t),
                              activeColor: primary,
                              onChanged: (chk) {
                                setStateDialog(() {
                                  if (chk! && !temp.contains(t)) temp.add(t);
                                  if (!chk) temp.remove(t);
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedTypes = temp);
                        Navigator.pop(ctx);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          ),
    );
  }

  final String apiBaseUrl = dotenv.env['API_BASE_URL']!;

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir au moins un métier.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final uri = Uri.parse('$apiBaseUrl/api/annonce/professionnel');
    final req =
        http.MultipartRequest('POST', uri)
          ..headers.addAll(AuthService.authHeader)
          ..fields['localisation'] = _locationController.text
          ..fields['titre'] = _titleController.text
          ..fields['type_annonce'] = _selectedTypes.join(',')
          ..fields['prix'] = _priceController.text.replaceAll(',', '.')
          ..fields['description'] = _descriptionController.text
          ..fields['date_creation'] = _dateController.text
          ..fields['date_expiration'] = _dateEndCtrl.text
          ..fields['idc'] = _mailCtrl.text
          ..fields['numtel'] = _phoneCtrl.text;

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
        var msg = 'Erreur (${res.statusCode})';
        try {
          final b = jsonDecode(res.body);
          if (b['message'] != null) msg = b['message'];
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
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
    final primary = Theme.of(context).primaryColor;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final card = Theme.of(context).cardColor;

    InputDecoration dec(String label, IconData icon, {bool dense = false}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: onVar.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        filled: true,
        fillColor: card.withAlpha(150),
        contentPadding: EdgeInsets.symmetric(
          vertical: dense ? 10 : 14,
          horizontal: 12,
        ),
        isDense: dense,
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Annonce Professionnel'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? card,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: dec("Titre de l'annonce", Icons.title),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Titre obligatoire'
                            : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              // Phone
              TextFormField(
                controller: _phoneCtrl,
                decoration: dec('Téléphone', Icons.phone),
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
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
                      decoration: dec('Email', Icons.email),
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

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: dec(
                  'Description (optionnel)',
                  Icons.description_outlined,
                  dense: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              // Types multi-select
              GestureDetector(
                onTap: _showMultiSelectDialog,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _selectedTypes.join(', '),
                    ),
                    decoration: dec(
                      _selectedTypes.isEmpty
                          ? 'Choisir métier(s)'
                          : 'Métier(s) sélectionné(s)',
                      Icons.work_outline,
                    ),
                    validator:
                        (_) =>
                            _selectedTypes.isEmpty
                                ? 'Choisissez au moins un métier'
                                : null,
                  ),
                ),
              ),
              if (_selectedTypes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                      _selectedTypes.map((t) {
                        return Chip(
                          label: Text(
                            t,
                            style: TextStyle(color: primary, fontSize: 12),
                          ),
                          backgroundColor: primary.withOpacity(0.15),
                          onDeleted:
                              () => setState(() => _selectedTypes.remove(t)),
                        );
                      }).toList(),
                ),
              ],
              const SizedBox(height: 18),

              // Prix
              TextFormField(
                controller: _priceController,
                decoration: dec('Prix (DA)', Icons.local_offer_outlined),
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

              // Localisation
              TextFormField(
                controller: _locationController,
                decoration: dec('Localisation', Icons.location_on_outlined),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Localisation obligatoire'
                            : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // Dates row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: dec(
                        'Date de création',
                        Icons.calendar_today_outlined,
                      ),
                      onTap: () => _selectDate(_dateController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dateEndCtrl,
                      readOnly: true,
                      decoration: dec(
                        'Date d\'expiration',
                        Icons.event_busy_outlined,
                      ),
                      onTap: () => _selectDate(_dateEndCtrl),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Date obligatoire'
                                  : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Images
              Text(
                'Ajouter des Images (max 5)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var img in _images)
                    Stack(
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
                        GestureDetector(
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
                    ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
