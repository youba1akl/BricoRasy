// lib/screens/personnel_page/personnel_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/services/socket_service.dart';
import 'package:bricorasy/models/conversation.dart';
import 'package:bricorasy/screens/personnel_page/chat-screen.dart';
import 'package:bricorasy/widgets/message_custom.dart';
import 'package:bricorasy/widgets/poste_custom.dart';
import 'package:bricorasy/widgets/custom_container_ann.dart';

const String API_BASE_URL = "http://10.0.2.2:5000";

enum ActivityView { messages, postes, annonces }

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});
  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  ActivityView _currentView = ActivityView.messages;
  List<Conversation> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SocketService.init();
    _fetchConversations();
    SocketService.socket.on('newMessage', (data) {
      final idx = _conversations.indexWhere(
        (c) => c.annonceId == data['annonceId'],
      );
      if (idx != -1) {
        setState(() => _conversations[idx].lastMessage = data['content']);
      }
    });
  }

  Future<void> _fetchConversations() async {
    setState(() => _loading = true);
    try {
      final resp = await http.get(
        Uri.parse('$API_BASE_URL/api/messages/conversations'),
        headers: AuthService.authHeader,
      );
      if (resp.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(resp.body);
        setState(() {
          _conversations =
              jsonList.map((j) => Conversation.fromJson(j)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur ${resp.statusCode} au chargement des conversations',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).primaryColor;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final offColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    final segments = [
      const ButtonSegment(
        value: ActivityView.messages,
        label: Text('Messages'),
        icon: Icon(Icons.message_outlined),
      ),
      const ButtonSegment(
        value: ActivityView.postes,
        label: Text('Postes'),
        icon: Icon(Icons.grid_view_outlined),
      ),
      const ButtonSegment(
        value: ActivityView.annonces,
        label: Text('Annonces'),
        icon: Icon(Icons.list_alt_outlined),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Activité'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SegmentedButton<ActivityView>(
              segments: segments,
              selected: {_currentView},
              onSelectionChanged:
                  (newSel) => setState(() => _currentView = newSel.first),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) =>
                      states.contains(MaterialState.selected)
                          ? primaryColor.withOpacity(0.85)
                          : cardColor.withOpacity(0.5),
                ),
                foregroundColor: MaterialStateProperty.resolveWith(
                  (states) =>
                      states.contains(MaterialState.selected)
                          ? onPrimaryColor
                          : offColor,
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: primaryColor.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: _buildCurrentViewContent()),
        ],
      ),
    );
  }

  Widget _buildCurrentViewContent() {
    switch (_currentView) {
      case ActivityView.messages:
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
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => Chatscreen(
                            username: convo.peerName,
                            peerId: convo.peerId,
                            annonceId: convo.annonceId,
                          ),
                    ),
                  );
                  if (updated == true) _fetchConversations();
                },
              ),
            );
          },
        );

      case ActivityView.postes:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: const [
            PosteCustom(aime: '30', comment: '40'),
            SizedBox(height: 12),
            PosteCustom(aime: '55', comment: '12'),
          ],
        );

      case ActivityView.annonces:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: const [
            CustomContainerAnn(title: 'Bricolage urgent', description: ''),
            SizedBox(height: 12),
            CustomContainerAnn(title: 'Jardinier recherché', description: ''),
          ],
        );
    }
  }
}
