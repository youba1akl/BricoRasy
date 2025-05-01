import 'package:flutter/material.dart';
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/widgets2/home/service_card.dart'; // Import the consolidated card

class ServiceListView extends StatelessWidget {
  final List<BricoleService> services;
  final Function(BricoleService) onServiceTapped;

  const ServiceListView({
    super.key,
    required this.services,
    required this.onServiceTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Consistent padding for the list content area
    const EdgeInsets contentPadding = EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0, bottom: 16.0);

    return ListView.builder(
      padding: contentPadding,
      itemCount: services.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0), // Spacing between service cards
        child: ServiceInfoBigCard( // Use the imported widget
          service: services[index],
          press: () => onServiceTapped(services[index]),
        ),
      ),
    );
  }
}