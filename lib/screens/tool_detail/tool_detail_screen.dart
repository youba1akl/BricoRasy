import 'dart:convert'; // For jsonEncode in report
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For reporting
import 'package:share_plus/share_plus.dart'; // For sharing
import 'package:url_launcher/url_launcher.dart'; // For dialing
import 'package:intl/intl.dart'; // For date formatting

import 'package:bricorasy/models/dummy_tool.dart'; // Your tool model
import 'package:bricorasy/services/auth_services.dart';
const String API_BASE_URL = "http://10.0.2.2:5000";

class ToolDetailScreen extends StatefulWidget {
  final DummyTool tool;

  const ToolDetailScreen({super.key, required this.tool});

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  // Launch phone dialer with the given number
  Future<void> _launchDialer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Impossible d’appeler : $phone')));
    }
  }

  /// Dial the tool-creator’s phone number
  void _callAction() {
    final phone = widget.tool.phone;
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone indisponible')),
      );
      return;
    }
    _launchDialer(phone);
  }

  // Placeholder messaging
  void _messageAction() {
    // TODO: Implement SMS logic if desired
  }

  // Send a report about this tool
  void sendReport(String message) async {
    final String annonceId = widget.tool.id;
    const String placeholderUserId = "user_abc";
    final String reportUrl = "$API_BASE_URL/api/reports";

    try {
      final response = await http.post(
        Uri.parse(reportUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "annonceId": annonceId,
          "userId": placeholderUserId,
          "annonceType": "outil",
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signalement envoyé avec succès"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'envoi (${response.statusCode})"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur réseau: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Share this tool via OS share sheet
  Future<void> _desactivateAction() async {
    final id = widget.tool.id;
    final url = Uri.parse('$API_BASE_URL/api/annonce/bricole/$id');

    try {
      final resp = await http.patch(
        url,
        headers: AuthService.authHeader, // ← attach JWT header
      );
      if (!mounted) return;

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce désactivée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pop(true); // return `true` to signal list to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la désactivation (${resp.statusCode})',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show report dialog
  void _showReportDialog() {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Signaler cet outil'),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  final message = messageController.text.trim();
                  if (message.isNotEmpty) {
                    sendReport(message);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Veuillez décrire le problème."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Envoyer'),
              ),
            ],
          ),
    );
  }

  // Bottom sheet for more options
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.orange,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _desactivateAction;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.red),
                  title: const Text(
                    'Signaler',
                    style: TextStyle(color: Colors.red),
                  ),
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

  // Builds a labeled info row
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final mutedTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: mutedTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: mutedTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Formats ISO date strings
  String _formatDate(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy', 'fr_FR').format(dt);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: onPrimaryColor),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.tool.id,
                child:
                    widget.tool.imagePath.isNotEmpty
                        ? Image.network(
                          widget.tool.imagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, prog) {
                            if (prog == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    prog.expectedTotalBytes != null
                                        ? prog.cumulativeBytesLoaded /
                                            prog.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder:
                              (ctx, err, stack) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                        )
                        : Container(color: Colors.grey[300]),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: onPrimaryColor),
                onPressed: _showMoreOptions,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tool.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.build_outlined,
                    widget.tool.typeAnnonce.isNotEmpty
                        ? widget.tool.typeAnnonce
                        : "Outil",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    widget.tool.localisation.isNotEmpty
                        ? widget.tool.localisation
                        : "Non spécifiée",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.calendar_month_outlined,
                    widget.tool.dureeLocation.isNotEmpty
                        ? "Durée: ${widget.tool.dureeLocation}"
                        : "Durée non spécifiée",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_outlined,
                    widget.tool.dateCreation.isNotEmpty
                        ? "Ajouté le: ${_formatDate(widget.tool.dateCreation)}"
                        : "Date inconnue",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.sell_outlined,
                    "${widget.tool.price.toStringAsFixed(2)} DA",
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text("Appeler"),
                          onPressed: _callAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: onPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.tool.description.isNotEmpty
                        ? widget.tool.description
                        : "Aucune description fournie.",
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
