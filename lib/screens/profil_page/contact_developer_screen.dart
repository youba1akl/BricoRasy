// lib/screens/contact_developer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart'; // For launching email client

class ContactDeveloperScreen extends StatelessWidget {
  const ContactDeveloperScreen({super.key});

  final String developerEmail = "anisaissani765@gmail.com"; // Corrected email
  final String emailSubject = "Contact depuis l'application BricoRasy";
  final String emailBody = "Bonjour l'équipe BricoRasy,\n\nJe vous contacte concernant...\n\n";

  Future<void> _launchEmailApp(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: developerEmail,
      queryParameters: {
        'subject': emailSubject,
        'body': emailBody,
      },
    );

    if (!await launchUrl(emailLaunchUri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'application email. Veuillez copier l\'adresse manuellement.')),
      );
    }
  }

  void _copyEmailToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: developerEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copié dans le presse-papiers !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacter les Développeurs"),
        backgroundColor: colorScheme.surface,
        elevation: 1,
      ),
      body: SingleChildScrollView( // To prevent overflow if content grows
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Nous Contacter",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Pour toute question, suggestion, ou si vous rencontrez un problème technique que vous souhaitez nous signaler directement, n'hésitez pas à nous envoyer un email.",
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: colorScheme.secondary, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "Adresse Email :",
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      developerEmail,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        // color: colorScheme.tertiary, // Or another distinct color
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text("Copier l'Email"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _copyEmailToClipboard(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_outlined),
                    label: const Text("Ouvrir l'Email"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _launchEmailApp(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "Nous nous efforcerons de vous répondre dans les plus brefs délais.",
              style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}