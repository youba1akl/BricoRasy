import 'package:flutter/material.dart';
// Assuming these custom widgets exist and are styled according to the theme
import '../../widgets/message_custom.dart';
import '../../widgets/poste_custom.dart';
// TODO: Import widget for displaying Annonces if different from PosteCustom

// Define enum for view states
enum ActivityView { messages, postes, annonces }

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  ActivityView _currentView = ActivityView.messages; // Default view
  String userRole = 'artisan'; // Change to 'client' or get from auth state

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).cardColor;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    // Define segments based on user role
    final List<ButtonSegment<ActivityView>> segments = [
      const ButtonSegment<ActivityView>(
          value: ActivityView.messages,
          label: Text('Messages'),
          icon: Icon(Icons.message_outlined)),
      // Conditionally add Postes segment
      if (userRole == 'artisan')
        const ButtonSegment<ActivityView>(
            value: ActivityView.postes,
            label: Text('Postes'),
            icon: Icon(Icons.grid_view_outlined)), // Or Icons.article_outlined
      const ButtonSegment<ActivityView>(
          value: ActivityView.annonces,
          label: Text('Annonces'),
          icon: Icon(Icons.list_alt_outlined)), // Or Icons.campaign_outlined
    ];

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mon Activité'), // Updated title
        // No leading back button assuming this is a main tab screen
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? cardColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 1.0,
        centerTitle: true,
      ),
      body: Column( // Use Column for layout
        children: [
          // --- Toggle Buttons (SegmentedButton) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SegmentedButton<ActivityView>(
              segments: segments, // Use dynamically generated segments
              selected: <ActivityView>{_currentView},
              onSelectionChanged: (Set<ActivityView> newSelection) {
                setState(() {
                  // Ensure selection doesn't become empty if single select behavior is desired
                  if (newSelection.isNotEmpty) {
                     _currentView = newSelection.first;
                  }
                });
              },
              // Apply consistent styling from previous examples
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return primaryColor.withOpacity(0.85); // Slightly adjusted opacity maybe
                  }
                  return cardColor.withOpacity(0.5); // Lighter background for unselected
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return onPrimaryColor;
                  }
                  return onSurfaceColor.withOpacity(0.7); // Slightly muted unselected text
                }),
                shape: WidgetStateProperty.all<OutlinedBorder>(
                   RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: primaryColor.withOpacity(0.3)) // Subtle border
                   )
                ),
                // Adjust padding if needed
                // padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                //   const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                // ),
              ),
            ),
          ),

          // --- Dynamic Content Area ---
          Expanded(
            child: _buildCurrentViewContent(), // Helper method for content
          ),
        ],
      ),
    );
  }

  // --- Helper to build content based on selected view ---
  Widget _buildCurrentViewContent() {
    // Add padding around the list content
    const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

    switch (_currentView) {
      case ActivityView.messages:
        return ListView( // Replace with ListView.builder for dynamic data
          padding: listPadding,
          children: const [
            // TODO: Replace with actual message data & ensure MessageCustom is styled
            MessageCustom(
              // img: Image.asset('assets/images/exemple.png'), // Pass ImageProvider if needed
              username: 'Aklil Youba',
              lastmssg: 'nouveaux messages',
            ),
            SizedBox(height: 10),
            MessageCustom(
              username: 'Tahar Bensalem',
              lastmssg: 'Ok, merci!',
            ),
             SizedBox(height: 10),
             MessageCustom(
              username: 'Amira Bouzid',
              lastmssg: 'Vous êtes disponible demain?',
            ),
            // Add more messages...
          ],
        );

      case ActivityView.postes:
        // This case is only reachable if userRole == 'artisan'
        return ListView( // Replace with ListView.builder for dynamic data
           padding: listPadding,
          children: const [
            // TODO: Replace with actual post data & ensure PosteCustom is styled
            PosteCustom(
              // img: Image.asset('assets/images/E02.png'), // Pass ImageProvider if needed
              aime: '30',
              comment: '40',
            ),
             SizedBox(height: 12),
            PosteCustom(
              // img: Image.asset('assets/images/E03.png'),
              aime: '55',
              comment: '12',
            ),
            // Add more postes...
          ],
        );

      case ActivityView.annonces:
        return ListView( // Replace with ListView.builder for dynamic data
           padding: listPadding,
          children: const [
            // TODO: Replace with actual annonce data & use appropriate widget (maybe PosteCustom or a new one)
            PosteCustom( // Using PosteCustom as placeholder
              // img: Image.asset('assets/images/E01.png'),
              aime: '15', // Maybe represent views or saves?
              comment: 'Bricole', // Maybe represent category?
            ),
             SizedBox(height: 12),
            PosteCustom(
              // img: Image.asset('assets/images/E04.png'),
              aime: '42',
              comment: 'Outil',
            ),
            // Add more annonces...
          ],
        );
    }
  }
}