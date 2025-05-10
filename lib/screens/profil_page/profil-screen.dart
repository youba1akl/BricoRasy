// lib/screens/profil_screen.dart
import 'package:bricorasy/screens/preference_screen.dart';
import 'package:bricorasy/screens/profil_page/price_catalog_screen.dart';
import 'package:bricorasy/screens/profil_page/contact_developer_screen.dart';
import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart';
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/screens/sign_page/welcome-screen.dart'; // For logout navigation

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class Profilscreen extends StatefulWidget {
  final String? username; // For potentially showing a different user's profile (not primary use from nav bar)
  final String? job;      // For potentially showing a different user's profile
  final Image? img;      // For potentially showing a different user's profile

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
    if (AuthService.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez vous connecter d'abord.")),
        );
      }
      // TODO: Consider navigating to login screen if not automatically handled by app structure
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoadingMyArtisanProfile = true;
    });

    if (AuthService.currentUser!.isArtisan) {
      Artisan myArtisanProfile = Artisan(
        fullname: AuthService.currentUser!.fullname,
        job: AuthService.currentUser!.job ?? "Artisan",
        localisation: AuthService.currentUser!.localisation ?? "Localisation non spécifiée",
        numTel: AuthService.currentUser!.phone,
        rating: "N/A", // Placeholder - This data would come from aggregated reviews/ratings system
        image: AuthService.currentUser!.profilePicture ?? '', // Use profilePicture or empty string
        like: "0", // Placeholder - This data would come from an interaction system
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Artisanprofilscreen(
              artisan: myArtisanProfile,
              isMyProfile: true,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paramètres de compte généraux (À implémenter).")),
        );
        // TODO: Navigate to a general user settings screen for non-artisans
        // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => GeneralUserSettingsScreen()));
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingMyArtisanProfile = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    if (kDebugMode) {
      print("Profilscreen: Logout tapped");
    }
    await AuthService.logoutUser(context); // AuthService handles navigation
  }

  @override
  Widget build(BuildContext context) {
    // Determine display data: prioritize logged-in user, then widget props, then defaults
    final String displayUsername;
    final String displayJob;
    final ImageProvider displayImage;

    if (AuthService.currentUser != null) {
      displayUsername = AuthService.currentUser!.fullname;
      displayJob = (AuthService.currentUser!.isArtisan)
          ? (AuthService.currentUser!.job ?? "Artisan")
          : "Client"; // Or an empty string if you prefer not to show "Client"

      if (AuthService.currentUser!.profilePicture != null &&
          AuthService.currentUser!.profilePicture!.isNotEmpty) {
        if (AuthService.currentUser!.profilePicture!.startsWith('http')) {
          displayImage = NetworkImage(AuthService.currentUser!.profilePicture!);
        } else {
          // Assuming it's a full asset path or just a filename needing prefix
          displayImage = AssetImage(
              AuthService.currentUser!.profilePicture!.startsWith('assets/')
                  ? AuthService.currentUser!.profilePicture!
                  : 'assets/images/${AuthService.currentUser!.profilePicture!}'
          );
        }
      } else {
        displayImage = const AssetImage('assets/images/defaultprofil.png');
      }
    } else {
      // Fallback if no user is logged in (e.g., if this screen could be accessed before login, though unlikely for profile tab)
      displayUsername = widget.username ?? "Utilisateur";
      displayJob = widget.job ?? "Rôle non spécifié";
      displayImage = widget.img?.image ?? const AssetImage('assets/images/defaultprofil.png');
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned( // Top Profile Info Section
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 260,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20, bottom: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).colorScheme.surfaceContainerLow
                      : Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surfaceVariant,
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
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (displayJob.isNotEmpty && displayJob != "Client" && displayJob != "Rôle non spécifié")
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          displayJob,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (AuthService.isUserArtisan) // Use the getter from AuthService
                      GestureDetector(
                        onTap: () {
                          print("Creer un Poste tapped by artisan: ${AuthService.currentUser?.fullname}");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fonctionnalité 'Créer un Poste' à implémenter.")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Créer un Poste',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned( // Settings List Section
              top: 245, // Adjust if top section height changes
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                    // "Mon Compte" item with loading state
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoadingMyArtisanProfile ? null : _handleAccountTap,
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
                              _isLoadingMyArtisanProfile
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                      ),
                                    )
                                  : Icon(Icons.account_circle_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Mon Compte',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onTap,
      ),
    );
  }
}