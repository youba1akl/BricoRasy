import 'dart:convert'; // For jsonEncode in report
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For report
import 'package:share_plus/share_plus.dart'; // For sharing
import 'package:bricorasy/models/dummy_tool.dart'; // Import your tool model
import 'package:intl/intl.dart'; // Import for date formatting

// Define your base API URL (uses 10.0.2.2 for Android Emulator connecting to localhost)
// Keep IP addresses as they are
const String API_BASE_URL = "http://10.0.2.2:5000";

class ToolDetailScreen extends StatefulWidget {
  final DummyTool tool; // Takes the tool object

  const ToolDetailScreen({
    super.key,
    required this.tool, // Constructor requires the tool object
  });

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  // Helper function to build info rows consistently
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final Color mutedTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: mutedTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: mutedTextColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to format dates nicely
  String _formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      // Example format: 25 déc. 2023 - Adjust 'fr_FR' and format as needed
      return DateFormat('d MMM yyyy', 'fr_FR').format(dateTime);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  // Placeholder function for button actions
  void _callAction() {
    print('Calling provider for tool: ${widget.tool.name}');
    // TODO: Implement actual phone call logic (needs provider contact info)
  }

  void _messageAction() {
    print('Messaging provider for tool: ${widget.tool.name}');
    // TODO: Implement actual messaging logic (needs provider contact info/chat screen)
  }

  // Send Report Function
  void sendReport(String message) async {
    final String annonceId = widget.tool.id; // Use the tool's ID
    const String placeholderUserId = "user_abc"; // TODO: Replace with actual logged-in user ID

    // Assuming the same report endpoint works for tools
    final String reportUrl = "$API_BASE_URL/api/reports";

    try {
      final response = await http.post(
        Uri.parse(reportUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "annonceId": annonceId, // Use tool ID
          "userId": placeholderUserId,
          "annonceType": "outil", // Optional: Add type if backend needs it
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Signalement envoyé avec succès"),
              backgroundColor: Colors.green),
        );
      } else {
        print('Report Error: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Erreur lors de l'envoi (${response.statusCode})"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Report Network Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur réseau: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  // Share Function
  void _shareAction() {
    Share.share(
        'Regarde cet outil sur BricoRasy : ${widget.tool.name} à ${widget.tool.localisation}');
  }

  // Show Report Dialog
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController messageController = TextEditingController();
        return AlertDialog(
          title: const Text('Signaler cet outil'), // Adjusted title
          content: TextField(
            controller: messageController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Décrivez le problème...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final message = messageController.text.trim();
                if (message.isNotEmpty) {
                  sendReport(message);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Veuillez décrire le problème."),
                        duration: Duration(seconds: 2)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  // Show More Options Bottom Sheet
  void _showMoreOptions() {
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
              leading: const Icon(Icons.share_outlined),
              title: const Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                _shareAction();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.red),
              title: const Text('Signaler', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final Color priceColor = Colors.deepOrange.shade700;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // --- Main Scaffold ---
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          // --- Sliver App Bar with Banner Image ---
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: onPrimaryColor),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              background: Hero(
                tag: widget.tool.id, // Use tool ID for unique tag
                child: widget.tool.imagePath.isNotEmpty
                    ? Image.network(
                        widget.tool.imagePath, // Use imagePath from tool object
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey[600]),
                        ),
                      )
                    : Container( // Placeholder if no image
                        color: Colors.grey[300],
                        child: Icon(Icons.construction, color: Colors.grey[600], size: 60), // Tool icon
                      ),
              ),
              stretchModes: const [StretchMode.zoomBackground],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: onPrimaryColor),
                onPressed: _showMoreOptions,
                tooltip: 'Plus d\'options',
              ),
            ],
          ),

          // --- Main Content Area ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Tool Name ---
                  Text(
                    widget.tool.name, // Use tool name
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16.0),

                  // --- Info Section ---
                   _buildInfoRow( // Display Type (Category)
                    context,
                    Icons.build_outlined, // Tool/Build icon
                    widget.tool.typeAnnonce.isNotEmpty ? widget.tool.typeAnnonce : "Outil", // Use typeAnnonce
                  ),
                  _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    widget.tool.localisation.isNotEmpty ? widget.tool.localisation : "Non spécifiée",
                  ),
                   _buildInfoRow( // Display Rental Duration
                    context,
                    Icons.calendar_month_outlined, // Calendar icon might be better
                    widget.tool.dureeLocation.isNotEmpty ? "Durée: ${widget.tool.dureeLocation}" : "Durée non spécifiée",
                  ),
                   _buildInfoRow( // Display creation date
                    context,
                    Icons.calendar_today_outlined,
                     widget.tool.dateCreation.isNotEmpty ? "Ajouté le: ${_formatDate(widget.tool.dateCreation)}" : "Date d'ajout inconnue",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.sell_outlined,
                    "${widget.tool.price.toStringAsFixed(2)} DA", // Use tool price
                  ),
                  const SizedBox(height: 24.0),

                  // --- Action Buttons ---
                  // Keep these if users contact the tool owner directly
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text("Appeler"), // Changed text slightly
                          onPressed: _callAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: onPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.message_outlined),
                          label: const Text("Message"),
                          onPressed: _messageAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                             textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // --- Description Section ---
                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.tool.description.isNotEmpty ? widget.tool.description : "Aucune description fournie.", // Use tool description
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24.0),

                  // --- Provider Info Section (Placeholder) ---
                  // TODO: Add provider info if tools are linked to users

                  // --- Reviews Section (Placeholder) ---
                  // TODO: Add reviews if applicable to tools
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}