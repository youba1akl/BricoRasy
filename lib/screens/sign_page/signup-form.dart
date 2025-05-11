import 'dart:convert';
import 'dart:io';
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/theme/theme.dart';
import 'package:bricorasy/widgets/custom_scaffold.dart';
import 'package:bricorasy/widgets2/home_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class FormSignUp extends StatefulWidget {
  final String role, fullname, email, password;
  const FormSignUp({
    super.key,
    required this.role,
    required this.fullname,
    required this.email,
    required this.password,
  });

  @override
  State<FormSignUp> createState() => _FormSignUpState();
}

class _FormSignUpState extends State<FormSignUp> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  // ignore: unused_field
  String _job = '', _phone = '';

  // Controllers dynamiques pour Catalogue
  final List<TextEditingController> _serviceControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _tarifControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _showProfileImageError = false;

  File? _profileImage;

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // gendre
  String? _gender;
  final List<String> _genderList = ['Homme', 'Femme'];

  // jobs
  List<String> _jobList = [];

  @override
  void initState() {
    super.initState();
    _loadJobs(); // Charger la liste des métiers depuis le fichier JSON
    _loadCommunes();
  }

  // Fonction pour charger les métiers depuis le fichier JSON
  Future<void> _loadJobs() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/jobs.json',
      );
      final data = json.decode(response); // Décoder le JSON
      setState(() {
        _jobList = List<String>.from(
          data['jobs'],
        ); // Extraire la liste des métiers
        if (_jobList.isNotEmpty) {
          _job =
              _jobList[0]; // Initialiser _job avec la première valeur si la liste n'est pas vide
        }
      });
    } catch (e) {
      print('Erreur lors du chargement des métiers: $e');
    }
  }

  List<String> _communesList = [];
  String? _selectedCommune;

  Future<void> _loadCommunes() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/bejaia.json',
      );
      final data = json.decode(response);

      setState(() {
        _communesList = List<String>.from(
          data['communes'],
        ); // si le JSON a une clé "communes"
        if (_communesList.isNotEmpty) {
          _selectedCommune = _communesList[0];
        }
      });
    } catch (e) {
      print('Erreur lors du chargement des communes: $e');
    }
  }

  // fonction pour sign up
  final AuthService _authService = AuthService();

  Future<void> _signupUser() async {
    setState(() => _isLoading = true);

    // 🔍 Étape 1 : Vérification des services si artisan
    if (widget.role == 'artisan') {
      for (int i = 0; i < 2; i++) {
        final name = _serviceControllers[i].text.trim();
        final price = _tarifControllers[i].text.trim();

        if (name.isEmpty || price.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez remplir les 2 services obligatoires.'),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }
    }

    // 📤 Étape 2 : Envoi des données vers le backend
    final result = await _authService.registerUser(
      fullname: widget.fullname,
      email: widget.email,
      password: widget.password,
      phone: _phone,
      role: widget.role,
      profilePicture: '', // à modifier plus tard si image
      job: widget.role == 'artisan' ? _job : '',
      localisation: _selectedCommune!,
      genre: _gender!,
      birthdate: _birthDate!.toIso8601String(),
      posts: [],
      services:
          widget.role == 'artisan'
              ? List.generate(
                2,
                (i) => {
                  'title': _serviceControllers[i].text.trim(),
                  'price':
                      double.tryParse(_tarifControllers[i].text.trim()) ?? 0.0,
                },
              )
              : [],
    );

    // ✅ Étape 3 : Traitement du résultat
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Compte créé avec succès')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScaffold()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : ${result['message']}')));
    }

    setState(() => _isLoading = false);
  }

  // ignore: unused_field
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isArtisan =
        widget.role == 'artisan'; // condition pour afficher les sections
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 5.0)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'File your information below or register\n',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              TextSpan(
                                text: 'with your social account',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 35.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                child:
                                    _profileImage == null
                                        ? const Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.black45,
                                        )
                                        : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_showProfileImageError)
                            const Text(
                              'Veuillez sélectionner une photo de profil',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          const SizedBox(height: 5),
                          const Text(
                            'Photo de profil',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fullname',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          TextFormField(
                            enabled: false, // rend le champ non modifiable
                            initialValue:
                                widget.fullname, // affiche le texte du fullname
                            style: const TextStyle(
                              color: Colors.black45,
                            ), // style du texte affiché
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: const TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          TextFormField(
                            enabled: false, // rend le champ non modifiable
                            initialValue:
                                widget.email, // affiche le texte du fullname
                            style: const TextStyle(
                              color: Colors.black45,
                            ), // style du texte affiché
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          TextFormField(
                            enabled: false, // rend le champ non modifiable
                            initialValue:
                                widget.password, // affiche le texte du fullname
                            style: const TextStyle(
                              color: Colors.black45,
                            ), // style du texte affiché
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: const TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'gendre',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          // Champ de sélection du genre avec DropdownButtonFormField
                          DropdownButtonFormField<String>(
                            value: _gender,
                            hint: Text('Choisir un genre'),
                            items:
                                _genderList.map((gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                            onSaved: (value) => _gender = value!,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ requis'
                                        : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintStyle: TextStyle(color: Colors.black26),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BirthDay',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          InkWell(
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1950),
                                lastDate: now,
                              );
                              if (picked != null) {
                                setState(() => _birthDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _birthDate == null
                                        ? 'Date de naissance'
                                        : 'Né(e) le : ${_birthDate!.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(
                                      color:
                                          _birthDate == null
                                              ? Colors.black26
                                              : Colors.black,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Localisation',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          // Champ de sélection du job avec DropdownButtonFormField
                          if (_communesList
                              .isNotEmpty) // Afficher le DropdownButtonFormField seulement si la liste n'est pas vide
                            DropdownButtonFormField<String>(
                              value: _selectedCommune,
                              hint: const Text('Choisir une commune'),
                              items:
                                  _communesList.map((commune) {
                                    return DropdownMenuItem<String>(
                                      value: commune,
                                      child: Text(commune),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCommune = value!;
                                });
                              },
                              onSaved: (value) => _selectedCommune = value!,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Champ requis'
                                          : null,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintStyle: TextStyle(color: Colors.black26),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Téléphone',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          // Numéro de téléphone
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Téléphone',
                              hintStyle: const TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            onSaved: (v) => _phone = v!.trim(),
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? 'Champ requis'
                                        : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      // Sections spécifiques aux artisans
                      if (isArtisan) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            // Champ de sélection du job avec DropdownButtonFormField
                            if (_jobList
                                .isNotEmpty) // Afficher le DropdownButtonFormField seulement si la liste n'est pas vide
                              DropdownButtonFormField<String>(
                                value: _job,
                                hint: Text('Choisir un métier'),
                                items:
                                    _jobList.map((job) {
                                      return DropdownMenuItem<String>(
                                        value: job,
                                        child: Text(job),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _job = value!;
                                  });
                                },
                                onSaved: (value) => _job = value!,
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Champ requis'
                                            : null,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintStyle: TextStyle(color: Colors.black26),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Catalogue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        for (
                          int i = 0;
                          i < _serviceControllers.length;
                          i++
                        ) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service ${i + 1}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              TextFormField(
                                controller: _serviceControllers[i],
                                decoration: InputDecoration(
                                  hintText: 'Nom du service',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v == null || v.isEmpty
                                            ? 'Champ requis'
                                            : null,
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: _tarifControllers[i],
                                decoration: InputDecoration(
                                  hintText: 'Tarif en DA',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v == null || v.isEmpty
                                            ? 'Champ requis'
                                            : null,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ],
                        TextButton.icon(
                          onPressed:
                              () => setState(() {
                                _serviceControllers.add(
                                  TextEditingController(),
                                );
                                _tarifControllers.add(TextEditingController());
                              }),
                          icon: const Icon(Icons.add, color: Color(0XFF416FDF)),
                          label: const Text(
                            'Ajouter un service',
                            style: TextStyle(color: Color(0XFF416FDF)),
                          ),
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                              BorderSide(
                                color:
                                    lightMode
                                        .primaryColor, // Couleur de la bordure
                                width: 1.0, // Épaisseur de la bordure
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ), // Rayon de bordure arrondie
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 25.0),
                      SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              // Appeler le backend
                              _signupUser();
                            } else {
                              setState(() {
                                _isLoading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter all your information and select a profile image.',
                                  ),
                                ),
                              );
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightColorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
