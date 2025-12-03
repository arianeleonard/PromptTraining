import 'prompt_evaluation.dart';
import 'package:flutter/foundation.dart';

enum MessageRole { user, assistant }

/// A single chat message with role, content, and timestamp.
/// Content supports Markdown formatting.
///
/// Optional [context] lets the user attach notes/background information to their
/// prompt. When present on user messages, this can be sent to the model as a
/// separate system prompt and is also rendered in the UI for clarity.
class Message {
  final String id;
  final MessageRole role;
  final String content; // markdown/plaintext; rich parts later
  final DateTime timestamp;
  final String? context; // Optional notes/background for the prompt
  final PromptEvaluation? evaluation; // Optional quality score and explanation for user prompts
  final MessageFeedback? feedback; // Optional like/dislike and notes captured on assistant replies

  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.context,
    this.evaluation,
    this.feedback,
  });

  // --- Serialization ---
  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      final roleStr = (json['role'] ?? '').toString().toLowerCase();
      final role = switch (roleStr) {
        'assistant' => MessageRole.assistant,
        _ => MessageRole.user,
      };

      PromptEvaluation? eval;
      final rawEval = json['evaluation'];
      if (rawEval is Map<String, dynamic>) {
        eval = PromptEvaluation.fromJson(rawEval);
      } else if (rawEval is Map) {
        eval = PromptEvaluation.fromJson(Map<String, dynamic>.from(rawEval));
      }

      MessageFeedback? fb;
      final rawFb = json['feedback'];
      if (rawFb is Map<String, dynamic>) {
        fb = MessageFeedback.fromJson(rawFb);
      } else if (rawFb is Map) {
        fb = MessageFeedback.fromJson(Map<String, dynamic>.from(rawFb));
      }

      return Message(
        id: (json['id'] ?? '').toString(),
        role: role,
        content: (json['content'] ?? '').toString(),
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(
              (json['ts'] is int) ? json['ts'] as int : DateTime.now().millisecondsSinceEpoch,
            ),
        context: (json['context']?.toString().trim().isEmpty == true)
            ? null
            : json['context']?.toString(),
        evaluation: eval,
        feedback: fb,
      );
    } catch (e) {
      debugPrint('Failed to parse Message: $e');
      return Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: '',
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role == MessageRole.assistant ? 'assistant' : 'user',
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        if (context != null) 'context': context,
        if (evaluation != null) 'evaluation': evaluation!.toJson(),
        if (feedback != null) 'feedback': feedback!.toJson(),
      };
}

/// Type of quick reaction a user can leave on an assistant message
enum FeedbackReaction { none, up, down }

/// Specific reason chosen for a thumbs-down
enum DownReason { vague, incorrect, other }

/// Captures user feedback on an assistant message
class MessageFeedback {
  final FeedbackReaction reaction;
  final DownReason? downReason;
  final String? notes;
  final DateTime reactedAt;

  const MessageFeedback({
    required this.reaction,
    this.downReason,
    this.notes,
    required this.reactedAt,
  });

  MessageFeedback copyWith({
    FeedbackReaction? reaction,
    DownReason? downReason,
    String? notes,
    DateTime? reactedAt,
  }) {
    return MessageFeedback(
      reaction: reaction ?? this.reaction,
      downReason: downReason ?? this.downReason,
      notes: notes ?? this.notes,
      reactedAt: reactedAt ?? this.reactedAt,
    );
  }

  // --- Serialization ---
  factory MessageFeedback.fromJson(Map<String, dynamic> json) {
    final reactStr = (json['reaction'] ?? '').toString().toLowerCase();
    final reaction = switch (reactStr) {
      'up' => FeedbackReaction.up,
      'down' => FeedbackReaction.down,
      _ => FeedbackReaction.none,
    };
    final reasonStr = (json['downReason'] ?? '').toString().toLowerCase();
    final DownReason? downReason = switch (reasonStr) {
      'vague' => DownReason.vague,
      'incorrect' => DownReason.incorrect,
      'other' => DownReason.other,
      _ => null,
    };
    return MessageFeedback(
      reaction: reaction,
      downReason: downReason,
      notes: (json['notes']?.toString().trim().isEmpty == true) ? null : json['notes']?.toString(),
      reactedAt: DateTime.tryParse(json['reactedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'reaction': switch (reaction) {
          FeedbackReaction.up => 'up',
          FeedbackReaction.down => 'down',
          FeedbackReaction.none => 'none',
        },
        if (downReason != null)
          'downReason': switch (downReason!) {
            DownReason.vague => 'vague',
            DownReason.incorrect => 'incorrect',
            DownReason.other => 'other',
          },
        if (notes != null) 'notes': notes,
        'reactedAt': reactedAt.toIso8601String(),
      };
}