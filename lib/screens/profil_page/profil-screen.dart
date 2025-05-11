// lib/screens/profil_screen.dart
import 'package:bricorasy/screens/preference_screen.dart';
import 'package:bricorasy/screens/profil_page/price_catalog_screen.dart';
import 'package:bricorasy/screens/profil_page/contact_developer_screen.dart';
import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart';
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/services/artisan_services.dart'; // Ensure this is imported for api_artisan.fetchMyArtisanProfile
import 'package:bricorasy/screens/sign_page/welcome-screen.dart'; // For logout navigation
import 'package:bricorasy/screens/add_post_screen.dart'; // <-- IMPORT AddPostScreen

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class Profilscreen extends StatefulWidget {
  final String? username;
  final String? job;
  final ImageProvider? img; // Changed to ImageProvider

  const Profilscreen({
    super.key,
    this.username,
    this.job,
    this.img,
  });

  @override
  State<Profilscreen> createState() => _ProfilscreenState();
}

class _ProfilscreenState extends State<Profilscreen> {
  bool _isLoadingMyArtisanProfile = false;

  Future<void> _handleAccountTap() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez vous connecter d'abord.")),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoadingMyArtisanProfile = true;
    });

    Artisan? myArtisanProfile = await api_artisan.fetchMyArtisanProfile();

    if (!mounted) {
       _isLoadingMyArtisanProfile = false;
      return;
    }

    if (myArtisanProfile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Artisanprofilscreen(
            artisan: myArtisanProfile,
            isMyProfile: true,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paramètres de compte généraux (À implémenter). Vous n'êtes pas un artisan.")),
      );
      // TODO: Navigate to a general user settings screen
    }

    setState(() {
      _isLoadingMyArtisanProfile = false;
    });
  }

  Future<void> _handleLogout() async {
    if (kDebugMode) {
      print("Profilscreen: Logout tapped by ${AuthService.currentUser?.fullname ?? 'Guest'}");
    }
    await AuthService.logoutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final String displayUsername;
    final String displayJobInfo;
    final ImageProvider displayImage;
    final bool isUserCurrentlyArtisan = AuthService.isUserArtisan;

    if (AuthService.currentUser != null) {
      final currentUser = AuthService.currentUser!;
      displayUsername = currentUser.fullname;
      displayJobInfo = isUserCurrentlyArtisan
          ? (currentUser.job?.isNotEmpty == true ? currentUser.job! : "Artisan")
          : "Client";

      if (currentUser.profilePicture != null &&
          currentUser.profilePicture!.isNotEmpty) {
        if (currentUser.profilePicture!.startsWith('http')) {
          displayImage = NetworkImage(currentUser.profilePicture!);
        } else {
          displayImage = AssetImage(
              currentUser.profilePicture!.startsWith('assets/')
                  ? currentUser.profilePicture!
                  : 'assets/images/${currentUser.profilePicture!}'
          );
        }
      } else {
        displayImage = const AssetImage('assets/images/defaultprofil.png');
      }
    } else {
      displayUsername = widget.username ?? "Utilisateur";
      displayJobInfo = widget.job ?? "Non connecté";
      displayImage = widget.img ?? const AssetImage('assets/images/defaultprofil.png');
    }

    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 260,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20, bottom: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? colorScheme.surfaceContainerLow
                      : colorScheme.surfaceContainer,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceVariant,
                        image: DecorationImage(
                          image: displayImage,
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            if (kDebugMode) print("Error loading profile image in Profilscreen: $exception");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayUsername,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (displayJobInfo.isNotEmpty && displayJobInfo != "Client" && displayJobInfo != "Non connecté" && displayJobInfo != "Rôle non spécifié")
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          displayJobInfo,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (isUserCurrentlyArtisan)
                      GestureDetector(
                        onTap: () {
                           if (kDebugMode) print("Creer un Poste tapped by artisan: $displayUsername");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddPostScreen()),
                          ).then((value) {
                            if (value == true && mounted) {
                              if (kDebugMode) print("Profilscreen: Returned from AddPostScreen with success, consider refreshing posts.");
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Créer un Poste',
                                style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.add_circle_outline, color: colorScheme.onPrimary, size: 20),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 245,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
                  children: [
                    _buildSectionTitle('Paramètres'),
                    _buildSettingsItem(Icons.palette_outlined, 'Préférences', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesScreen()));
                    }),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoadingMyArtisanProfile ? null : _handleAccountTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              _isLoadingMyArtisanProfile
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                      ),
                                    )
                                  : Icon(Icons.account_circle_outlined, color: colorScheme.primary, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Mon Compte',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildSettingsItem(Icons.bookmark_border_outlined, 'Listes Sauvegardées', () {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Écran 'Listes Sauvegardées' à implémenter.")),
                        );
                    }),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Ressources'),
                    _buildSettingsItem(Icons.menu_book_outlined, 'Catalogue de Prix', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PriceCatalogScreen()));
                    }),
                    _buildSettingsItem(Icons.contact_support_outlined, 'Contacter le Support', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactDeveloperScreen()));
                    }),
                    const SizedBox(height: 24),
                    _buildLogoutButton(_handleLogout),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 10.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onError),
        label: Text(
          'Se déconnecter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: onTap,
      ),
    );
  }
}