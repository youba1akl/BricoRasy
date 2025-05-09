// lib/widgets2/home/proServiceListView.dart

import 'package:flutter/material.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/widgets2/home/proServiceCard.dart';     // Your card widget
import 'package:bricorasy/screens/home/professional_detail_screen.dart'; // <-- Import your detail screen

class ProserviceListView extends StatelessWidget {
  final List<ProfessionalService> services;
  // You can drop this callback if you never use it elsewhere:
  final Function(ProfessionalService)? onServiceTapped;

  const ProserviceListView({
    super.key,
    required this.services,
    this.onServiceTapped,
  });

  @override
  Widget build(BuildContext context) {
    const EdgeInsets contentPadding = EdgeInsets.only(
      top: 12.0, left: 16.0, right: 16.0, bottom: 16.0,
    );

    return ListView.builder(
      padding: contentPadding,
      itemCount: services.length,
      itemBuilder: (context, index) {
        final svc = services[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: ServiceInfoBigCardProf(
            service: svc,
            press: () {
              // 1) Navigate to the professional detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>ProfessionalDetailScreen(service: svc),
                ),
              );
              // 2) (Optional) still call the callback if provided
              if (onServiceTapped != null) {
                onServiceTapped!(svc);
              }
            },
          ),
        );
      },
    );
  }
}
