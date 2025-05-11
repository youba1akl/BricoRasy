// lib/screens/artisan/artisan-profil-screen.dart
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/models/post.model.dart'; // For Post model
import 'package:bricorasy/services/post_service.dart'; // For PostService
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/poste_custom.dart';
import '../../widgets/tarif_custom.dart';

enum ProfileView { postes, avis }

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

  List<Post> _artisanPosts = [];
  bool _isLoadingPosts = true;
  // List<YourReviewModel> _artisanReviews = [];
  // bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("ArtisanProfileScreen initState for: ${widget.artisan.fullname}, isMyProfile: ${widget.isMyProfile}");
      print("Artisan image path from model: ${widget.artisan.image}");
      print("Artisan ID for fetching posts: ${widget.artisan.id}");
    }
    _fetchArtisanPosts();
    // _fetchArtisanReviews();
  }

  Future<void> _fetchArtisanPosts() async {
    if (widget.artisan.id == null || widget.artisan.id!.isEmpty) {
      if (kDebugMode) print("Artisan ID is null or empty. Cannot fetch posts.");
      if (mounted) setState(() => _isLoadingPosts = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoadingPosts = true);
    try {
      _artisanPosts = await PostService.fetchPostsByArtisanId(widget.artisan.id!);
      if (kDebugMode) print("Fetched ${_artisanPosts.length} posts for artisan ${widget.artisan.fullname}");
    } catch (e) {
      if (kDebugMode) print("Error fetching posts for artisan ${widget.artisan.id}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des postes: ${e.toString()}")),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoadingPosts = false);
    }
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, {String? label}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : "N/A",
            style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
          if(label != null && label.isNotEmpty) const SizedBox(height: 2),
          if(label != null && label.isNotEmpty) Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleCall() async {
    if (widget.artisan.numTel.isEmpty) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Numéro de téléphone non disponible.")),
        );
      }
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: widget.artisan.numTel);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
       if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible de passer l'appel au ${widget.artisan.numTel}")),
        );
      }
      if (kDebugMode) print('Could not launch $launchUri: $e');
    }
  }

  void _handleMessage() {
    if (kDebugMode) print("Message action triggered for ${widget.artisan.fullname}");
     if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Messagerie à implémenter.")),
        );
     }
  }

  void _handleMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: const Icon(Icons.bookmark_border_outlined), title: const Text('Enregistrer'), onTap: () { Navigator.pop(context); /* TODO */ }),
              ListTile(leading: const Icon(Icons.rate_review_outlined), title: const Text('Laisser un Avis'), onTap: () { Navigator.pop(context); /* TODO */ }),
              ListTile(leading: const Icon(Icons.share_outlined), title: const Text('Partager le profil'), onTap: () { Navigator.pop(context); /* TODO */ }),
              ListTile(leading: Icon(Icons.flag_outlined, color: Theme.of(context).colorScheme.error), title: Text('Signaler', style: TextStyle(color: Theme.of(context).colorScheme.error)), onTap: () { Navigator.pop(context); /* TODO */ }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final ImageProvider displayImageProvider;
    if (widget.artisan.image.isNotEmpty) {
      if (widget.artisan.image.startsWith('http')) {
        displayImageProvider = NetworkImage(widget.artisan.image);
      } else if (widget.artisan.image.startsWith('assets/')) {
        displayImageProvider = AssetImage(widget.artisan.image);
      } else {
        displayImageProvider = AssetImage('assets/images/${widget.artisan.image}');
        if (kDebugMode) print("Artisan image '${widget.artisan.image}' not a URL or full asset path, attempting 'assets/images/${widget.artisan.image}'. Ensure this asset exists.");
      }
    } else {
      displayImageProvider = const AssetImage('assets/images/defaultprofil.png');
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.isMyProfile ? "Mon Profil Artisan" : widget.artisan.fullname, style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.isMyProfile)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface),
              onPressed: () {
                if (kDebugMode) print("Edit my artisan profile: ${widget.artisan.fullname}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Édition du profil artisan à implémenter.")),
                );
              },
              tooltip: 'Modifier le profil',
            ),
          if (!widget.isMyProfile)
             IconButton(
               icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
               onPressed: _handleMoreOptions,
               tooltip: 'Plus d\'options',
             ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container( // Profile Header
              color: colorScheme.surfaceContainer,
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.surfaceVariant,
                    backgroundImage: displayImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                       if (kDebugMode) print("Error loading profile image for ${widget.artisan.fullname}: $exception");
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(widget.artisan.fullname, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface), textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(widget.artisan.job.isNotEmpty ? widget.artisan.job : "Profession non spécifiée", style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildStatItem(context, Icons.star_outline_rounded, widget.artisan.rating, label: "Note")),
                      SizedBox(height: 60, child: VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8, color: colorScheme.outlineVariant)),
                      Expanded(child: _buildStatItem(context, Icons.location_on_outlined, widget.artisan.localisation, label: "Lieu")),
                      SizedBox(height: 60, child: VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8, color: colorScheme.outlineVariant)),
                      Expanded(child: _buildStatItem(context, Icons.favorite_border_rounded, widget.artisan.like, label: "Likes")),
                    ],
                  ),
                   const SizedBox(height: 24),
                   if (!widget.isMyProfile)
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                       child: Row(
                         children: [
                           Expanded(
                             child: ElevatedButton.icon(
                               icon: const Icon(Icons.phone_outlined, size: 18),
                               label: const Text("Appeler"),
                               onPressed: widget.artisan.numTel.isNotEmpty ? _handleCall : null,
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: colorScheme.primary,
                                 foregroundColor: colorScheme.onPrimary,
                                 padding: const EdgeInsets.symmetric(vertical: 12),
                                 textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                               ),
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: OutlinedButton.icon(
                               icon: const Icon(Icons.message_outlined, size: 18),
                               label: const Text("Message"),
                               onPressed: _handleMessage,
                               style: OutlinedButton.styleFrom(
                                 foregroundColor: colorScheme.primary,
                                 side: BorderSide(color: colorScheme.primary.withOpacity(0.7)),
                                 padding: const EdgeInsets.symmetric(vertical: 12),
                                 textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                    if (widget.isMyProfile)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.dashboard_customize_outlined),
                              label: Text("Gérer mes Postes", style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Navigation vers la gestion des postes à implémenter.")),
                                  );
                              }
                          ),
                        )
                ],
              ),
            ),
            Padding( // Content Area
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text("Catalogue / Tarifs Indicatifs", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        TarifCustom(title: 'Service Exemple 1', prix: '1000 DA - 2000 DA'),
                        const SizedBox(height: 8),
                        TarifCustom(title: 'Service Exemple 2', prix: 'Contactez-moi'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SegmentedButton<ProfileView>(
                        segments: const <ButtonSegment<ProfileView>>[
                          ButtonSegment<ProfileView>(value: ProfileView.postes, label: Text('Postes'), icon: Icon(Icons.dynamic_feed_outlined)),
                          ButtonSegment<ProfileView>(value: ProfileView.avis, label: Text('Avis'), icon: Icon(Icons.reviews_outlined)),
                        ],
                        selected: <ProfileView>{_currentView},
                        onSelectionChanged: (Set<ProfileView> newSelection) {
                          if (mounted) {
                            setState(() { _currentView = newSelection.first; });
                          }
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          selectedBackgroundColor: colorScheme.primaryContainer,
                          selectedForegroundColor: colorScheme.onPrimaryContainer,
                          foregroundColor: colorScheme.onSurfaceVariant,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentView == ProfileView.postes
                          ? _buildPostesView(context, textTheme, colorScheme) // Pass context and theme data
                          : _buildAvisView(context, textTheme, colorScheme),   // Pass context and theme data
                    ),
                 ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostesView(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    if (_isLoadingPosts) {
      return Center(key: const ValueKey('postes_loading'), child: CircularProgressIndicator(color: colorScheme.primary));
    }
    if (_artisanPosts.isEmpty) {
      return Center(key: const ValueKey('postes_empty'), child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Aucun poste publié pour le moment.", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
      ));
    }

    return Column(
      key: const ValueKey('postes_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            widget.isMyProfile ? "Mes Postes" : "Postes de ${widget.artisan.fullname}",
            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _artisanPosts.length,
          itemBuilder: (context, index) {
            final post = _artisanPosts[index]; // post is a Post object here
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: PosteCustom( // <-- CORRECTED USAGE
                post: post,      // Pass the entire 'post' object
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvisView(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    // ... (Placeholder, same as your provided code)
    return Column(
      key: const ValueKey('avis_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Avis sur ${widget.artisan.fullname}", style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
        const SizedBox(height: 10),
        _buildReviewItem(context, "Utilisateur A", "Excellent service, très professionnel et rapide !", 5),
        const Divider(),
        _buildReviewItem(context, "Client B", "Bon travail, je recommande.", 4),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context, String userName, String reviewText, int rating) {
    // ... (Placeholder, same as your provided code)
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer,
        child: Text(userName.isNotEmpty ? userName.substring(0,1).toUpperCase() : "?", style: TextStyle(color: colorScheme.onSecondaryContainer)),
      ),
      title: Row(
        children: [
          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) => Icon(
              index < rating ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber,
              size: 18,
            )),
          )
        ],
      ),
      subtitle: Text(reviewText),
      contentPadding: EdgeInsets.zero,
    );
  }
}