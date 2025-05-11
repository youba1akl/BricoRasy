// lib/screens/add_post_screen.dart (NEW FILE)
import 'dart:io'; // For File
import 'package:bricorasy/services/post_service.dart'; // Your PostService
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bricorasy/services/auth_services.dart'; // For current user details

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _picker = ImagePicker();
  final List<XFile> _images = []; // To hold selected images

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill contact info from logged-in artisan if available
    final currentUser = AuthService.currentUser;
    if (currentUser != null && currentUser.isArtisan) {
      _phoneCtrl.text = currentUser.phone;
      _emailCtrl.text = currentUser.email;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous ne pouvez sélectionner que 5 images au maximum.')),
      );
      return;
    }
    try {
      // Pick multiple images
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        if ((_images.length + pickedFiles.length) <= 5) {
          setState(() {
            _images.addAll(pickedFiles);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Limite de 5 images atteinte. ${5 - _images.length} images restantes peuvent être ajoutées.')),
          );
          // Optionally add only up to the limit
          // final remainingSlots = 5 - _images.length;
          // setState(() {
          //   _images.addAll(pickedFiles.take(remainingSlots));
          // });
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error picking images: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des images: $e')),
      );
    }
  }

  void _removeImage(XFile image) {
    setState(() {
      _images.remove(image);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }
    // Optional: Check if at least one image is selected, if images are mandatory for a post
    // if (_images.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Veuillez ajouter au moins une image pour le poste.')),
    //   );
    //   return;
    // }


    setState(() => _isSubmitting = true);

    try {
      final createdPost = await PostService.createPost(
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        images: _images, // Pass the list of XFiles
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      if (createdPost != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poste créé avec succès!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Pop and indicate success (optional)
      } else {
        // This case might not be hit if PostService throws an exception on failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur inconnue lors de la création du poste.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la création du poste: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Helper for input decoration, similar to your add_anno_bricole
  InputDecoration _inputDecoration(String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest, // Material 3 fill
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un Nouveau Poste"),
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDecoration("Titre du Poste", Icons.title_rounded),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est obligatoire.';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: _inputDecoration("Description de votre travail/service", Icons.description_outlined),
                maxLines: 5,
                minLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est obligatoire.';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _phoneCtrl,
                decoration: _inputDecoration("Téléphone de contact (optionnel)", Icons.phone_outlined),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _emailCtrl,
                decoration: _inputDecoration("Email de contact (optionnel)", Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              Text(
                'Ajouter des Images (max 5)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._images.map((imageFile) => Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imageFile.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          InkWell(
                            onTap: () => _removeImage(imageFile),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                  if (_images.length < 5)
                    InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Icon(Icons.add_a_photo_outlined, size: 30, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.publish_outlined),
                      label: const Text('Publier le Poste'),
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}