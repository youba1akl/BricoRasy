// lib/screens/annonce_list_screen.dart

import 'package:flutter/material.dart';
import 'package:bricorasy/services/annonce_activity.dart';
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/models/dummy_tool.dart';

class AnnonceListScreen extends StatelessWidget {
  const AnnonceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Annonces'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bricolage'),
              Tab(text: 'Pro'),
              Tab(text: 'Outils'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AnnonceTab<BricoleService>(
              fetcher: AnnonceService.fetchBricole,
              itemBuilder: _buildBricoleCard,
            ),
            _AnnonceTab<ProfessionalService>(
              fetcher: AnnonceService.fetchProfessionnel,
              itemBuilder: _buildProCard,
            ),
            _AnnonceTab<DummyTool>(
              fetcher: AnnonceService.fetchOutil,
              itemBuilder: _buildOutilCard,
            ),
          ],
        ),
      ),
    );
  }

  // --- Card builders ---

  static Widget _buildBricoleCard(BuildContext ctx, BricoleService s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(s.name, style: Theme.of(ctx).textTheme.titleLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.localisation ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Publié le ${s.date_creation}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProCard(BuildContext ctx, ProfessionalService s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(s.name, style: Theme.of(ctx).textTheme.titleLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Publié le ${s.dateCreation}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOutilCard(BuildContext ctx, DummyTool s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(s.name, style: Theme.of(ctx).textTheme.titleLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.typeAnnonce, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              'Ajouté le ${s.dateCreation}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Generic tab widget ---
class _AnnonceTab<T> extends StatelessWidget {
  final Future<List<T>> Function() fetcher;
  final Widget Function(BuildContext, T) itemBuilder;

  const _AnnonceTab({required this.fetcher, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: fetcher(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Erreur : ${snap.error}'));
        }
        final list = snap.data!;
        if (list.isEmpty) {
          return const Center(child: Text('Aucune annonce'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: list.length,
          itemBuilder: (ctx, i) => itemBuilder(ctx, list[i]),
        );
      },
    );
  }
}
