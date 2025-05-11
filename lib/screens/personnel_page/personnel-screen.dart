// lib/screens/personnel_page/personnel_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;

import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/services/socket_service.dart'; // Assuming you still use this for messages
import 'package:bricorasy/services/post_service.dart';   // <-- IMPORT POST SERVICE
import 'package:bricorasy/models/conversation.dart';
import 'package:bricorasy/models/post.model.dart';      // <-- IMPORT POST MODEL
import 'package:bricorasy/screens/personnel_page/chat-screen.dart';
import 'package:bricorasy/widgets/message_custom.dart';
import 'package:bricorasy/widgets/poste_custom.dart';
import 'package:bricorasy/screens/personnel_page/annonce_list_screen.dart';

// Use AuthService.baseUrl for consistency
const String API_BASE_URL = "http://10.0.2.2:5000"; // Or AuthService.baseUrl

enum ActivityView { messages, postes, annonces }

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});
  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  ActivityView _currentView = ActivityView.messages;

  // Message state
  List<Conversation> _conversations = [];
  bool _loadingMessages = true; // Specific loading for messages

  // Poste state
  List<Post> _myPosts = []; // <-- STATE FOR USER'S POSTS
  bool _loadingPosts = true;  // <-- SPECIFIC LOADING FOR POSTS

  // General loading for initial setup, can be refined
  // bool _isLoadingOverall = true; // You might not need this if handling specifics

  @override
  void initState() {
    super.initState();
    // Ensure AuthService.currentUser is available before fetching
    // This might be better handled by a top-level auth state listener
    if (AuthService.currentUser != null) {
      SocketService.init(); // Assuming this depends on user being logged in
      _fetchConversations();
      _fetchMyPosts(); // <-- FETCH MY POSTS

      // Socket listener for messages
      SocketService.socket.on('newMessage', (data) {
        if (!mounted) return;
        // Your existing newMessage handling for conversations
        final conversationIdFromJson = data['conversationId'] ?? data['annonceId']; // Adapt based on what backend sends
        final idx = _conversations.indexWhere((c) => c.annonceId == conversationIdFromJson || c.annonceId == conversationIdFromJson);
        if (idx != -1) {
          setState(() => _conversations[idx].lastMessage = data['content']);
        }
      });
    } else {
      // Handle case where user is not logged in but somehow reaches this screen
      // Or, this screen should be protected by an auth guard.
      if (kDebugMode) print("PersonnelScreen: User not logged in. Cannot fetch data.");
      setState(() {
        _loadingMessages = false;
        _loadingPosts = false;
      });
    }
  }

  Future<void> _fetchConversations() async {
    if (!mounted) return;
    setState(() => _loadingMessages = true);
    try {
      // Ensure API_BASE_URL is correct or use AuthService.baseUrl
      final resp = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/messages/conversations'), // Using AuthService.baseUrl
        headers: AuthService.authHeader,
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(resp.body);
        setState(() {
          _conversations = jsonList.map((j) => Conversation.fromJson(j)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur ${resp.statusCode} au chargement des conversations'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur réseau (conversations): $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMessages = false);
    }
  }

  Future<void> _fetchMyPosts() async {
    if (AuthService.currentUser == null || !AuthService.currentUser!.isArtisan) {
      if (kDebugMode) print("User is not an artisan or not logged in, skipping post fetch.");
      if (mounted) setState(() => _loadingPosts = false);
      return;
    }
    if (!mounted) return;
    setState(() => _loadingPosts = true);
    try {
      _myPosts = await PostService.fetchPostsByArtisanId(AuthService.currentUser!.id);
      if (kDebugMode) print("Fetched ${_myPosts.length} posts for current user.");
    } catch (e) {
      if (kDebugMode) print("Error fetching my posts: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement de vos postes: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  void _onSegmentSelectionChanged(Set<ActivityView> newSelection) {
    if (mounted) {
      setState(() {
        _currentView = newSelection.first;
        // Fetch data if switching to a tab and its data hasn't been loaded or needs refresh
        if (_currentView == ActivityView.postes && _myPosts.isEmpty && !_loadingPosts) {
          _fetchMyPosts();
        }
        // Add similar logic for messages if needed, though it fetches in initState
        // For annonces, AnnonceListScreen handles its own data fetching
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme; // Use ColorScheme

    final segments = [
      ButtonSegment(
        value: ActivityView.messages,
        label: const Text('Messages'),
        icon: Icon(Icons.chat_bubble_outline_rounded, color: _currentView == ActivityView.messages ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
      ),
      // Only show "Postes" tab if the user is an artisan
      if (AuthService.isUserArtisan)
        ButtonSegment(
          value: ActivityView.postes,
          label: const Text('Mes Postes'),
          icon: Icon(Icons.dynamic_feed_outlined, color: _currentView == ActivityView.postes ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
        ),
      ButtonSegment(
        value: ActivityView.annonces,
        label: const Text('Mes Annonces'),
        icon: Icon(Icons.list_alt_rounded, color: _currentView == ActivityView.annonces ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Activité'),
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button if it's a main tab screen
        elevation: 0.5,
        backgroundColor: colorScheme.surfaceContainerLow,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SegmentedButton<ActivityView>(
              segments: segments,
              selected: {_currentView},
              onSelectionChanged: _onSegmentSelectionChanged,
              style: SegmentedButton.styleFrom( // More Material 3 like styling
                backgroundColor: colorScheme.surfaceContainerHighest,
                selectedBackgroundColor: colorScheme.primaryContainer,
                selectedForegroundColor: colorScheme.onPrimaryContainer,
                foregroundColor: colorScheme.onSurfaceVariant, // Color for unselected text and icon
                // side: BorderSide(color: colorScheme.outlineVariant), // Optional border
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              showSelectedIcon: false, // Icons are already in labels
            ),
          ),
          // Conditional LinearProgressIndicator for specific views
          if ((_currentView == ActivityView.messages && _loadingMessages) ||
              (_currentView == ActivityView.postes && _loadingPosts))
            const LinearProgressIndicator(),
          Expanded(child: _buildCurrentViewContent()),
        ],
      ),
    );
  }

  Widget _buildCurrentViewContent() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (_currentView) {
      case ActivityView.messages:
        if (_loadingMessages) return const SizedBox.shrink(); // Already handled by LinearProgressIndicator
        if (_conversations.isEmpty) return Center(child: Text("Aucun message.", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)));
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _conversations.length,
          itemBuilder: (ctx, i) {
            final convo = _conversations[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MessageCustom(
                username: convo.peerName,
                lastmssg: convo.lastMessage,
                onTap: () async {
                  // ... your existing navigation to Chatscreen ...
                },
              ),
            );
          },
        );

      case ActivityView.postes:
        if (!AuthService.isUserArtisan) { // Should not happen if tab is hidden, but good check
            return Center(child: Text("Connectez-vous en tant qu'artisan pour voir vos postes.", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)));
        }
        if (_loadingPosts) return const SizedBox.shrink(); // Already handled by LinearProgressIndicator
        if (_myPosts.isEmpty) return Center(child: Text("Vous n'avez publié aucun poste.", style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _myPosts.length,
          itemBuilder: (context, index) {
            final post = _myPosts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PosteCustom(post: post), // Pass the Post object
            );
          },
        );

      case ActivityView.annonces:
        return AnnonceListScreen(); // This screen handles its own loading/empty states
    }
  }

  @override
  void dispose() {
    // Consider if SocketService needs explicit dispose if not used elsewhere
    // SocketService.dispose(); // If SocketService manages its own lifecycle for this screen
    super.dispose();
  }
}