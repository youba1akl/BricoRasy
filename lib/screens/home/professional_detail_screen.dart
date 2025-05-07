// lib/screens/home/professional_detail_screen.dart
import 'dart:convert'; // For jsonEncode in sendReport
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For sendReport
import 'package:share_plus/share_plus.dart';
import 'package:bricorasy/models/professional_service.dart'; // Your model
import 'package:bricorasy/services/professional_api_service.dart'; // Your API service
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Define your API_BASE_URL, ideally in a separate config file and imported
// This is used by sendReport. ProfessionalApiService already has its own.
const String API_BASE_URL_FOR_REPORTS = "http://127.0.0.1:5000";

class ProfessionalDetailScreen extends StatefulWidget {
  final String serviceId; // Changed to accept serviceId

  const ProfessionalDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ProfessionalDetailScreen> createState() => _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  final ProfessionalApiService _apiService = ProfessionalApiService();
  ProfessionalService? _service; // Make it nullable
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final fetchedService = await _apiService.fetchProfessionalServiceById(widget.serviceId);
      if (!mounted) return;
      setState(() {
        _service = fetchedService;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print('Error in _fetchServiceDetails: $e');
      setState(() {
        _error = "Impossible de charger les détails: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, {bool isPrice = false}) {
    if (_service == null) return const SizedBox.shrink();
    final Color mutedTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    // Don't show row if text is empty, unless it's price (which might be 0.00 DA)
    if (text.isEmpty && !isPrice) return const SizedBox.shrink();
    // Special check for price: don't show if price is exactly 0.0 and the text is "0.00 DA"
    // (assuming _service.prix is available when isPrice is true)
    if (isPrice && _service!.prix == 0.0 && text == "0.00 DA") return const SizedBox.shrink();

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

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return "Non spécifiée";
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy', 'fr_FR').format(dateTime); // Ensure 'fr_FR' locale is initialized if needed
    } catch (e) {
      return dateString; // Fallback to original string if parsing fails
    }
  }

  Future<void> _callAction() async {
    if (_service == null || _service!.numtel == null || _service!.numtel!.trim().isEmpty) {
      print("Phone number is missing for service ID: ${widget.serviceId}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Numéro de téléphone non disponible.")),
        );
      }
      return;
    }

    final String sanitizedPhoneNumber = _service!.numtel!.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: sanitizedPhoneNumber);

    if (await canLaunchUrl(launchUri)) {
      try {
        await launchUrl(launchUri);
      } catch (e) {
        print("Error launching phone dialer: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Impossible de lancer l'appel: $e"), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      print('Could not launch ${launchUri.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible de lancer l'application téléphone.")),
        );
      }
    }
  }

  void _messageAction() {
    if (_service == null) return;
    print('Messaging professional: ${_service!.name}');
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fonctionnalité de message non implémentée.")));
  }

  void sendReport(String message) async {
    if (_service == null) return;
    final String annonceId = _service!.id;
    const String placeholderUserId = "user_abc123"; // TODO: Replace with actual logged-in user ID from your auth system

    final String reportUrl = "$API_BASE_URL_FOR_REPORTS/api/reports"; // Ensure this endpoint is correct

    try {
       final response = await http.post(
        Uri.parse(reportUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "annonceId": annonceId,
          "userId": placeholderUserId,
          "annonceType": "professionnel" // Optional: Backend might use this to categorize reports
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
                  "Erreur lors de l'envoi du signalement (${response.statusCode})"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Report Network Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur réseau lors du signalement: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  void _shareAction() {
    if (_service == null) return;
    Share.share(
        'Regarde ce service professionnel sur BricoRasy : ${_service!.name} à ${_service!.localisation}');
  }

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
              child: const Text('Envoyer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Consider using Theme.of(context).colorScheme.error
                foregroundColor: Colors.white, // Consider using Theme.of(context).colorScheme.onError
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).cardColor, // Use theme color
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
              leading: Icon(Icons.flag_outlined, color: Theme.of(context).colorScheme.error),
              title: Text('Signaler', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            const SizedBox(height: 10), // For bottom padding if any
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chargement..."),
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: onPrimaryColor),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _service == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Erreur"),
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: onPrimaryColor),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error ?? "Une erreur inconnue est survenue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchServiceDetails,
                  child: const Text("Réessayer"),
                )
              ],
            ),
          ),
        ),
      );
    }

    // At this point, _service is not null
    final ProfessionalService currentService = _service!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: onPrimaryColor),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false, // Or true, depending on your design
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text( // Title in the collapsed app bar
                currentService.name,
                style: TextStyle(
                  color: onPrimaryColor,
                  fontSize: 16.0, // Adjust as needed
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              background: Hero(
                tag: currentService.id, // Use service id for Hero tag
                child: currentService.imagePath.isNotEmpty && currentService.imagePath.startsWith('http')
                    ? Image.network(
                        currentService.imagePath,
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
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey[600], size: 60),
                        ),
                      )
                    : (currentService.imagePath.isNotEmpty && currentService.imagePath.startsWith('assets/'))
                        ? Image.asset( // For local asset placeholder
                            currentService.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.business_center_outlined, color: Colors.grey[600], size: 60),
                            ),
                          )
                        : Container( // Fallback if imagePath is empty or not recognized
                            color: Colors.grey[300],
                            child: Icon(Icons.business_center_outlined, color: Colors.grey[600], size: 60),
                          ),
              ),
              stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: onPrimaryColor),
                onPressed: _showMoreOptions,
                tooltip: 'Plus d\'options',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentService.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildInfoRow(
                    context,
                    Icons.category_outlined,
                    currentService.categories.isNotEmpty ? currentService.categories.join(" • ") : "Non spécifié",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.location_on_outlined,
                    currentService.localisation.isNotEmpty ? currentService.localisation : "Non spécifiée",
                  ),
                   _buildInfoRow(
                    context,
                    Icons.calendar_today_outlined,
                    "Publié le: ${_formatDate(currentService.dateCreation)}",
                  ),
                   _buildInfoRow(
                    context,
                    Icons.event_busy_outlined,
                    "Expire le: ${_formatDate(currentService.dateExpiration)}",
                  ),
                  _buildInfoRow(
                    context,
                    Icons.sell_outlined,
                    "${currentService.prix.toStringAsFixed(2)} DA",
                    isPrice: true, // Pass the flag for price
                  ),
                  const SizedBox(height: 24.0),
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
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
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
                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    currentService.description?.isNotEmpty == true
                        ? currentService.description!
                        : "Aucune description fournie.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24.0), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}