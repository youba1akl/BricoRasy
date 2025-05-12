// lib/screens/home/tool_detail_screen.dart

import 'dart:convert'; // For jsonEncode in report
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For reporting
import 'package:share_plus/share_plus.dart'; // For sharing
import 'package:url_launcher/url_launcher.dart'; // For dialing
import 'package:intl/intl.dart'; // For date formatting

import 'package:bricorasy/models/dummy_tool.dart'; // Your tool model, must include creatorId
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/services/socket_service.dart';
import 'package:bricorasy/screens/personnel_page/chat-screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String API_BASE_URL = dotenv.env['API_BASE_URL']!;

class ToolDetailScreen extends StatefulWidget {
  final DummyTool tool;

  const ToolDetailScreen({super.key, required this.tool});

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  @override
  void initState() {
    super.initState();
    SocketService.init(); // initialise la connexion Socket.IO
  }

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

  /// Ouvre la conversation Socket.IO
  void _messageAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Chatscreen(
              username: widget.tool.name,
              annonceId: widget.tool.id,
              peerId: widget.tool.idc, // doit être présent dans DummyTool
              initialMessage: "",
            ),
      ),
    );
  }

  // Send a report about this tool
  void sendReport(String message) async {
    final String annonceId = widget.tool.id;
    final url = Uri.parse('$API_BASE_URL/api/reports');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "message": message,
        "annonceId": annonceId,
        "userId": AuthService.currentUserId,
        "annonceType": "outil",
      }),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode == 201
              ? "Signalement envoyé avec succès"
              : "Erreur lors de l'envoi (${response.statusCode})",
        ),
        backgroundColor: response.statusCode == 201 ? Colors.green : Colors.red,
      ),
    );
  }

  // Deactivate via PATCH
  Future<void> _desactivateAction() async {
    final id = widget.tool.id;
    final url = Uri.parse('$API_BASE_URL/api/annonce/outil/$id');

    try {
      final resp = await http.patch(url, headers: AuthService.authHeader);
      if (!mounted) return;

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce désactivée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
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
          (_) => AlertDialog(
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
                  final msg = messageController.text.trim();
                  if (msg.isNotEmpty) {
                    sendReport(msg);
                    Navigator.pop(context);
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
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.orange,
                  ),
                  title: const Text('Désactiver'),
                  onTap: () {
                    Navigator.pop(context);
                    _desactivateAction();
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
                    widget.tool.typeAnnonce,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    widget.tool.localisation,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.timer_outlined,
                    "Durée: ${widget.tool.dureeLocation}",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_outlined,
                    "Ajouté le: ${_formatDate(widget.tool.dateCreation)}",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.sell_outlined,
                    "${widget.tool.price.toStringAsFixed(2)} DA",
                  ),
                  const SizedBox(height: 24),
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
                  Text(widget.tool.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
