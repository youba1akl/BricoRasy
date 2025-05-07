// lib/screens/profil_screen.dart
import 'package:bricorasy/screens/preference_screen.dart'; // <-- 1. ADD THIS IMPORT
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
    final String displayJob = widget.job ?? "Non spécifié"; // Not displayed if null by current logic
    final ImageProvider displayImage = widget.img?.image ?? AssetImage('assets/images/defaultprofil.png');
    // Make sure 'assets/images/defaultprofil.png' exists and is in pubspec.yaml

    return SafeArea(
      child: Scaffold(
        // Consider setting a scaffoldBackgroundColor from the theme
        // backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 250,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.light ? Color(0XFFF3F6F4) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)), // Themed background
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300], // Placeholder color if image fails
                        image: DecorationImage(
                          image: displayImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayUsername,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        // color: Theme.of(context).colorScheme.onSurface, // Use theme color
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.job != null && widget.job!.isNotEmpty) // Check if job is not null AND not empty
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          displayJob,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurfaceVariant, // Use theme color
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement navigation to create post screen
                        print("Creer un Poste tapped");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary, // Uses theme's primary color
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Créer un Poste',
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), // Use theme's onPrimary
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary, size: 20), // Use theme's onPrimary
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 240,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration( // Consider removing const if child boxShadow is not const
                  color: Theme.of(context).colorScheme.surface, // Use theme's surface color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.15), // Use theme's shadow color
                      blurRadius: 3.0,
                      spreadRadius: 1,
                      offset: Offset(0, -1), // Shadow upwards slightly
                    ),
                  ],
                ),
                child: ListView(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 20,
                    bottom: 15,
                  ),
                  children: [
                    _buildSectionTitle('Paramètres'),
                    _buildSettingsItem(Icons.settings, 'Préférences', () {
                      // VVVV --- 2. IMPLEMENTED NAVIGATION --- VVVV
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PreferencesScreen()),
                      );
                      print("Preferences tapped - navigating");
                      // ^^^^ --- IMPLEMENTATION END --- ^^^^
                    }),
                    _buildSettingsItem(Icons.account_box, 'Compte', () {
                      // TODO: Navigate to Account screen
                      print("Account tapped");
                    }),
                    _buildSettingsItem(Icons.bookmark_border, 'Listes Sauvegardées', () { // Changed icon for variety
                      // TODO: Navigate to Saved Lists screen
                      print("Saved List tapped");
                    }),
                    SizedBox(height: 10),
                    _buildSectionTitle('Ressources'),
                    _buildSettingsItem(Icons.menu_book_outlined, 'Catalogue', () { // Changed icon for variety
                      // TODO: Navigate to Catalogue screen
                      print("Catalogue tapped");
                    }),
                    _buildSettingsItem(Icons.help_outline, 'Support', () { // Changed icon
                      // TODO: Navigate to Support screen
                      print("Support tapped");
                    }),
                    SizedBox(height: 20), // More space before logout
                    _buildLogoutButton(() {
                      // TODO: Implement logout logic (e.g., clear user session, navigate to login)
                      print("Logout tapped");
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
      padding: const EdgeInsets.only(top: 10.0, bottom: 8.0), // Adjusted bottom padding
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Theme.of(context).colorScheme.onSurface, // Use theme color
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6), // Adjusted margin
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Adjusted padding
        decoration: BoxDecoration(
          // Using surfaceVariant or a slightly tinted background
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          // Original color: const Color(0XFFdae5f2),
          borderRadius: const BorderRadius.all(
            Radius.circular(12), // Slightly larger radius
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
            SizedBox(width: 15), // Increased spacing
            Expanded( // Allow text to take available space
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                  fontWeight: FontWeight.w500 // Slightly bolder
                ),
              ),
            ),
            // Spacer(), // Not needed if Text is Expanded
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Added horizontal margin
        padding: const EdgeInsets.all(14), // Adjusted padding
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error, // Use theme's error color
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.onError, // Use theme's onError color
            ),
            SizedBox(width: 10), // Increased spacing
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError, // Use theme's onError color
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}