// lib/screens/artisan/artisan-profil-screen.dart
import 'package:bricorasy/models/artisan.model.dart'; // Your Artisan model
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For call functionality

// Assuming these are custom widgets you've defined elsewhere for posts and tarifs
// Adjust paths if these widgets are in a different location
import '../../widgets/poste_custom.dart';
import '../../widgets/tarif_custom.dart';

// TODO: Import your chat screen if you implement messaging
// import 'package:bricorasy/screens/personnel_page/chat_screen.dart';
// TODO: Import your service/provider for fetching posts and reviews for this artisan
// import 'package:bricorasy/services/post_service.dart'; // Assuming you'll create this
// import 'package:bricorasy/services/review_service.dart'; // Assuming you'll create this
// TODO: Import AuthService if needed for chat initiation or other user-specific actions
// import 'package:bricorasy/services/auth_service.dart';

enum ProfileView { postes, avis } // For toggling content

class Artisanprofilscreen extends StatefulWidget {
  final Artisan artisan;       // Expect an Artisan object
  final bool isMyProfile;    // Flag to indicate if it's the logged-in user's profile

  const Artisanprofilscreen({
    super.key,
    required this.artisan,    // Artisan object is now required
    this.isMyProfile = false, // Default to false (viewing someone else)
  });

  @override
  State<Artisanprofilscreen> createState() => _ArtisanprofilscreenState();
}

class _ArtisanprofilscreenState extends State<Artisanprofilscreen> {
  ProfileView _currentView = ProfileView.postes; // Default view for content area

  // TODO: Add state variables for posts and reviews if fetched dynamically
  // List<YourPostModel> _artisanPosts = [];
  // List<YourReviewModel> _artisanReviews = [];
  // bool _isLoadingPosts = false; // Set to true in initState if fetching
  // bool _isLoadingReviews = false; // Set to true in initState if fetching

  @override
  void initState() {
    super.initState();
    // TODO: Fetch posts and reviews for widget.artisan (e.g., using widget.artisan.id if it exists)
    // _fetchArtisanPosts();
    // _fetchArtisanReviews();
    print("ArtisanProfileScreen initState for: ${widget.artisan.fullname}, isMyProfile: ${widget.isMyProfile}");
    print("Artisan image path from model: ${widget.artisan.image}");
  }

  // --- Placeholder fetch methods (implement with actual service calls) ---
  // Future<void> _fetchArtisanPosts() async {
  //   if (!mounted) return;
  //   setState(() => _isLoadingPosts = true);
  //   try {
  //     // Example: _artisanPosts = await PostService.fetchPostsByArtisanId(widget.artisan.id);
  //     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  //     // _artisanPosts = [dummyPost1, dummyPost2]; // Populate with dummy posts
  //     print("Fetched posts (placeholder)");
  //   } catch (e) {
  //     print("Error fetching posts: $e");
  //     // Handle error (e.g., show a message)
  //   }
  //   if (mounted) setState(() => _isLoadingPosts = false);
  // }

  // Future<void> _fetchArtisanReviews() async {
  //   if (!mounted) return;
  //   setState(() => _isLoadingReviews = true);
  //   try {
  //     // Example: _artisanReviews = await ReviewService.fetchReviewsForArtisan(widget.artisan.id);
  //     await Future.delayed(const Duration(seconds: 1));
  //     // _artisanReviews = [dummyReview1, dummyReview2]; // Populate with dummy reviews
  //     print("Fetched reviews (placeholder)");
  //   } catch (e) {
  //     print("Error fetching reviews: $e");
  //   }
  //   if (mounted) setState(() => _isLoadingReviews = false);
  // }


  // --- Helper Widget for Stat Items ---
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
            value.isNotEmpty ? value : "N/A", // Handle empty values
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

  // --- Action Handlers ---
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
      print('Could not launch $launchUri: $e');
    }
  }

  void _handleMessage() {
    print("Message action triggered for ${widget.artisan.fullname}");
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
            children: [ /* Your ListTiles for more options */ ],
          ),
        ),
      ),
    );
  }

  // --- Build Method ---
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
        // Fallback for just filename, assuming it's in 'assets/images/'
        displayImageProvider = AssetImage('assets/images/${widget.artisan.image}');
        print("Artisan image '${widget.artisan.image}' not a URL or full asset path, attempting 'assets/images/${widget.artisan.image}'");
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
                print("Edit my artisan profile: ${widget.artisan.fullname}");
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
                       print("Error loading profile image for ${widget.artisan.fullname}: $exception");
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
                    // Using Column for TarifCustom as they are not meant to be horizontally flexible here.
                    // If TarifCustom has Flexible/Expanded, it needs to be a direct child of Row/Column that provides flex.
                    // Wrap with Column if they should stack.
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
                          ? _buildPostesView(context, textTheme, colorScheme)
                          : _buildAvisView(context, textTheme, colorScheme),
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
    // TODO: Replace with dynamic data and ListView.builder if _isLoadingPosts is false and _artisanPosts is not empty.
    // if (_isLoadingPosts) return Center(key: const ValueKey('postes_loading'), child: CircularProgressIndicator());
    // if (_artisanPosts.isEmpty) return Center(key: const ValueKey('postes_empty'), child: Text("Aucun poste publié pour le moment."));
    return Column(
      key: const ValueKey('postes_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Postes de ${widget.artisan.fullname}", style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
        const SizedBox(height: 10),
        PosteCustom(img: Image.asset('assets/images/E02.png'), aime: '30', comment: '23'),
        const SizedBox(height: 12),
        PosteCustom(aime: '45', comment: '10'), // Example without image
      ],
    );
  }

  Widget _buildAvisView(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    // TODO: Replace with dynamic data and ListView.builder.
    // if (_isLoadingReviews) return Center(key: const ValueKey('avis_loading'), child: CircularProgressIndicator());
    // if (_artisanReviews.isEmpty) return Center(key: const ValueKey('avis_empty'), child: Text("Aucun avis pour le moment."));
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
              color: Colors.amber, // Or colorScheme.tertiary
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