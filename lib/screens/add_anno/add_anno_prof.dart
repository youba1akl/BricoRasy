import 'dart:convert'; // For error parsing
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddAnnoProf extends StatefulWidget {
  const AddAnnoProf({Key? key}) : super(key: key);

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

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  final List<String> _typeOptions = ['Plombier', 'Maçon', 'Jardinier', 'Électricien', 'Peintre', 'Autre']; // Added more options
  List<String> _selectedTypes = [];

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  @override
  void dispose() {
    _locationController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _dateEndCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow slightly past start date
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ctrl.text = picked.toIso8601String().split('T')[0];
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
       if (_images.length < 5) { // Limit images
          setState(() => _images.add(image));
       } else {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Vous ne pouvez ajouter que 5 images maximum.'), backgroundColor: Colors.orange),
          );
       }
    }
  }

  // --- Multi-select Dialog ---
  void _showMultiSelectDialog() async {
    final List<String> tempSelected = List.from(_selectedTypes); // Copy current selection
    final Color primaryColor = Theme.of(context).primaryColor; // Get theme color

    await showDialog(
      context: context,
      builder: (ctx) {
        // Use StatefulBuilder to update checkboxes inside the dialog
        return StatefulBuilder(
           builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Sélectionnez le(s) métier(s)'),
                contentPadding: const EdgeInsets.only(top: 12.0, bottom: 0, left: 0, right: 0), // Adjust padding
                content: SizedBox( // Constrain height
                  width: double.maxFinite,
                  child: ListView( // Use ListView for scrolling if many options
                    shrinkWrap: true,
                    children: _typeOptions.map((type) {
                      return CheckboxListTile(
                        title: Text(type),
                        value: tempSelected.contains(type),
                        activeColor: primaryColor, // Use theme color
                        controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
                        onChanged: (checked) {
                          // Update the temporary list inside the dialog state
                          setDialogState(() { // Use setDialogState from StatefulBuilder
                            if (checked == true) {
                              tempSelected.add(type);
                            } else {
                              tempSelected.remove(type);
                            }
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Use theme color
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      // Update the main screen's state only when OK is pressed
                      setState(() {
                        _selectedTypes = tempSelected;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
           }
        );
      },
    );
  }

  // --- Submit Form ---
  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
     if (_selectedTypes.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir au moins un métier.'), backgroundColor: Colors.orange),
      );
      return;
    }
  /*   if (_images.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une image.'), backgroundColor: Colors.orange),
      );
      return;
    }*/

    setState(() => _submitting = true);

    // Use 127.0.0.1 as requested
    final uri = Uri.parse('http://10.0.2.2:5000/api/annonce/professionnel');
    final req = http.MultipartRequest('POST', uri)
      ..fields['localisation'] = _locationController.text
      ..fields['titre'] = _titleController.text // Changed 'name' to 'titre' to match others
      ..fields['type_annonce'] = _selectedTypes.join(',') // Send as comma-separated
      ..fields['prix'] = _priceController.text.replaceAll(',', '.')
      ..fields['description'] = _descriptionController.text
      ..fields['date_creation'] = _dateController.text
      ..fields['date_expiration'] = _dateEndCtrl.text;
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
          const SnackBar(content: Text('Annonce créée avec succès!'), backgroundColor: Colors.green)
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

    // Reusable input decoration matching the other form
    InputDecoration inputDecoration(String label, IconData icon, {bool isDense = false}) {
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
        contentPadding: EdgeInsets.symmetric(vertical: isDense ? 10.0 : 14.0, horizontal: 12.0), // Adjust padding
        isDense: isDense, // Make field vertically smaller if needed
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Annonce Professionnel'), // Keep original title
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
              // Title
              TextFormField(
                controller: _titleController,
                decoration: inputDecoration("Titre de l'annonce", Icons.title),
                validator: (v) => v == null || v.trim().isEmpty ? 'Titre obligatoire' : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: inputDecoration('Description (optionnel)', Icons.description_outlined),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),

              // Multi-select type Trigger Field
              GestureDetector(
                onTap: _showMultiSelectDialog,
                child: AbsorbPointer( // Prevents keyboard from showing
                  child: TextFormField(
                    // Use a controller to display selected items, or just placeholder text
                    controller: TextEditingController(text: _selectedTypes.isEmpty ? '' : _selectedTypes.join(', ')),
                    readOnly: true, // Make it read-only visually
                    decoration: inputDecoration(
                      _selectedTypes.isEmpty ? 'Choisir métier(s)' : 'Métier(s) sélectionné(s)', // Dynamic label
                      Icons.work_outline, // Business/Work icon
                    ),
                    validator: (v) => _selectedTypes.isEmpty ? 'Choisissez au moins un métier' : null,
                  ),
                ),
              ),
              // Display selected types as Chips below the field
              if (_selectedTypes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedTypes.map((type) {
                    return Chip(
                      label: Text(type, style: TextStyle(fontSize: 12, color: primaryColor)),
                      backgroundColor: primaryColor.withOpacity(0.15),
                      deleteIconColor: primaryColor.withOpacity(0.7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedTypes.remove(type);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 18),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: inputDecoration('Prix (DA) / Prestation', Icons.local_offer_outlined),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Prix obligatoire';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: inputDecoration('Localisation', Icons.location_on_outlined),
                 validator: (v) => v == null || v.trim().isEmpty ? 'Localisation obligatoire' : null,
                 textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // Date Fields Row
              Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Expanded(
                       child: TextFormField(
                         controller: _dateController,
                         readOnly: true,
                         decoration: inputDecoration('Date de création', Icons.calendar_today_outlined),
                         onTap: () => _selectDate(_dateController),
                       ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                       child: TextFormField(
                         controller: _dateEndCtrl,
                         readOnly: true,
                         decoration: inputDecoration('Date d\'expiration', Icons.event_busy_outlined),
                         onTap: () => _selectDate(_dateEndCtrl),
                         validator: (v) => v == null || v.isEmpty ? 'Date d\'expiration obligatoire' : null,
                       ),
                    ),
                 ],
              ),
              const SizedBox(height: 24),

              // Images Section (Copied from TaskFormScreen styling)
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
                      label: const Text('Créer l\'annonce'),
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