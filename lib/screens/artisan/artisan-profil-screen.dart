import 'package:flutter/material.dart';
// Assuming these are custom widgets you've defined elsewhere
import '../../widgets/poste_custom.dart';
import '../../widgets/tarif_custom.dart';
// Import url_launcher if you implement call/message actions
// import 'package:url_launcher/url_launcher.dart';

// Define placeholder types for the toggle buttons
enum ProfileView { postes, avis }

class Artisanprofilscreen extends StatefulWidget {
  // Use final fields and ensure null safety
  final String username;
  final String job;
  final String loc;
  final String rating; // Consider using double or int
  final String like; // Consider using int
  final ImageProvider? imgProvider; // Use ImageProvider for flexibility

  const Artisanprofilscreen({
    super.key,
    this.username = "Nom d'Artisan", // Provide default values
    this.job = "Profession",
    this.loc = "Lieu",
    this.rating = "N/A",
    this.like = "0",
    this.imgProvider, // Make image optional
  });

  @override
  State<Artisanprofilscreen> createState() => _ArtisanprofilscreenState();
}

class _ArtisanprofilscreenState extends State<Artisanprofilscreen> {
  // Use the enum for the current view state
  ProfileView _currentView = ProfileView.postes;

  // --- Helper Widgets ---

  // Helper for Stat Items
  Widget _buildStatItem(BuildContext context, IconData icon, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  // --- Action Handlers (Placeholders) ---
  void _handleCall() {
    print("Call action triggered");
    // TODO: Implement call logic (e.g., using url_launcher)
  }

  void _handleMessage() {
    print("Message action triggered");
    // TODO: Implement message logic (e.g., navigate to chat screen or SMS)
  }

  void _handleMoreOptions() {
    print("More options triggered");
    // TODO: Implement bottom sheet logic from original code if needed
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Enregistrer'),
              onTap: () => Navigator.pop(context), // TODO: Implement Save
            ),
            ListTile(
              leading: const Icon(Icons.comment_outlined),
              title: const Text('Laisser un Avis'),
              onTap: () => Navigator.pop(context), // TODO: Implement Review
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Partager le profil'),
              onTap: () => Navigator.pop(context), // TODO: Implement Share
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.red),
              title: const Text('Signaler', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context), // TODO: Implement Report
            ),
             const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).cardColor;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: onSurfaceColor),
            onPressed: _handleMoreOptions,
            tooltip: 'Plus d\'options',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Profile Header ---
            Container(
              color: cardColor,
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: widget.imgProvider ??
                        const AssetImage('assets/images/profil.png'),
                    onBackgroundImageError: widget.imgProvider != null ? (dynamic exception, StackTrace? stackTrace) {
                       print("Error loading profile image: $exception");
                    } : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.job,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: onSurfaceVariantColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // --- Stats Row ---
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildStatItem(context, Icons.star_border_outlined, widget.rating)),
                        const VerticalDivider(width: 1, thickness: 1),
                        Expanded(child: _buildStatItem(context, Icons.location_on_outlined, widget.loc)),
                        const VerticalDivider(width: 1, thickness: 1),
                        Expanded(child: _buildStatItem(context, Icons.favorite_border_outlined, widget.like)),
                      ],
                    ),
                  ),
                   const SizedBox(height: 20),
                   // --- Action Buttons ---
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                     child: Row(
                       children: [
                         Expanded(
                           child: ElevatedButton.icon(
                             icon: const Icon(Icons.phone_outlined, size: 20),
                             label: const Text("Appeler"),
                             onPressed: _handleCall,
                             style: ElevatedButton.styleFrom(
                               backgroundColor: primaryColor,
                               foregroundColor: onPrimaryColor,
                               padding: const EdgeInsets.symmetric(vertical: 10),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                             ),
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: OutlinedButton.icon(
                             icon: const Icon(Icons.message_outlined, size: 20),
                             label: const Text("Message"),
                             onPressed: _handleMessage,
                             style: OutlinedButton.styleFrom(
                               foregroundColor: primaryColor,
                               side: BorderSide(color: primaryColor.withOpacity(0.5)),
                               padding: const EdgeInsets.symmetric(vertical: 10),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ), // End of Header Container

            // --- Content Area (Tarifs, Toggle, Posts/Avis) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    // --- Catalogue/Tarifs Section ---
                    Text(
                       "Catalogue / Tarifs",
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Assuming TarifCustom is styled appropriately
                    TarifCustom(title: 'Site Web', prix: '7000'),
                    TarifCustom(title: 'Réparation Fuite', prix: '3500'),
                    const SizedBox(height: 20),

                    // --- Toggle Buttons (Postes / Avis) ---
                    Center( // Center the segmented button
                      child: SegmentedButton<ProfileView>(
                        segments: const <ButtonSegment<ProfileView>>[
                          ButtonSegment<ProfileView>(
                              value: ProfileView.postes,
                              label: Text('Postes'),
                              icon: Icon(Icons.grid_view_outlined)),
                          ButtonSegment<ProfileView>(
                              value: ProfileView.avis,
                              label: Text('Avis'),
                              icon: Icon(Icons.reviews_outlined)),
                        ],
                        selected: <ProfileView>{_currentView},
                        onSelectionChanged: (Set<ProfileView> newSelection) {
                          setState(() {
                            _currentView = newSelection.first;
                          });
                        },
                        // --- Simplified Style using ButtonStyle ---
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return primaryColor; // Selected background
                            }
                            return cardColor; // Unselected background
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return onPrimaryColor; // Selected text/icon color
                            }
                            return primaryColor; // Unselected text/icon color
                          }),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                             RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                // Optional: Add a non-stateful border here
                                side: BorderSide(color: primaryColor.withOpacity(0.5))
                             )
                          ),
                        ),
                        // --- End Simplified Style ---
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Dynamic Content (Postes or Avis) ---
                    // Assuming PosteCustom is styled appropriately
                    if (_currentView == ProfileView.postes) ...[
                      // Example Postes - Replace with dynamic data later
                      PosteCustom(img: Image.asset('assets/images/E02.png'), aime: '30', comment: '23'),
                      const SizedBox(height: 12),
                      PosteCustom(aime: '30', comment: '40'),
                      const SizedBox(height: 12),
                      PosteCustom(img: Image.asset('assets/images/E02.png'), aime: '64', comment: '40'),
                      // Add more PosteCustom widgets or use ListView.builder if data is dynamic
                    ] else if (_currentView == ProfileView.avis) ...[
                      // Example Avis - Replace with dynamic data/review widget later
                      ListTile(leading: CircleAvatar(), title: Text("Avis 1"), subtitle: Text("Excellent travail!")),
                      Divider(),
                      ListTile(leading: CircleAvatar(), title: Text("Avis 2"), subtitle: Text("Très professionnel.")),
                      // Add more Avis widgets or use ListView.builder
                    ],
                 ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}