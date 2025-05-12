// lib/screens/artisan/artisan-profil-screen.dart
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/models/post.model.dart';
import 'package:bricorasy/models/tarif_item.model.dart'; // Ensure this is imported
import 'package:bricorasy/services/post_service.dart';
import 'package:bricorasy/screens/artisan/edit_artisan_profile_screen.dart';
import 'package:bricorasy/screens/personnel_page/chat-screen.dart'; // For _messageAction
// It seems API_BASE_URL is used in _fetchReviews, so keeping it or using AuthService.baseUrl
import 'package:bricorasy/services/auth_services.dart'; // For AuthService.baseUrl and token
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For _fetchReviews
import 'dart:convert'; // For jsonDecode in _fetchReviews
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/poste_custom.dart';
import '../../widgets/tarif_custom.dart';

// Assuming API_BASE_URL is defined somewhere globally or use AuthService.baseUrl
const String API_BASE_URL_PROFILE = AuthService.baseUrl; // Or your specific constant

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

  List<Map<String, String>> _reviews = []; // Using Map as per your _fetchReviews
  bool _isLoadingReviews = true;
  bool _sendingReview = false;
  final TextEditingController _reviewCtrl = TextEditingController();

  late Artisan _displayArtisan;

  @override
  void initState() {
    super.initState();
    _displayArtisan = widget.artisan;

    if (kDebugMode) {
      print("ArtisanProfileScreen initState for: ${_displayArtisan.fullname}, isMyProfile: ${widget.isMyProfile}");
      print("Artisan image path from model: ${_displayArtisan.image}");
      print("Artisan ID for fetching posts/reviews: ${_displayArtisan.id}");
      print("Initial tarifs count from _displayArtisan: ${_displayArtisan.tarifs.length}");
    }

    if (_displayArtisan.id != null && _displayArtisan.id!.isNotEmpty) {
      _fetchArtisanPosts(_displayArtisan.id!);
      _fetchReviews(_displayArtisan.id!); // Fetch reviews using the artisan's ID
    } else {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
          _isLoadingReviews = false;
        });
      }
      if (kDebugMode) print("Artisan ID is null or empty. Cannot fetch posts/reviews.");
    }
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchArtisanPosts(String artisanId) async {
    if (!mounted) return;
    setState(() => _isLoadingPosts = true);
    try {
      _artisanPosts = await PostService.fetchPostsByArtisanId(artisanId);
      if (kDebugMode) print("Fetched ${_artisanPosts.length} posts for artisan $artisanId");
    } catch (e) {
      if (kDebugMode) print("Error fetching posts for artisan $artisanId: $e");
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

  Future<void> _fetchReviews(String artisanId) async { // artisanId is the User._id
    if (!mounted) return;
    setState(() => _isLoadingReviews = true);
    try {
      // Ensure your backend /api/reviews/artisan/:artisanUserId expects the User ID
      final uri = Uri.parse('$API_BASE_URL_PROFILE/api/reviews/artisan/$artisanId');
      if (kDebugMode) print("Fetching reviews from: $uri");

      final resp = await http.get(uri, headers: AuthService.authHeader); // Assuming reviews might be protected

      if (!mounted) return;
      if (resp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(resp.body);
        setState(() {
          _reviews = list.map((j) => {
            'userName': j['reviewer']?['fullname'] as String? ?? 'Anonyme',
            'content': j['comment'] as String? ?? '',
            'rating': j['rating']?.toString() ?? '0', // Assuming rating is sent
            // Add other review fields like date if available
          }).toList();
        });
        if (kDebugMode) print("Fetched ${_reviews.length} reviews.");
      } else {
        if (kDebugMode) print("Error fetching reviews: ${resp.statusCode} - ${resp.body}");
        throw "Code ${resp.statusCode}";
      }
    } catch (e) {
      if (kDebugMode) print("Exception fetching reviews: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur chargement avis: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview() async {
    final text = _reviewCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le commentaire ne peut pas être vide.")));
      return;
    }
    if (_displayArtisan.id == null || _displayArtisan.id!.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID de l'artisan manquant.")));
      return;
    }

    if (!mounted) return;
    setState(() => _sendingReview = true);
    try {
      final uri = Uri.parse('$API_BASE_URL_PROFILE/api/reviews/artisan/${_displayArtisan.id}');
      final resp = await http.post(
        uri,
        headers: AuthService.authHeader, // Use authHeader which includes Content-Type
        body: jsonEncode({
          'comment': text,
          // 'rating': _selectedRating, // You'll need a way to select rating (e.g., star rating widget)
          }),
      );
      if (!mounted) return;
      if (resp.statusCode == 201) {
        _reviewCtrl.clear();
        // setState(() => _selectedRating = 0); // Reset rating selector
        await _fetchReviews(_displayArtisan.id!); // Refresh reviews
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avis soumis avec succès!"), backgroundColor: Colors.green,));
      } else {
        final err = jsonDecode(resp.body)['message'] ?? 'Erreur lors de la soumission de l\'avis';
        throw err;
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Échec envoi avis: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _sendingReview = false);
    }
  }


  Widget _buildStatItem(BuildContext context, IconData icon, String value, {String? label}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(value.isNotEmpty ? value : "N/A", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface), textAlign: TextAlign.center),
          if(label != null && label.isNotEmpty) const SizedBox(height: 2),
          if(label != null && label.isNotEmpty) Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> _handleCall() async {
    if (_displayArtisan.numTel.isEmpty) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Numéro de téléphone non disponible.")));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: _displayArtisan.numTel);
    try {
      if (await canLaunchUrl(launchUri)) { await launchUrl(launchUri); } else { throw 'Could not launch $launchUri'; }
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Impossible de passer l'appel au ${_displayArtisan.numTel}")));
      if (kDebugMode) print('Could not launch $launchUri: $e');
    }
  }

  void _handleMessage() {
    if (kDebugMode) print("Message action triggered for ${_displayArtisan.fullname}");
    if (_displayArtisan.id == null || _displayArtisan.id!.isEmpty) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'initier la messagerie: ID de l'artisan manquant.")));
      return;
    }
    // Ensure AuthService.currentUser is not null and has an ID
    if (AuthService.currentUser == null || AuthService.currentUser!.id.isEmpty) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez vous connecter pour envoyer un message.")));
      return;
    }

    // TODO: Replace with your actual ChatService.initiateConversation logic
    // For now, navigating to Chatscreen with necessary IDs
    // The 'annonceId' for a direct chat with an artisan might just be a combination of user IDs or a dedicated conversation ID.
    // For this example, I'll use artisan.id as a placeholder for a unique conversation identifier context.
    // You'll need a proper backend mechanism to create/retrieve conversation IDs.
    final String conversationContextId = "artisan_${_displayArtisan.id}"; // Example context

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Chatscreen( // Assuming Chatscreen takes these parameters
          username: _displayArtisan.fullname, // Name of the person you are chatting with
          peerId: _displayArtisan.id!,       // The ID of the artisan user
          annonceId: conversationContextId, // Context for the conversation (can be artisanId or a generated convo ID)
        ),
      ),
    );
  }

  void _handleMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: const Icon(Icons.bookmark_border_outlined), title: const Text('Enregistrer'), onTap: () { Navigator.pop(context); /* TODO */ }),
              ListTile(leading: const Icon(Icons.rate_review_outlined), title: const Text('Laisser un Avis'), onTap: () { Navigator.pop(context); _showAddReviewDialog(); }),
              ListTile(leading: const Icon(Icons.share_outlined), title: const Text('Partager le profil'), onTap: () { Navigator.pop(context); /* TODO */ }),
              ListTile(leading: Icon(Icons.flag_outlined, color: Theme.of(context).colorScheme.error), title: Text('Signaler', style: TextStyle(color: Theme.of(context).colorScheme.error)), onTap: () { Navigator.pop(context); /* TODO */ }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
    // Reset controller for new review
    _reviewCtrl.clear();
    // TODO: Add a star rating input widget here if you want ratings with comments
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Laisser un avis pour ${_displayArtisan.fullname}"),
            content: TextField(
              controller: _reviewCtrl,
              decoration: const InputDecoration(hintText: "Votre commentaire..."),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Annuler")),
              ElevatedButton(
                onPressed: _sendingReview ? null : () {
                  Navigator.pop(dialogContext); // Close dialog first
                  _submitReview();
                },
                child: _sendingReview ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Envoyer"),
              ),
            ],
          );
        });
  }


  Future<void> _navigateToEditProfile() async {
    if (kDebugMode) print("Navigating to edit profile for: ${_displayArtisan.fullname}");
    final updatedArtisanData = await Navigator.push<Artisan>(
      context,
      MaterialPageRoute(
        builder: (context) => EditArtisanProfileScreen(artisan: _displayArtisan),
      ),
    );

    if (updatedArtisanData != null && mounted) {
      setState(() {
        _displayArtisan = updatedArtisanData;
        if (kDebugMode) {
          print("Profile updated. New image path: ${_displayArtisan.image}");
          print("Updated tarifs count: ${_displayArtisan.tarifs.length}");
          _displayArtisan.tarifs.forEach((t) => print("  Tarif: ${t.serviceName} - ${t.price} (ID: ${t.id})"));
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour avec succès!"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final ImageProvider displayImageProvider;
    if (_displayArtisan.image.isNotEmpty) {
      if (_displayArtisan.image.startsWith('http')) {
        displayImageProvider = NetworkImage(_displayArtisan.image);
      } else if (_displayArtisan.image.startsWith('assets/')) {
        displayImageProvider = AssetImage(_displayArtisan.image);
      } else {
        displayImageProvider = AssetImage('assets/images/${_displayArtisan.image}');
      }
    } else {
      displayImageProvider = const AssetImage('assets/images/defaultprofil.png');
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.isMyProfile ? "Mon Profil Artisan" : _displayArtisan.fullname, style: TextStyle(color: colorScheme.onSurface)),
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
              onPressed: _navigateToEditProfile,
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
      body: RefreshIndicator( // Added RefreshIndicator
        onRefresh: () async {
          // Re-fetch data when user pulls to refresh
          if (_displayArtisan.id != null && _displayArtisan.id!.isNotEmpty) {
            await _fetchArtisanPosts(_displayArtisan.id!);
            await _fetchReviews(_displayArtisan.id!);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll even if content is small
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
                         if (kDebugMode) print("Error loading profile image for ${_displayArtisan.fullname}: $exception");
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(_displayArtisan.fullname, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface), textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text(_displayArtisan.job.isNotEmpty ? _displayArtisan.job : "Profession non spécifiée", style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStatItem(context, Icons.star_outline_rounded, _displayArtisan.rating, label: "Note")),
                        SizedBox(height: 60, child: VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8, color: colorScheme.outlineVariant)),
                        Expanded(child: _buildStatItem(context, Icons.location_on_outlined, _displayArtisan.localisation, label: "Lieu")),
                        SizedBox(height: 60, child: VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8, color: colorScheme.outlineVariant)),
                        Expanded(child: _buildStatItem(context, Icons.favorite_border_rounded, _displayArtisan.like, label: "Likes")),
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
                                 onPressed: _displayArtisan.numTel.isNotEmpty ? _handleCall : null,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary,
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
                                   foregroundColor: colorScheme.primary, side: BorderSide(color: colorScheme.primary.withOpacity(0.7)),
                                   padding: const EdgeInsets.symmetric(vertical: 12),
                                   textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
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
                      if (_displayArtisan.tarifs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(child: Text("Aucun tarif spécifié.", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center)),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _displayArtisan.tarifs.length,
                          itemBuilder: (context, index) {
                            final tarifItem = _displayArtisan.tarifs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TarifCustom(title: tarifItem.serviceName, prix: tarifItem.price),
                            );
                          },
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
                            if (mounted) setState(() => _currentView = newSelection.first);
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
                            ? _buildPostesView(context, textTheme, colorScheme)
                            : _buildAvisView(context, textTheme, colorScheme),
                      ),
                   ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostesView(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    if (_isLoadingPosts) return Center(key: const ValueKey('postes_loading'), child: CircularProgressIndicator(color: colorScheme.primary));
    if (_artisanPosts.isEmpty) return Center(key: const ValueKey('postes_empty'), child: Padding(padding: const EdgeInsets.all(16.0), child: Text("Aucun poste publié.", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant))));
    return Column(
      key: const ValueKey('postes_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(widget.isMyProfile ? "Mes Postes" : "Postes de ${_displayArtisan.fullname}", style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _artisanPosts.length,
          itemBuilder: (context, index) {
            final post = _artisanPosts[index];
            return Padding(padding: const EdgeInsets.only(bottom: 16.0), child: PosteCustom(post: post));
          },
        ),
      ],
    );
  }

  Widget _buildAvisView(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    if (_isLoadingReviews) return Center(key: const ValueKey('avis_loading'), child: CircularProgressIndicator(color: colorScheme.primary));
    if (_reviews.isEmpty) return Center(key: const ValueKey('avis_empty'), child: Padding(padding: const EdgeInsets.all(16.0), child: Text("Aucun avis pour le moment.", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant))));

    return Column(
      key: const ValueKey('avis_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Laisser un avis" button only if not my profile and user is logged in
        if (!widget.isMyProfile && AuthService.currentUser != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text("Laisser un avis"),
                onPressed: _showAddReviewDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer
                ),
              ),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return _buildReviewItem(context, review['userName']!, review['content']!, int.tryParse(review['rating'] ?? '0') ?? 0);
          },
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context, String userName, String reviewText, int rating) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.tertiaryContainer,
                  child: Text(userName.isNotEmpty ? userName.substring(0,1).toUpperCase() : "?", style: TextStyle(color: colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold)),
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
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
            const SizedBox(height: 8),
            Text(reviewText, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}