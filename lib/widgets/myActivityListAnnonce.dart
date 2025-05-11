// lib/widgets/info_list_view.dart
import 'package:flutter/material.dart';
import '../widgets/my_activityAnnonce.dart';

/// Modèle minimal pour les données à afficher
class InfoItem {
  final String id;
  final String title;
  final String description;
  final DateTime dateCreation;

  InfoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateCreation,
  });
}

/// Un ListView de [InfoCard]
class InfoListView extends StatelessWidget {
  final List<InfoItem> items;

  const InfoListView({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée à afficher',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InfoCard(
          title: item.title,
          description: item.description,
          dateCreation: item.dateCreation,
        );
      },
    );
  }
}
