import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:bricorasy/models/bricole_service.dart';

const String API_BASE_URL = "http://10.0.2.2:5000";

class Bricolescreen extends StatefulWidget {
  final BricoleService service;

  const Bricolescreen({super.key, required this.service});

  @override
  State<Bricolescreen> createState() => _BricolescreenState();
}

class _BricolescreenState extends State<Bricolescreen> {
  // Dialer helper
  Future<void> _launchDialer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Impossible d’appeler : $phone')));
    }
  }

  // ── UPDATED CALL ACTION ─────────────────────────────────────
  /// Instead of using the annonce creator’s phone,
  /// we now dial the **logged-in user’s** number
  void _callAction() {
    final phone = widget.service.phone;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone indisponible')),
      );
      return;
    }
    _launchDialer(phone);
  }
  // ─────────────────────────────────────────────────────────────

  // Placeholder messaging
  void _messageAction() {
    // TODO: implement SMS logic
  }

  // Report sending
  void sendReport(String message) async {
    final String annonceId = widget.service.id;
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

  // Share
  void _shareAction() {
    Share.share(
      'Regarde ce service sur BricoRasy : '
      '${widget.service.name} à ${widget.service.localisation}',
    );
  }

  // Show report dialog
  void _showReportDialog() {
    TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Signaler cette annonce'),
            content: TextField(
              controller: messageController,
              maxLines: 4,
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

  // More options sheet
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
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

  // Info row builder
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Date formatter
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
    final primary = Theme.of(context).primaryColor;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primary,
            iconTheme: IconThemeData(color: onPrimary),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.service.id,
                child:
                    widget.service.imagePath.isNotEmpty
                        ? Image.network(
                          widget.service.imagePath,
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
                                child: const Icon(Icons.broken_image),
                              ),
                        )
                        : Container(color: Colors.grey[300]),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: onPrimary),
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
                    widget.service.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.category_outlined,
                    widget.service.categories.isNotEmpty
                        ? widget.service.categories.join(" • ")
                        : "Non spécifié",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    widget.service.localisation,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_outlined,
                    "Publié le: ${_formatDate(widget.service.date_creation)}",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.event_busy_outlined,
                    "Expire le: ${_formatDate(widget.service.date_exp)}",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.sell_outlined,
                    "${widget.service.prix.toStringAsFixed(2)} DA",
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text("Appelez-moi"),
                          onPressed: _callAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: onPrimary,
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
                  const Text(
                    "Aucune description détaillée fournie pour ce service.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
