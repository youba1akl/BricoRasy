// lib/widgets/poste_custom.dart
import 'package:bricorasy/models/post.model.dart';
import 'package:bricorasy/screens/artisan/comment-screen.dart'; // For navigation to comments
import 'package:bricorasy/services/auth_services.dart'; // <-- IMPORT AUTHSERVICE
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:url_launcher/url_launcher.dart'; // For call and email

class PosteCustom extends StatefulWidget {
  final Post post;

  const PosteCustom({
    super.key,
    required this.post,
  });

  @override
  State<PosteCustom> createState() => _PosteCustomState();
}

class _PosteCustomState extends State<PosteCustom> {
  Future<void> _launchCaller(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Numéro de téléphone non fourni pour ce poste.')),
        );
      }
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de passer l\'appel au $phoneNumber')),
        );
      }
      if (kDebugMode) print('Could not launch $launchUri');
    }
  }

  Future<void> _launchEmail(String emailAddress) async {
    if (emailAddress.isEmpty) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adresse email non fournie pour ce poste.')),
        );
      }
      return;
    }
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: { // Using queryParameters for better encoding
        'subject': Uri.encodeComponent('Réponse à votre poste "${widget.post.title ?? ''}" sur BricoRasy'),
        'body': Uri.encodeComponent('Bonjour ${widget.post.artisan.fullname},\n\nConcernant votre poste "${widget.post.title ?? ''}"...\n\n'),
      }
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir l\'application email pour $emailAddress')),
        );
      }
      if (kDebugMode) print('Could not launch $launchUri');
    }
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final ImageProvider displayImageProvider;
    if (widget.post.images.isNotEmpty && widget.post.images.first.isNotEmpty) {
      if (widget.post.images.first.startsWith('http')) {
        displayImageProvider = NetworkImage(widget.post.images.first);
      } else if (widget.post.images.first.startsWith('assets/')){
        displayImageProvider = AssetImage(widget.post.images.first);
      }
      else {
        displayImageProvider = AssetImage('assets/images/${widget.post.images.first}');
        if (kDebugMode) print("PosteCustom: Image path '${widget.post.images.first}' is not a URL or full asset path, attempting 'assets/images/${widget.post.images.first}'. Ensure this asset exists.");
      }
    } else {
      displayImageProvider = const AssetImage('assets/images/E01.png'); // Your default placeholder
    }

    return Card(
      elevation: 2, // Slightly reduced elevation for a flatter look if desired
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.images.isNotEmpty)
            GestureDetector(
              onTap: () {
                if (kDebugMode) print("Image tapped for post: ${widget.post.title ?? 'Untitled'}");
                // TODO: Implement full-screen image view or gallery for multiple images
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: displayImageProvider,
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                       if (kDebugMode) print("Error loading post image: ${widget.post.images.first} - $exception");
                    },
                  ),
                ),
              ),
            ),
          if (widget.post.images.isEmpty)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5), // Subtler placeholder
                // Removed top-only border radius as Card clips content
              ),
              child: Icon(Icons.image_not_supported_outlined, size: 50, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.post.title != null && widget.post.title!.isNotEmpty)
                  Text(
                    widget.post.title!,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (widget.post.title != null && widget.post.title!.isNotEmpty)
                  const SizedBox(height: 6),
                Text(
                  "Publié par: ${widget.post.artisan.fullname}", // Artisan name from Post object
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                // Expandable description (optional enhancement)
                // For now, keeping it simple with maxLines
                Text(
                  widget.post.description,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.9)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16), // More space before buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (widget.post.phone != null && widget.post.phone!.isNotEmpty)
                      Expanded( // Make buttons take available space if needed
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call_outlined, size: 16),
                          label: const Text("Appeler"),
                          onPressed: () => _launchCaller(widget.post.phone!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    if (widget.post.phone != null && widget.post.phone!.isNotEmpty && widget.post.email != null && widget.post.email!.isNotEmpty)
                      const SizedBox(width: 10),
                    if (widget.post.email != null && widget.post.email!.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.email_outlined, size: 16),
                          label: const Text("Email"),
                          onPressed: () => _launchEmail(widget.post.email!),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.5, color: colorScheme.outlineVariant.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0), // Reduced vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.favorite_border, size: 20, color: colorScheme.onSurfaceVariant),
                  label: Text("0", style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)), // Placeholder
                  onPressed: () { /* TODO: Implement like */ },
                ),
                TextButton.icon(
                  icon: Icon(Icons.mode_comment_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                  label: Text("0", style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)), // Placeholder
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Commentscreen(
                          // TODO: Adapt Commentscreen to take postId
                          // postId: widget.post.id,
                          like: '0', // Placeholder
                          comment: '0', // Placeholder
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, size: 22, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      backgroundColor: colorScheme.surface,
                      builder: (context) => SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(leading: const Icon(Icons.bookmark_border_outlined), title: const Text('Enregistrer'), onTap: () {Navigator.pop(context); /* TODO */}),
                              ListTile(leading: const Icon(Icons.share_outlined), title: const Text('Partager'), onTap: () {Navigator.pop(context); /* TODO */}),
                              // Conditional Edit/Delete options
                              if (AuthService.currentUser?.id == widget.post.artisan.id) ...[
                                Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.3)),
                                ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Modifier'), onTap: () {Navigator.pop(context); /* TODO: Edit Post */}),
                                ListTile(leading: Icon(Icons.delete_outline, color: colorScheme.error), title: Text('Supprimer', style: TextStyle(color: colorScheme.error)), onTap: () {Navigator.pop(context); /* TODO: Delete Post */}),
                              ],
                              // Report option for other users' posts
                              if (AuthService.currentUser?.id != widget.post.artisan.id)
                                ListTile(leading: Icon(Icons.flag_outlined, color: colorScheme.error), title: Text('Signaler', style: TextStyle(color: colorScheme.error)), onTap: () {Navigator.pop(context); /* TODO: Report Post */}),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}