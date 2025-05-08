import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:bricorasy/models/bricole_service.dart'; // Import your service model
import 'package:intl/intl.dart'; // Import for date formatting

// Define your base API URL (uses 10.0.2.2 for Android Emulator connecting to localhost)
const String API_BASE_URL = "http://127.0.0.1:5000";

class Bricolescreen extends StatefulWidget {
  final BricoleService service;

  const Bricolescreen({
    super.key,
    required this.service,
  });

  @override
  State<Bricolescreen> createState() => _BricolescreenState();
}

class _BricolescreenState extends State<Bricolescreen> {
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
    print('Calling provider for: ${widget.service.name}');
    // TODO: Implement actual phone call logic
  }

  void _messageAction() {
    print('Messaging provider for: ${widget.service.name}');
    // TODO: Implement actual messaging logic
  }

  // Send Report Function
  void sendReport(String message) async {
    final String annonceId = widget.service.id; // Use the actual ID from the model
    const String placeholderUserId = "user_abc"; // TODO: Replace with actual logged-in user ID

    final String reportUrl = "$API_BASE_URL/api/reports";

    try {
      final response = await http.post(
        Uri.parse(reportUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "annonceId": annonceId, // Use actual ID
          "userId": placeholderUserId,
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
        'Regarde ce service sur BricoRasy : ${widget.service.name} à ${widget.service.localisation}');
  }

  // Show Report Dialog
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController messageController = TextEditingController();
        return AlertDialog(
          title: const Text('Signaler cette annonce'),
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
                // Use service ID for unique tag
                tag: widget.service.id, // Changed tag to use ID
                // Use Image.network for URLs coming from the backend
                child: widget.service.imagePath.isNotEmpty
                    ? Image.network(
                        widget.service.imagePath, // Use imagePath from service object
                        fit: BoxFit.cover,
                        // Add loading and error builders for network images
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
                        child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
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
                  // --- Service Name ---
                  Text(
                    widget.service.name, // Correct: uses 'name' from model
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16.0),

                  // --- Info Section ---
                  _buildInfoRow(
                    context,
                    Icons.category_outlined,
                    // Correct: uses 'categories' from model
                    widget.service.categories.isNotEmpty ? widget.service.categories.join(" • ") : "Non spécifié",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    widget.service.localisation, // Correct: uses 'localisation'
                  ),
                   _buildInfoRow( // Display creation date instead of duration
                    context,
                    Icons.calendar_today_outlined,
                    "Publié le: ${_formatDate(widget.service.date_creation)}",
                  ),
                   _buildInfoRow( // Display expiration date
                    context,
                    Icons.event_busy_outlined,
                    "Expire le: ${_formatDate(widget.service.date_exp)}",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.sell_outlined,
                    // Correct: uses 'prix' from model
                    "${widget.service.prix.toStringAsFixed(2)} DA",
                  ),
                  const SizedBox(height: 24.0),

                  // --- Action Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text("Appelez-moi"),
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
                    // Model doesn't have description, add placeholder or fetch later
                    "Aucune description détaillée fournie pour ce service.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24.0),

                  // --- Provider Info Section (Placeholder) ---
                  // TODO: Add provider info

                  // --- Reviews Section (Placeholder) ---
                  // TODO: Add reviews
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}