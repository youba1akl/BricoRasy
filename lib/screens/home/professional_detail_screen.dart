// lib/screens/home/professional_detail_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/services/socket_service.dart';
import 'package:bricorasy/screens/personnel_page/chat-screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String API_BASE_URL = dotenv.env['API_BASE_URL']!;

class ProfessionalDetailScreen extends StatefulWidget {
  final ProfessionalService service;

  const ProfessionalDetailScreen({super.key, required this.service});

  @override
  State<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  @override
  void initState() {
    super.initState();
    SocketService.init(); // initialisation de la connexion Socket.IO
  }

  Future<void> _launchDialer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Impossible d’appeler : $phone')));
    }
  }

  void _callAction() {
    final phone = widget.service.numtel ?? '';
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone indisponible')),
      );
      return;
    }
    _launchDialer(phone);
  }

  /// Ouvre l’écran de chat en temps réel via Socket.IO
  void _messageAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Chatscreen(
              username: widget.service.name, // titre ou nom pro
              annonceId: widget.service.id, // ID de l’annonce
              peerId:
                  widget
                      .service
                      .idc, // ID du créateur (à ajouter dans ProfessionalService)
              initialMessage: "je veux postuler",
            ),
      ),
    );
  }

  Future<void> _desactivateAction() async {
    final id = widget.service.id;
    final url = Uri.parse('$API_BASE_URL/api/annonce/professionnel/$id');

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

  void sendReport(String message) async {
    final annonceId = widget.service.id;
    final url = Uri.parse('$API_BASE_URL/api/reports');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'annonceId': annonceId,
        'userId': AuthService.currentUserId,
        'annonceType': 'professionnel',
      }),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resp.statusCode == 201
              ? 'Signalement envoyé avec succès'
              : 'Erreur lors de l\'envoi (${resp.statusCode})',
        ),
        backgroundColor: resp.statusCode == 201 ? Colors.green : Colors.red,
      ),
    );
  }

  void _showReportDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Signaler cette annonce'),
            content: TextField(
              controller: ctrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez le problème…',
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
                  final msg = ctrl.text.trim();
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

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

  Widget _buildInfoRow(IconData icon, String text) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: muted, height: 1.4)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('d MMM yyyy', 'fr_FR').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = widget.service;
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
                tag: svc.id,
                child:
                    svc.imagePath.startsWith('http')
                        ? Image.network(svc.imagePath, fit: BoxFit.cover)
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
                    svc.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.category_outlined,
                    svc.categories.join(' • '),
                  ),
                  _buildInfoRow(Icons.location_on_outlined, svc.localisation),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Publié le: ${_formatDate(svc.dateCreation)}',
                  ),
                  _buildInfoRow(
                    Icons.event_busy_outlined,
                    'Expire le: ${_formatDate(svc.dateExpiration)}',
                  ),
                  _buildInfoRow(
                    Icons.sell_outlined,
                    '${svc.prix.toString()} DA',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text('Appelez-moi'),
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
                          label: const Text('Postuler'),
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
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    svc.description ?? 'Aucune description fournie.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
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
