// lib/screens/artisan/edit_artisan_profile_screen.dart
import 'dart:io'; // For File
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/models/tarif_item.model.dart'; // <-- IMPORT TarifItem MODEL
import 'package:bricorasy/services/auth_services.dart'; // For current user access if needed for validation/defaults
// TODO: Create and import a service for updating user/artisan profiles
// This service would handle the API call to PUT /api/users/me/profile
// and potentially profile picture uploads.
// import 'package:bricorasy/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditArtisanProfileScreen extends StatefulWidget {
  final Artisan artisan;

  const EditArtisanProfileScreen({super.key, required this.artisan});

  @override
  State<EditArtisanProfileScreen> createState() => _EditArtisanProfileScreenState();
}

class _EditArtisanProfileScreenState extends State<EditArtisanProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullnameCtrl;
  late TextEditingController _jobCtrl;
  late TextEditingController _localisationCtrl;
  late TextEditingController _numTelCtrl;

  // State for tarifs
  late List<TarifItem> _tarifsData; // Holds the actual TarifItem data
  List<TextEditingController> _tarifServiceNameControllers = [];
  List<TextEditingController> _tarifPriceControllers = [];
  // To manage FormKeys for each tarif row for individual validation (optional but good)
  List<GlobalKey<FormState>> _tarifFormKeys = [];


  XFile? _pickedImageFile;
  String _currentImageUrl = ''; // Stores the initial image URL or path
  bool _isDeletingImage = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullnameCtrl = TextEditingController(text: widget.artisan.fullname);
    _jobCtrl = TextEditingController(text: widget.artisan.job);
    _localisationCtrl = TextEditingController(text: widget.artisan.localisation);
    _numTelCtrl = TextEditingController(text: widget.artisan.numTel);
    _currentImageUrl = widget.artisan.image;

    // Initialize tarifs from widget.artisan.tarifs (create deep copy for editing)
    _tarifsData = widget.artisan.tarifs.map((t) =>
      TarifItem(id: t.id, serviceName: t.serviceName, price: t.price)
    ).toList();
    _initializeTarifControllers();
  }

  void _initializeTarifControllers() {
    // Dispose old controllers before creating new ones to prevent leaks if re-initialized
    for (var ctrl in _tarifServiceNameControllers) { ctrl.dispose(); }
    for (var ctrl in _tarifPriceControllers) { ctrl.dispose(); }

    _tarifServiceNameControllers = _tarifsData.map((t) => TextEditingController(text: t.serviceName)).toList();
    _tarifPriceControllers = _tarifsData.map((t) => TextEditingController(text: t.price)).toList();
    _tarifFormKeys = _tarifsData.map((_) => GlobalKey<FormState>()).toList(); // One key per tarif row
  }

  @override
  void dispose() {
    _fullnameCtrl.dispose();
    _jobCtrl.dispose();
    _localisationCtrl.dispose();
    _numTelCtrl.dispose();
    for (var ctrl in _tarifServiceNameControllers) { ctrl.dispose(); }
    for (var ctrl in _tarifPriceControllers) { ctrl.dispose(); }
    super.dispose();
  }

  void _addTarifItem() {
    setState(() {
      // Add a new empty TarifItem and corresponding controllers/keys
      _tarifsData.add(TarifItem(serviceName: '', price: ''));
      _tarifServiceNameControllers.add(TextEditingController());
      _tarifPriceControllers.add(TextEditingController());
      _tarifFormKeys.add(GlobalKey<FormState>());
    });
  }

  void _removeTarifItem(int index) {
    setState(() {
      _tarifsData.removeAt(index);
      // Dispose and remove controllers and key for the removed item
      _tarifServiceNameControllers[index].dispose();
      _tarifPriceControllers[index].dispose();
      _tarifServiceNameControllers.removeAt(index);
      _tarifPriceControllers.removeAt(index);
      _tarifFormKeys.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1024, imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          _pickedImageFile = image;
          _isDeletingImage = false; // A new image selection overrides deletion intent
        });
      }
    } catch (e) {
      if (kDebugMode) print("Error picking image: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de sélection d'image: $e")));
    }
  }

  void _deleteImage() {
    if (!mounted) return;
    setState(() {
      _pickedImageFile = null; // Clear any newly picked file
      _currentImageUrl = '';    // Clear current image URL (visual feedback)
      _isDeletingImage = true;  // Flag that existing image should be deleted on save
    });
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez corriger les erreurs dans le formulaire."), backgroundColor: Colors.orange),
      );
      return;
    }

    // Update _tarifsData from controllers before creating the payload
    List<TarifItem> processedTarifs = [];
    for (int i = 0; i < _tarifsData.length; i++) {
      final serviceName = _tarifServiceNameControllers[i].text.trim();
      final price = _tarifPriceControllers[i].text.trim();
      // Include tarif if at least one field is filled, or both if stricter validation is needed
      if (serviceName.isNotEmpty || price.isNotEmpty) {
        processedTarifs.add(TarifItem(
          id: _tarifsData[i].id, // Preserve existing ID for updates
          serviceName: serviceName,
          price: price,
        ));
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    Map<String, dynamic> updatePayload = {
      'fullname': _fullnameCtrl.text.trim(),
      'job': _jobCtrl.text.trim(),
      'localisation': _localisationCtrl.text.trim(),
      'phone': _numTelCtrl.text.trim(), // Backend User model uses 'phone'
      'tarifs': processedTarifs.map((t) => t.toJson()).toList(),
    };

    // Signal to delete image if _isDeletingImage is true and no new image was picked
    if (_isDeletingImage && _pickedImageFile == null) {
      updatePayload['profilePicture'] = ''; // Backend interprets this as delete
      if (kDebugMode) print("EditArtisanProfile: Sending signal to delete profilePicture.");
    }
    // If _pickedImageFile is not null, it's passed directly to AuthService.updateMyProfile.
    // If neither deleting nor picking new, 'profilePicture' key is NOT sent in updatePayload,
    // so backend should keep the existing image unless explicitly told to change/delete.

    if (kDebugMode) {
      print("EditArtisanProfile: Calling AuthService.updateMyProfile.");
      print("Payload (text data): $updatePayload");
      if (_pickedImageFile != null) print("New Image File: ${_pickedImageFile!.name}");
    }

    LoggedInUser? updatedLoggedInUser;
    try {
      updatedLoggedInUser = await AuthService.updateMyProfile(
        updateData: updatePayload,
        profilePictureFile: _pickedImageFile, // Pass the XFile or null
      );

      if (!mounted) return;

      if (updatedLoggedInUser != null) {
        // Construct an Artisan object from the updated LoggedInUser to pass back.
        // This ensures the Artisan object reflects the latest data from the server.
        Artisan resultArtisan = Artisan(
          id: updatedLoggedInUser.id,
          fullname: updatedLoggedInUser.fullname,
          job: updatedLoggedInUser.job ?? widget.artisan.job, // Fallback to old if backend doesn't return it or it's null
          localisation: updatedLoggedInUser.localisation ?? widget.artisan.localisation,
          numTel: updatedLoggedInUser.phone, // LoggedInUser has 'phone'
          image: updatedLoggedInUser.profilePicture ?? (_isDeletingImage && _pickedImageFile == null ? '' : widget.artisan.image), // Reflect deletion or use new/old
          // Use tarifs directly from updatedLoggedInUser, assuming it's List<TarifItem>
          tarifs: updatedLoggedInUser.tarifs,
          rating: widget.artisan.rating, // Rating not edited on this screen
          like: widget.artisan.like,     // Likes not edited on this screen
        );

        if (kDebugMode) {
          print("EditArtisanProfile: Profile update successful. Popping with updated Artisan data.");
          print("Result Artisan Tarifs Count: ${resultArtisan.tarifs.length}");
          resultArtisan.tarifs.forEach((t) => print("  Tarif from result: ${t.serviceName} - ${t.price} (ID: ${t.id})"));
        }
        Navigator.pop(context, resultArtisan); // Pop and return updated Artisan data
      } else {
        // This case might be hit if updateMyProfile returns null without throwing an error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mise à jour du profil réussie, mais données utilisateur non retournées."), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) print("EditArtisanProfile: Error during _saveProfile API call - $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de la mise à jour du profil: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  Widget _buildImagePreview() {
    ImageProvider provider;
    if (_pickedImageFile != null) {
      provider = FileImage(File(_pickedImageFile!.path));
    } else if (_currentImageUrl.isNotEmpty && !_isDeletingImage) {
      if (_currentImageUrl.startsWith('http')) {
        provider = NetworkImage(_currentImageUrl);
      } else if (_currentImageUrl.startsWith('assets/')) {
        provider = AssetImage(_currentImageUrl);
      } else {
        provider = AssetImage('assets/images/$_currentImageUrl');
      }
    } else {
      provider = const AssetImage('assets/images/defaultprofil.png');
    }
    return CircleAvatar(
      radius: 60,
      backgroundImage: provider,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      onBackgroundImageError: _pickedImageFile == null && _currentImageUrl.isNotEmpty && !_isDeletingImage ? (dynamic error, StackTrace? stackTrace) {
        if (kDebugMode) print("Error loading current image in preview: $_currentImageUrl, $error");
        // Optionally update UI to show default if current image fails to load
      } : null,
    );
  }

  // Helper for input decoration
  InputDecoration _inputDecoration(String label, IconData icon, {EdgeInsets? contentPadding}) {
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
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier Mon Profil Artisan"),
        backgroundColor: colorScheme.surfaceContainerLow,
        actions: [
          IconButton(
            icon: _isSaving
                ? SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary))
                : const Icon(Icons.save_outlined),
            onPressed: _isSaving ? null : _saveProfile,
            tooltip: "Enregistrer",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text("Changer Photo"),
                          onPressed: _isSaving ? null : _pickImage,
                        ),
                        if ((_pickedImageFile != null || (_currentImageUrl.isNotEmpty && !_currentImageUrl.endsWith('defaultprofil.png'))) && !_isDeletingImage) ...[ // Show delete only if there's a custom image
                           const SizedBox(width: 10),
                           TextButton.icon(
                            icon: Icon(Icons.delete_outline, color: colorScheme.error),
                            label: Text("Supprimer Photo", style: TextStyle(color: colorScheme.error)),
                            onPressed: _isSaving ? null : _deleteImage,
                          ),
                        ]
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(controller: _fullnameCtrl, decoration: _inputDecoration("Nom Complet", Icons.person_outline), validator: (v) => v == null || v.trim().isEmpty ? "Nom complet obligatoire" : null),
              const SizedBox(height: 18),
              TextFormField(controller: _jobCtrl, decoration: _inputDecoration("Métier Principal", Icons.work_outline), validator: (v) => v == null || v.trim().isEmpty ? "Métier obligatoire" : null),
              const SizedBox(height: 18),
              TextFormField(controller: _localisationCtrl, decoration: _inputDecoration("Localisation (Ville, Quartier)", Icons.location_on_outlined), validator: (v) => v == null || v.trim().isEmpty ? "Localisation obligatoire" : null),
              const SizedBox(height: 18),
              TextFormField(controller: _numTelCtrl, decoration: _inputDecoration("Numéro de Téléphone", Icons.phone_outlined), keyboardType: TextInputType.phone, validator: (v) => v == null || v.trim().isEmpty ? "Numéro de téléphone obligatoire" : null),
              const SizedBox(height: 24),

              // --- Dynamic Tarifs Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mes Services / Tarifs", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: colorScheme.primary, size: 28), // Bigger add icon
                    tooltip: "Ajouter un service/tarif",
                    onPressed: _isSaving ? null : _addTarifItem,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_tarifsData.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text("Aucun tarif ajouté. Cliquez sur '+' pour en ajouter.", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                )),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tarifsData.length,
                itemBuilder: (context, index) {
                  // Using a Form with its own key for each row can allow individual validation,
                  // but for simplicity, we're validating all at once with the main form key.
                  // Individual keys (_tarifFormKeys[index]) are available if needed.
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 0, top: 4, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _tarifServiceNameControllers[index],
                              decoration: InputDecoration(
                                labelText: "Service ${index + 1}",
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                isDense: true,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? "Nom du service requis" : null,
                              // onChanged: (value) => _tarifsData[index].serviceName = value.trim(), // Update model as user types
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _tarifPriceControllers[index],
                              decoration: InputDecoration(
                                labelText: "Prix/Tranche",
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                isDense: true,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? "Prix requis" : null,
                              // onChanged: (value) => _tarifsData[index].price = value.trim(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: colorScheme.error.withOpacity(0.8)),
                            tooltip: "Supprimer ce tarif",
                            onPressed: _isSaving ? null : () => _removeTarifItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // --- End Dynamic Tarifs Section ---

              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: _isSaving
                    ? SizedBox(width:18, height:18, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                    : const Icon(Icons.save_alt_outlined),
                label: Text(_isSaving ? "Enregistrement..." : "Enregistrer les Modifications"),
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}