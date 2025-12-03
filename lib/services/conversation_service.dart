import '../models/conversation.dart';
import '../models/message.dart';

/// Service class to handle Conversation operations
class ConversationService {
  static final List<Conversation> _conversations = [];

  /// Creates a new conversation with generated ID and title
  static Conversation createConversation({String? title}) {
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'New Conversation',
      messages: [],
      lastUpdated: DateTime.now(),
    );
    _conversations.add(conversation);
    return conversation;
  }

  /// Gets all conversations sorted by last updated
  static List<Conversation> getAllConversations() {
    _conversations.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return List.unmodifiable(_conversations);
  }

  /// Gets a conversation by ID
  static Conversation? getConversationById(String id) {
    try {
      return _conversations.firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Adds a message to a conversation and updates lastUpdated
  static void addMessageToConversation(String conversationId, Message message) {
    final conversation = getConversationById(conversationId);
    if (conversation != null) {
      conversation.messages.add(message);
      conversation.lastUpdated = DateTime.now();
    }
  }

  /// Deletes a conversation
  static bool deleteConversation(String id) {
    final initialLength = _conversations.length;
    _conversations.removeWhere((conv) => conv.id == id);
    return _conversations.length < initialLength;
  }

  /// Updates conversation title
  static void updateConversationTitle(String conversationId, String newTitle) {
    final conversation = getConversationById(conversationId);
    if (conversation != null) {
      conversation.title = newTitle;
      conversation.lastUpdated = DateTime.now();
    }
  }
}