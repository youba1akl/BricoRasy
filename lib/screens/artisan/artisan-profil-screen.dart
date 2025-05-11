// lib/screens/artisan/artisan-profil-screen.dart
import 'dart:convert';
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/models/post.model.dart'; // For Post model
import 'package:bricorasy/services/post_service.dart'; // For PostService
import 'package:bricorasy/services/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../widgets/poste_custom.dart';
import '../../widgets/tarif_custom.dart';

enum ProfileView { postes, avis }

const String API_BASE_URL = "http://10.0.2.2:5000";

class Artisanprofilscreen extends StatefulWidget {
  final Artisan artisan;
  final bool isMyProfile;

  const Artisanprofilscreen({
    super.key,
    required this.artisan,
    this.isMyProfile = false,
  });

  @override
  State<Artisanprofilscreen> createState() => _ArtisanprofilscreenState();
}

class _ArtisanprofilscreenState extends State<Artisanprofilscreen> {
  ProfileView _currentView = ProfileView.postes;

  // Posts
  List<Post> _artisanPosts = [];
  bool _isLoadingPosts = true;

  // --- Reviews state ---
  List<Map<String, String>> _reviews = [];
  bool _isLoadingReviews = true;
  bool _sendingReview = false;
  final TextEditingController _reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print(
        "ArtisanProfileScreen initState for: ${widget.artisan.fullname}, isMyProfile: ${widget.isMyProfile}",
      );
      print("Artisan image path from model: ${widget.artisan.image}");
      print("Artisan ID for fetching posts: ${widget.artisan.id}");
    }
    _fetchArtisanPosts();
    _fetchReviews();
  }

  Future<void> _fetchArtisanPosts() async {
    if (widget.artisan.id == null || widget.artisan.id!.isEmpty) {
      if (mounted) setState(() => _isLoadingPosts = false);
      return;
    }
    setState(() => _isLoadingPosts = true);
    try {
      _artisanPosts = await PostService.fetchPostsByArtisanId(
        widget.artisan.id!,
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur chargement postes: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final resp = await http.get(
        Uri.parse('$API_BASE_URL/api/reviews/artisan/${widget.artisan.id}'),
        headers: AuthService.authHeader,
      );
      if (resp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(resp.body);
        _reviews =
            list
                .map(
                  (j) => {
                    'userName': j['reviewer']?['fullname'] as String? ?? '—',
                    'content': j['comment'] as String? ?? '',
                  },
                )
                .toList();
      } else {
        throw "Code ${resp.statusCode}";
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur chargement avis: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview() async {
    final text = _reviewCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendingReview = true);
    try {
      final uri = Uri.parse(
        '$API_BASE_URL/api/reviews/artisan/${widget.artisan.id}',
      );
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({'comment': text}),
      );
      if (resp.statusCode == 201) {
        _reviewCtrl.clear();
        await _fetchReviews();
      } else {
        final err = jsonDecode(resp.body)['message'] ?? 'Erreur';
        throw err;
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Échec envoi avis: $e")));
    } finally {
      if (mounted) setState(() => _sendingReview = false);
    }
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value, {
    String? label,
  }) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: cs.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : "N/A",
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (label != null && label.isNotEmpty)
            Text(
              label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Future<void> _handleCall() async {
    if (widget.artisan.numTel.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: widget.artisan.numTel);
    if (!await launchUrl(uri)) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Impossible d’appeler : ${widget.artisan.numTel}"),
          ),
        );
    }
  }

  void _handleMessage() {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Messagerie à implémenter.")),
      );
  }

  void _handleMoreOptions() {
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
                  leading: const Icon(Icons.bookmark_border_outlined),
                  title: const Text('Enregistrer'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: const Text('Laisser un Avis'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Partager le profil'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(
                    Icons.flag_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Signaler',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Determine profile image...
    final displayImage =
        widget.artisan.image.startsWith('http')
            ? NetworkImage(widget.artisan.image)
            : AssetImage(
                  widget.artisan.image.startsWith('assets/')
                      ? widget.artisan.image
                      : 'assets/images/${widget.artisan.image}',
                )
                as ImageProvider;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isMyProfile ? "Mon Profil Artisan" : widget.artisan.fullname,
          style: TextStyle(color: cs.onSurface),
        ),
        backgroundColor: cs.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.isMyProfile)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: cs.onSurface),
              onPressed: () {},
            ),
          if (!widget.isMyProfile)
            IconButton(
              icon: Icon(Icons.more_vert, color: cs.onSurface),
              onPressed: _handleMoreOptions,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ** Profile Header & Stats **
            Container(
              color: cs.surfaceContainer,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: cs.surfaceVariant,
                    backgroundImage: displayImage,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.artisan.fullname,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.artisan.job.isNotEmpty
                        ? widget.artisan.job
                        : "Profession non spécifiée",
                    style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          Icons.star_outline_rounded,
                          widget.artisan.rating,
                          label: "Note",
                        ),
                      ),
                      VerticalDivider(
                        color: cs.outlineVariant,
                        thickness: 1,
                        indent: 8,
                        endIndent: 8,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          Icons.location_on_outlined,
                          widget.artisan.localisation,
                          label: "Lieu",
                        ),
                      ),
                      VerticalDivider(
                        color: cs.outlineVariant,
                        thickness: 1,
                        indent: 8,
                        endIndent: 8,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          Icons.favorite_border_rounded,
                          widget.artisan.like,
                          label: "Likes",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!widget.isMyProfile)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.phone_outlined),
                              label: const Text("Appeler"),
                              onPressed: _handleCall,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.message_outlined),
                              label: const Text("Message"),
                              onPressed: _handleMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.isMyProfile)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.dashboard_customize_outlined),
                        label: const Text("Gérer mes Postes"),
                        onPressed: () {},
                      ),
                    ),
                ],
              ),
            ),

            // ** Catalogue / Tarifs **
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Catalogue / Tarifs Indicatifs",
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TarifCustom(
                    title: 'Service Exemple 1',
                    prix: '1000 DA - 2000 DA',
                  ),
                  const SizedBox(height: 8),
                  TarifCustom(
                    title: 'Service Exemple 2',
                    prix: 'Contactez-moi',
                  ),
                  const SizedBox(height: 24),

                  // ** Segmented Control **
                  Center(
                    child: SegmentedButton<ProfileView>(
                      segments: const [
                        ButtonSegment(
                          value: ProfileView.postes,
                          label: Text('Postes'),
                          icon: Icon(Icons.dynamic_feed_outlined),
                        ),
                        ButtonSegment(
                          value: ProfileView.avis,
                          label: Text('Avis'),
                          icon: Icon(Icons.reviews_outlined),
                        ),
                      ],
                      selected: {_currentView},
                      onSelectionChanged:
                          (s) => setState(() => _currentView = s.first),
                    ),
                  ),
                  const SizedBox(height: 20),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _currentView == ProfileView.postes
                            ? _buildPostesView(context, tt, cs)
                            : _buildAvisView(context, tt, cs),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostesView(BuildContext context, TextTheme tt, ColorScheme cs) {
    if (_isLoadingPosts) {
      return Center(
        key: const ValueKey('postes_loading'),
        child: CircularProgressIndicator(color: cs.primary),
      );
    }
    if (_artisanPosts.isEmpty) {
      return Center(
        key: const ValueKey('postes_empty'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Aucun poste publié pour le moment.",
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }
    return Column(
      key: const ValueKey('postes_content'),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _artisanPosts.length,
          itemBuilder:
              (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PosteCustom(post: _artisanPosts[i]),
              ),
        ),
      ],
    );
  }

  Widget _buildAvisView(BuildContext context, TextTheme tt, ColorScheme cs) {
    if (_isLoadingReviews) {
      return Center(
        key: const ValueKey('avis_loading'),
        child: CircularProgressIndicator(color: cs.primary),
      );
    }
    return Column(
      key: const ValueKey('avis_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Avis sur ${widget.artisan.fullname}",
          style: tt.titleMedium?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 10),
        // existing reviews
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reviews.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = _reviews[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Text(
                  r['userName']![0].toUpperCase(),
                  style: TextStyle(color: cs.onPrimaryContainer),
                ),
              ),
              title: Text(
                r['userName']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(r['content']!),
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
        const Divider(height: 32),
        // new review input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _reviewCtrl,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Écrire un avis…",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon:
                    _sendingReview
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(Icons.send),
                onPressed: _sendingReview ? null : _submitReview,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
