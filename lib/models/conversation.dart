import 'message.dart';
import 'package:flutter/foundation.dart';

/// A conversation containing multiple messages with auto-generated title.
class Conversation {
  final String id;
  String title; // Mutable - auto-generated or user-customized
  final List<Message> messages; // Mutable - messages added during chat
  DateTime lastUpdated; // Mutable - updated on each interaction

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.lastUpdated,
  });

  // --- Serialization ---
  factory Conversation.fromJson(Map<String, dynamic> json) {
    try {
      final rawMsgs = json['messages'];
      final msgs = <Message>[];
      if (rawMsgs is List) {
        for (final m in rawMsgs) {
          try {
            if (m is Map<String, dynamic>) {
              msgs.add(Message.fromJson(m));
            } else if (m is Map) {
              msgs.add(Message.fromJson(Map<String, dynamic>.from(m)));
            }
          } catch (e) {
            debugPrint('Skipping corrupted message: $e');
          }
        }
      }
      return Conversation(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? 'Untitled').toString(),
        messages: msgs,
        lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Failed to parse Conversation: $e');
      return Conversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Untitled',
        messages: const [],
        lastUpdated: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(growable: false),
        'lastUpdated': lastUpdated.toIso8601String(),
      };
}