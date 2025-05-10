// lib/widgets2/home/service_list_view.dart

import 'package:flutter/material.dart';
import 'package:bricorasy/models/bricole_service.dart';
// Import the service card widget (adjust path if necessary)
import 'package:bricorasy/widgets2/home/service_card.dart';
// Import the detail screen (adjust path if necessary)
import 'package:bricorasy/screens/home/bricole-screen.dart'; // <-- Import Bricolescreen

class ServiceListView extends StatelessWidget {
  final List<BricoleService> services;
  // Keep the callback parameter, even if navigation is primary action now
  final Function(BricoleService) onServiceTapped;

  const ServiceListView({
    super.key,
    required this.services,
    required this.onServiceTapped, // Keep this parameter
  });

  @override
  Widget build(BuildContext context) {
    // Consistent padding for the list content area
    const EdgeInsets contentPadding = EdgeInsets.only(
        top: 12.0, left: 16.0, right: 16.0, bottom: 16.0);

    return ListView.builder(
      padding: contentPadding,
      itemCount: services.length,
      itemBuilder: (context, index) {
        final currentService = services[index]; // Get the specific service
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0), // Spacing between cards
          child: ServiceInfoBigCard( // Use the imported card widget
            service: currentService,
            press: () {
              // --- Navigation Logic Added Here ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Navigate to Bricolescreen and pass the service data
                  builder: (_) => Bricolescreen(service: currentService),
                ),
              );
              // You can still call the original callback if needed for other logic
              // onServiceTapped(currentService);
              // --- End Navigation Logic ---
            },
          ),
        );
      },
    );
  }
}