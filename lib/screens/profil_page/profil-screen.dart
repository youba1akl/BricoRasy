// lib/screens/profil_screen.dart
import 'package:bricorasy/screens/preference_screen.dart';
import 'package:bricorasy/screens/profil_page/price_catalog_screen.dart';
import 'package:bricorasy/screens/profil_page/contact_developer_screen.dart';
import 'package:flutter/material.dart';

class Profilscreen extends StatefulWidget {
  const Profilscreen({super.key, this.username, this.job, this.img});

  final String? username;
  final String? job;
  final Image? img; // Consider using ImageProvider for more flexibility

  @override
  State<Profilscreen> createState() => _ProfilscreenState();
}

class _ProfilscreenState extends State<Profilscreen> {
  @override
  Widget build(BuildContext context) {
    final String displayUsername = widget.username ?? "Utilisateur";
    final String displayJob = widget.job ?? "Rôle non spécifié"; // Default if job is null
    final ImageProvider displayImage = widget.img?.image ?? AssetImage('assets/images/defaultprofil.png');

    return SafeArea(
      child: Scaffold(
        // backgroundColor: Theme.of(context).colorScheme.background, // Optional: explicitly set background
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 260, // Slightly increased height to accommodate potentially longer job titles or button
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20, bottom: 15), // Adjusted bottom padding
                decoration: BoxDecoration(
                  // Use a color from the theme that provides a subtle background
                  color: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).colorScheme.surfaceContainerLow // Material 3 light surface
                      : Theme.of(context).colorScheme.surfaceContainer, // Material 3 dark surface
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surfaceVariant, // Placeholder background
                        image: DecorationImage(
                          image: displayImage,
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // You could log the error or handle it if needed
                            print("Error loading profile image: $exception");
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
                    // Only display job if it's provided and not the default "Rôle non spécifié"
                    // or if you always want to show something, keep the default.
                    if (widget.job != null && widget.job!.isNotEmpty)
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
                    // This button's visibility might depend on user role (e.g., only for artisans)
                    // For now, it's always shown if you uncomment it.
                    // You'll need to add logic to conditionally show it.
                    // if (isArtisanUser) // Example condition
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement navigation to create post screen
                        print("Creer un Poste tapped");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Fonctionnalité 'Créer un Poste' à implémenter.")),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, // Increased padding
                          vertical: 10,  // Increased padding
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(25), // More rounded
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
            Positioned(
              top: 245, // Adjust based on the height of the top container (260 - some overlap)
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25), // Slightly larger radius
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 8.0, // Softer shadow
                      spreadRadius: 0,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: 16, // Consistent padding
                    right: 16,
                    top: 24, // More space at the top of the list
                    bottom: 16,
                  ),
                  children: [
                    _buildSectionTitle('Paramètres'),
                    _buildSettingsItem(Icons.palette_outlined, 'Préférences', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PreferencesScreen()),
                      );
                    }),
                    _buildSettingsItem(Icons.account_circle_outlined, 'Compte', () {
                      // TODO: Navigate to Account screen
                      print("Account tapped");
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Écran 'Compte' à implémenter.")),
                        );
                    }),
                    _buildSettingsItem(Icons.bookmark_border_outlined, 'Listes Sauvegardées', () {
                      // TODO: Navigate to Saved Lists screen
                      print("Saved List tapped");
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Écran 'Listes Sauvegardées' à implémenter.")),
                        );
                    }),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Ressources'),
                    _buildSettingsItem(Icons.menu_book_outlined, 'Catalogue de Prix', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PriceCatalogScreen()),
                      );
                    }),
                    _buildSettingsItem(Icons.contact_support_outlined, 'Contacter le Support', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactDeveloperScreen()),
                      );
                    }),
                    const SizedBox(height: 24),
                    _buildLogoutButton(() {
                      // TODO: Implement actual logout logic
                      // This should likely clear user session, navigate to login screen
                      print("Logout tapped");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Déconnexion à implémenter.")),
                      );
                      // Example: Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => WelcomeScreen()), (route) => false);
                    }),
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
      padding: const EdgeInsets.only(top: 12.0, bottom: 10.0, left: 4.0), // Added left padding
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600, // Slightly less bold than titleLarge
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Material( // Added Material for InkWell splash effect
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            // Use surfaceContainer for a subtle background, or keep transparent if Material provides enough visual cue
            color: Theme.of(context).colorScheme.surfaceContainerLowest, // Or surfaceContainerLow
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            // border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)) // Optional subtle border
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24), // Icon color as primary
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                       fontWeight: FontWeight.w500
                      ),
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
    return Padding( // Added padding to control button width via horizontal margin
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
          minimumSize: const Size(double.infinity, 50), // Make button take full available width in padding
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