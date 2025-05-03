import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddAnnoProf extends StatefulWidget {
  const AddAnnoProf({Key? key}) : super(key: key);

  @override
  State<AddAnnoProf> createState() => _AddAnnoProfState();
}

class _AddAnnoProfState extends State<AddAnnoProf> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  final List<String> _typeOptions = ['Plombier', 'Maçon', 'Jardinier', 'Autre'];
  List<String> _selectedTypes = [];

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _images.add(image));
    }
  }

  void _showMultiSelectDialog() async {
    final List<String> tempSelected = List.from(_selectedTypes);
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Sélectionnez les professionnel'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _typeOptions.map((type) {
                return CheckboxListTile(
                  title: Text(type),
                  value: tempSelected.contains(type),
                  activeColor: Colors.deepPurple,
                  onChanged: (checked) {
                    setState(() {
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
              child: Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () {
                setState(() {
                  _selectedTypes = tempSelected;
                });
                Navigator.pop(ctx);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Annonce Professionnel'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.deepPurple.shade50,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration("Titre de l'annonce", Icons.title),
                  ),
                  SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Description', Icons.description),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  // Multi-select type
                  GestureDetector(
                    onTap: _showMultiSelectDialog,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: _inputDecoration('nos Professionnels', Icons.category),
                        controller: TextEditingController(
                          text: _selectedTypes.join(', '),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedTypes.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _selectedTypes.map((type) {
                        return Chip(
                          label: Text(type),
                          backgroundColor: Colors.deepPurple.shade100,
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedTypes.remove(type);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: _inputDecoration('Prix', Icons.attach_money),
                  ),
                  SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: _inputDecoration('Localisation', Icons.location_on),
                  ),
                  SizedBox(height: 16),

                  // Date
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: _inputDecoration('Date de création', Icons.calendar_today),
                  ),
                  SizedBox(height: 16),

                  // Images
                  Text('Images', style: Theme.of(context).textTheme.titleSmall),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._images.map((img) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(img.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.deepPurple),
                          ),
                          child: Icon(Icons.add_a_photo, color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Créer', style: TextStyle(fontSize: 16, color: Colors.white)),
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
