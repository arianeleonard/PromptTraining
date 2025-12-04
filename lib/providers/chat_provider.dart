import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../models/chat_status.dart';
import '../models/chat_event.dart';
import '../services/thread_naming_service.dart';
import '../core/config.dart';
import '../services/chat_repository.dart';
import '../services/openrouter_service.dart';
  import '../services/prompt_evaluator_service.dart';
  import '../models/prompt_evaluation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/prompt_history_entry.dart';
import '../models/user_role.dart';
import '../l10n/app_localizations.dart';

/// Core state management for conversations, messages, and AI streaming.
/// Uses Repository pattern to abstract AI service backends.
class ChatProvider extends ChangeNotifier {
  final List<Conversation> _conversations = [];
  String? _selectedConversationId;
  ChatStatus _status = ChatStatus.idle;
  String _currentModelId = 'openai/gpt-4o-mini';
  final ThreadNamingService _namingService;
  final ChatRepository _chatRepository;

  // For canceling streaming requests
  bool _shouldCancelStream = false;

    // Prompt evaluator service
    final PromptEvaluatorService _evaluator = PromptEvaluatorService();

  /// Creates a new ChatProvider instance
  ///
  /// **Parameters:**
  /// - `namingService`: Optional custom service for generating thread names
  /// - `chatRepository`: Optional custom repository for AI interactions
  ///
  /// **Default Behavior:**
  /// - Uses `ThreadNamingService()` for automatic thread naming
  /// - Selects repository based on `AppConfig.backendProvider`:
  ///   - `direct`: OpenRouter client calls (dev only)
  ///   - `firebase`: Firebase Function proxy (production)
  ///   - `supabase`: Supabase Edge Function proxy (production)
  ChatProvider({
    ThreadNamingService? namingService,
    ChatRepository? chatRepository,
  }) : _namingService = namingService ?? ThreadNamingService(),
       _chatRepository = chatRepository ?? _defaultRepository() {
    _init();
  }

  // Schedule async loads for local-only persistence
  void _init() {
    Future.microtask(() async {
      await _loadUiPrefs();
      await _loadConversations();
      _initHistory();
      notifyListeners();
    });
  }

  // --- Prompt history (persisted locally) ---
  static const String _historyPrefsKey = 'prompt_history_v1';
  final List<PromptHistoryEntry> _promptHistory = [];
  bool _historyLoaded = false;

  // Load history shortly after construction
  // ignore: prefer_void_to_null
  void _initHistory() {
    Future.microtask(_loadPromptHistory);
  }

  // Call initializer
  // Using initializer list is not allowed for async; call here lazily.
  // We trigger immediately in the first access as well.


  static ChatRepository _defaultRepository() {
    switch (AppConfig.backendProvider) {
      case BackendProvider.direct:
        return OpenRouterChatRepository(OpenRouterService());
      case BackendProvider.firebase:
        return FirebaseChatRepository(AppConfig.firebaseProxyUrl);
      case BackendProvider.supabase:
        return SupabaseChatRepository(AppConfig.supabaseEdgeFunctionUrl);
    }
  }

  // Draft and focus management for prompt input reinjection
  String _inputDraft = '';
  int _draftVersion = 0;
  int _focusTick = 0;

  // Current language code affecting AI instructions and assistant section headings
  String _languageCode = 'en';
  
  // Current user role for tailoring AI suggestions
  UserRole _userRole = UserRole.strategist;
  static const List<UserRole> _availableRoles = <UserRole>[
    UserRole.strategist,
    UserRole.designer,
    UserRole.developer,
    UserRole.marketing,
    UserRole.projectManager,
    UserRole.productOwner,
    UserRole.finance,
  ];

  String get inputDraft => _inputDraft;
  int get draftVersion => _draftVersion;
  int get focusTick => _focusTick;
  String get languageCode => _languageCode;
  UserRole get userRole => _userRole;
  List<UserRole> get availableRoles => List.unmodifiable(_availableRoles);

  /// Update the language code used for AI feedback ('en' or 'fr').
  void setLanguageCode(String code) {
    final lc = code.toLowerCase();
    if (lc != 'en' && lc != 'fr') return;
    if (_languageCode == lc) return;
    _languageCode = lc;
    // No UI depends directly on this except future sends; no immediate notify needed,
    // but we can notify in case some header previews depend on it.
    notifyListeners();
    _saveUiPrefs();
  }

  /// Update the user's role/work context for tailoring AI suggestions.
  void setUserRole(UserRole role) {
    if (_userRole == role) return;
    if (!_availableRoles.contains(role)) return;
    _userRole = role;
    notifyListeners();
    _saveUiPrefs();
  }

  /// Set the prompt input draft programmatically. Optionally request focus.
  void setInputDraft(String text, {bool focus = false}) {
    _inputDraft = text;
    _draftVersion++; // signal a new draft injection event
    if (focus) {
      _focusTick++; // signal focus request
    }
    notifyListeners();
  }

  /// Request focusing the input without changing the draft text.
  void focusInput() {
    _focusTick++;
    notifyListeners();
  }

  List<Conversation> get conversations {
    // Sort conversations by lastUpdated, most recent first
    final sortedConversations = List<Conversation>.from(_conversations);
    sortedConversations.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sortedConversations;
  }

  String? get selectedConversationId => _selectedConversationId;
  ChatStatus get status => _status;
  String get currentModelId => _currentModelId;
  List<PromptHistoryEntry> get promptHistory {
    if (!_historyLoaded) {
      _initHistory();
    }
    final list = List<PromptHistoryEntry>.from(_promptHistory);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<PromptHistoryEntry> get favoritePrompts {
    final list = promptHistory.where((e) => e.isFavorite).toList(growable: false);
    return list;
  }

  Conversation? get selectedConversation =>
      _selectedConversationId != null
          ? _conversations
              .where((c) => c.id == _selectedConversationId)
              .firstOrNull
          : null;

  List<Message> get messages => selectedConversation?.messages ?? [];

  void setStatus(ChatStatus status) {
    _status = status;
    notifyListeners();
  }

  void stopGeneration() {
    if (_status == ChatStatus.streaming) {
      _shouldCancelStream = true;
      _status = ChatStatus.idle;
      notifyListeners();
    }
  }

  void selectConversation(String? conversationId) {
    _selectedConversationId = conversationId;
    notifyListeners();
    _saveSelectedConversationId();
  }

  void createNewConversation() {
    // Create conversation with empty title so UI can localize label dynamically
    final newConversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      messages: [],
      lastUpdated: DateTime.now(),
    );
    _conversations.add(newConversation);
    _selectedConversationId = newConversation.id;
    notifyListeners();
    _saveConversations();
    _saveSelectedConversationId();
  }

  void setModel(String modelId) {
    _currentModelId = modelId;
    notifyListeners();
    _saveUiPrefs();
  }

  void deleteConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    if (_selectedConversationId == conversationId) {
      _selectedConversationId =
          _conversations.isNotEmpty ? _conversations.first.id : null;
    }
    notifyListeners();
    _saveConversations();
    _saveSelectedConversationId();
  }

  /// Sends a user message and generates an AI response
  ///
  /// **Core Flow:**
  /// 1. Validates input and prevents concurrent sends
  /// 2. Creates new conversation if none selected
  /// 3. Adds user message to conversation
  /// 4. Generates thread title (first message only)
  /// 5. Streams AI response in real-time
  ///
  /// **Parameters:**
  /// - `content`: User's message text (trimmed automatically)
  /// - `modelId`: AI model to use (e.g., 'openai/gpt-4o-mini')
  ///
  /// **State Changes:**
  /// - Updates `_status` to `streaming` during AI response
  /// - Modifies `_conversations` with new messages
  /// - Triggers `notifyListeners()` for UI updates
  ///
  /// **Error Handling:**
  /// - Network failures show error message in chat
  /// - API key issues trigger configuration prompts (or mock mode)
  /// - Streaming can be cancelled via `stopGeneration()`
  ///
  /// **Mock Mode:**
  /// When no API key is configured, generates realistic mock responses
  /// with simulated streaming delays for demonstration purposes.
  Future<void> sendMessage(String content, String modelId, {String? context}) async {
    if (content.trim().isEmpty) return;

    // Prevent duplicate sends
    if (_status != ChatStatus.idle) return;

    // Create conversation if none selected
    if (_selectedConversationId == null) {
      createNewConversation();
    }

    final conversation = selectedConversation;
    if (conversation == null) return;

    // 1. Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
      context: context?.trim().isEmpty == true ? null : context?.trim(),
    );

    conversation.messages.add(userMessage);

    // Update conversation title if it's the first message
    if (conversation.messages.length == 1) {
      _generateTitle(content, conversation);
    }

    conversation.lastUpdated = DateTime.now();
    notifyListeners();
    _saveConversations();

    // 2. Evaluate the prompt and attach results, then stream a
    // conversation-aware coaching reply from the main assistant.
    try {
      setStatus(ChatStatus.submitting);
      final eval = await _evaluateAndAttach(userMessage, conversation, modelId);

      // Save to prompt history
      try {
        final record = PromptHistoryEntry.fromMessageEval(
          id: userMessage.id,
          timestamp: userMessage.timestamp,
          prompt: userMessage.content,
          context: userMessage.context,
          eval: eval,
          languageCode: _languageCode,
          // Store a human-readable label in history (canonical English)
          userRole: _userRole.canonicalLabel,
        );
        await _addHistoryRecord(record);
      } catch (e) {
        debugPrint('Failed to add prompt history record: $e');
      }

      // 3. After attaching the evaluation, generate a streaming AI
      // coaching response using the full conversation history.
      await _generateAiResponse(
        conversation,
        modelId,
        // Use the global prompt-trainer persona; it already knows to
        // behave as a conversation-aware AI prompt trainer.
        systemPrompt: AppConfig.mainAssistantSystemPrompt,
      );
    } catch (e) {
      debugPrint('Failed to handle sendMessage flow: $e');
      // Surface an error assistant message
      final l10n = AppLocalizations(Locale(_languageCode));
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: '❌ ${l10n.errorEvaluatingPrompt}\n\n${e.toString()}',
        timestamp: DateTime.now(),
      );
      conversation.messages.add(errorMessage);
      notifyListeners();
      _saveConversations();
    } finally {
      // _generateAiResponse manages status during streaming; when this
      // whole flow finishes we return to idle.
      setStatus(ChatStatus.idle);
    }
  }

  Future<PromptEvaluation> _evaluateAndAttach(
    Message userMessage,
    Conversation conversation,
    String modelId,
  ) async {
    try {
        final eval = await _evaluator.evaluate(
        prompt: userMessage.content,
        context: userMessage.context,
        modelId: modelId,
        feedbackMemory: _buildPreferenceSummary(conversation),
        languageCode: _languageCode,
          userRole: _userRole,
      );

      final idx = conversation.messages.indexWhere((m) => m.id == userMessage.id);
      if (idx != -1) {
        conversation.messages[idx] = Message(
          id: userMessage.id,
          role: userMessage.role,
          content: userMessage.content,
          timestamp: userMessage.timestamp,
          context: userMessage.context,
          evaluation: eval,
        );
        conversation.lastUpdated = DateTime.now();
        notifyListeners();
        _saveConversations();
      }
      return eval;
    } catch (e) {
      debugPrint('Failed to evaluate prompt: $e');
      // Propagate a fallback heuristic result so assistant can still reply
      final l10n = AppLocalizations(Locale(_languageCode));
      final fallback = PromptEvaluation(score: 6, explanation: l10n.heuristicFallback);
      // Also attach fallback to the user message for consistent UI
      final idx = conversation.messages.indexWhere((m) => m.id == userMessage.id);
      if (idx != -1) {
        conversation.messages[idx] = Message(
          id: userMessage.id,
          role: userMessage.role,
          content: userMessage.content,
          timestamp: userMessage.timestamp,
          context: userMessage.context,
          evaluation: fallback,
        );
        conversation.lastUpdated = DateTime.now();
        notifyListeners();
        _saveConversations();
      }
      return fallback;
    }
  }

  // --- Feedback capture and preference shaping ---

  /// Set or clear thumbs-up feedback on an assistant message
  void setMessageThumbsUp(String messageId, bool selected) {
    final conv = selectedConversation;
    if (conv == null) return;
    final idx = conv.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = conv.messages[idx];
    if (msg.role != MessageRole.assistant) return;

    final newFeedback = selected
        ? MessageFeedback(
            reaction: FeedbackReaction.up,
            reactedAt: DateTime.now(),
          )
        : null; // remove feedback when unselected

    conv.messages[idx] = Message(
      id: msg.id,
      role: msg.role,
      content: msg.content,
      timestamp: msg.timestamp,
      context: msg.context,
      evaluation: msg.evaluation,
      feedback: newFeedback,
    );
    conv.lastUpdated = DateTime.now();
    notifyListeners();
    _saveConversations();
  }

  /// Set or clear thumbs-down feedback on an assistant message
  void setMessageThumbsDown(
    String messageId,
    bool selected, {
    DownReason? reason,
    String? notes,
  }) {
    final conv = selectedConversation;
    if (conv == null) return;
    final idx = conv.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = conv.messages[idx];
    if (msg.role != MessageRole.assistant) return;

    final newFeedback = selected
        ? MessageFeedback(
            reaction: FeedbackReaction.down,
            downReason: reason,
            notes: (notes?.trim().isEmpty == true) ? null : notes?.trim(),
            reactedAt: DateTime.now(),
          )
        : null; // remove feedback when unselected

    conv.messages[idx] = Message(
      id: msg.id,
      role: msg.role,
      content: msg.content,
      timestamp: msg.timestamp,
      context: msg.context,
      evaluation: msg.evaluation,
      feedback: newFeedback,
    );
    conv.lastUpdated = DateTime.now();
    notifyListeners();
    _saveConversations();
  }

  /// Build a short summary of user feedback within this conversation to guide future suggestions.
  String? _buildPreferenceSummary(Conversation conversation) {
    final assistantMsgs = conversation.messages.where((m) => m.role == MessageRole.assistant);
    int ups = 0, downs = 0, vague = 0, incorrect = 0, other = 0;
    final notes = <String>[];
    for (final m in assistantMsgs) {
      final f = m.feedback;
      if (f == null) continue;
      switch (f.reaction) {
        case FeedbackReaction.up:
          ups++;
          break;
        case FeedbackReaction.down:
          downs++;
          switch (f.downReason) {
            case DownReason.vague:
              vague++;
              break;
            case DownReason.incorrect:
              incorrect++;
              break;
            case DownReason.other:
              other++;
              break;
            case null:
              break;
          }
          if ((f.notes ?? '').isNotEmpty) notes.add(f.notes!.trim());
          break;
        case FeedbackReaction.none:
          break;
      }
    }

    if (ups == 0 && downs == 0) return null; // nothing to bias on yet

    final buf = StringBuffer();
    buf.writeln('USER_FEEDBACK_MEMORY:');
    buf.writeln('- Likes: $ups, Dislikes: $downs');
    if (downs > 0) {
      final reasons = <String>[];
      if (vague > 0) reasons.add('$vague× too vague');
      if (incorrect > 0) reasons.add('$incorrect× incorrect information');
      if (other > 0) reasons.add('$other× other issues');
      if (reasons.isNotEmpty) buf.writeln('- Frequent issues: ${reasons.join(', ')}');
    }
    if (notes.isNotEmpty) {
      buf.writeln('- User notes (samples):');
      for (final n in notes.take(3)) {
        buf.writeln('  • "$n"');
      }
    }
    buf.writeln('- Please tailor improvement suggestions to address the above.');
    buf.writeln('- If issues include "too vague", be concrete with examples and rewrites.');
    buf.writeln('- If issues include "incorrect", emphasize factual accuracy and safe phrasing.');
    return buf.toString();
  }

  String _buildEvaluationAssistantMarkdown(PromptEvaluation eval) {
    // The evaluator already returns markdown in `explanation`, including
    // bullet points. Forward it directly so bullets render exactly once.
    return eval.explanation.trim();
  }

  Future<void> _generateTitle(String content, Conversation conversation) async {
    try {
      // Use AI naming service for better titles
      final aiGeneratedTitle = await _namingService.generateThreadName(content);
      conversation.title = aiGeneratedTitle;
      conversation.lastUpdated = DateTime.now();
      notifyListeners();
      _saveConversations();
    } catch (e) {
      // Fallback to simple title generation if AI service fails
      final words = content.split(' ');
      conversation.title =
          words.length <= 4 ? content : '${words.take(4).join(' ')}...';
      notifyListeners();
      _saveConversations();
    }
  }

  Future<void> _generateAiResponse(
    Conversation conversation,
    String modelId,
    {String? systemPrompt}
  ) async {
    _shouldCancelStream = false;
    setStatus(ChatStatus.streaming);
    notifyListeners();

    try {
      // Stream response via repository
      final responseStream = _chatRepository.streamChat(
        history: conversation.messages,
        modelId: modelId,
        // Always fall back to the global prompt-trainer persona so the
        // assistant behaves as a conversation-aware prompt coach.
        systemPrompt: systemPrompt ?? AppConfig.mainAssistantSystemPrompt,
      );

      // Create AI message and start streaming into it
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now(),
      );

      conversation.messages.add(aiMessage);
      conversation.lastUpdated = DateTime.now();
      notifyListeners();

      String accumulatedContent = '';

      await for (final event in responseStream) {
        if (_shouldCancelStream) break;

        if (event is ResponseChunk) {
          accumulatedContent += event.text;
        } else if (event is ChatError) {
          throw Exception(event.message);
        } else if (event is Finished) {
          break;
        }

        // Update the AI message by replacing the last message
        conversation.messages[conversation.messages.length - 1] = Message(
          id: aiMessage.id,
          role: MessageRole.assistant,
          content: accumulatedContent,
          timestamp: aiMessage.timestamp,
        );
        notifyListeners();
        _saveConversations();
      }

      if (_shouldCancelStream && accumulatedContent.isNotEmpty) {
        conversation.messages[conversation.messages.length - 1] = Message(
          id: aiMessage.id,
          role: MessageRole.assistant,
          content: '$accumulatedContent\n\n${AppLocalizations(Locale(_languageCode)).responseStoppedByUser}',
          timestamp: aiMessage.timestamp,
        );
        notifyListeners();
        _saveConversations();
      }
    } catch (e) {
      // Replace placeholder if it's still empty, otherwise add error message
      if (conversation.messages.isNotEmpty &&
          conversation.messages.last.role == MessageRole.assistant &&
          conversation.messages.last.content.isEmpty) {
        final l10n = AppLocalizations(Locale(_languageCode));
        conversation.messages[conversation.messages.length - 1] = Message(
          id: conversation.messages.last.id,
          role: MessageRole.assistant,
          content:
              '❌ ${l10n.errorBold}: ${e.toString()}\n\n${l10n.checkApiKeyAndRetry}',
          timestamp: DateTime.now(),
        );
      } else {
        final l10n = AppLocalizations(Locale(_languageCode));
        final errorMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content:
              '❌ ${l10n.errorBold}: ${e.toString()}\n\n${l10n.checkApiKeyAndRetry}',
          timestamp: DateTime.now(),
        );
        conversation.messages.add(errorMessage);
      }
      _saveConversations();
    }

    setStatus(ChatStatus.idle);
    conversation.lastUpdated = DateTime.now();
    notifyListeners();
    _saveConversations();
  }

  // --- Prompt history persistence ---
  Future<void> _loadPromptHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyPrefsKey);
      if (raw == null || raw.trim().isEmpty) {
        _historyLoaded = true;
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _historyLoaded = true;
        return;
      }
      final sanitized = <PromptHistoryEntry>[];
      for (final item in decoded) {
        try {
          if (item is Map<String, dynamic>) {
            sanitized.add(PromptHistoryEntry.fromJson(item));
          } else if (item is Map) {
            sanitized.add(PromptHistoryEntry.fromJson(Map<String, dynamic>.from(item)));
          } else {
            // skip invalid entry
          }
        } catch (e) {
          debugPrint('Skipping corrupted history entry: $e');
        }
      }
      _promptHistory
        ..clear()
        ..addAll(sanitized);
      _historyLoaded = true;
      // Write back sanitized list
      await _savePromptHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load prompt history: $e');
      _historyLoaded = true; // avoid retry loops
    }
  }

  Future<void> _savePromptHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _promptHistory.map((e) => e.toJson()).toList(growable: false);
      await prefs.setString(_historyPrefsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Failed to save prompt history: $e');
    }
  }

  Future<void> _addHistoryRecord(PromptHistoryEntry entry) async {
    if (!_historyLoaded) {
      await _loadPromptHistory();
    }
    _promptHistory.add(entry);
    // Trim to last N entries if needed
    if (_promptHistory.length > 500) {
      _promptHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _promptHistory.removeRange(500, _promptHistory.length);
    }
    await _savePromptHistory();
    notifyListeners();
  }

  /// Set favorite flag for a history entry by id.
  Future<void> setHistoryFavorite(String entryId, bool isFavorite) async {
    if (!_historyLoaded) {
      await _loadPromptHistory();
    }
    final idx = _promptHistory.indexWhere((e) => e.id == entryId);
    if (idx == -1) return;
    _promptHistory[idx] = _promptHistory[idx].copyWith(isFavorite: isFavorite);
    await _savePromptHistory();
    notifyListeners();
  }

  // --- Local persistence for conversations and UI prefs ---
  static const String _conversationsPrefsKey = 'conversations_v1';
  static const String _selectedConversationPrefsKey = 'selected_conversation_id_v1';
  static const String _prefsLanguageKey = 'prefs_language_v1';
  static const String _prefsUserRoleKey = 'prefs_user_role_v1';
  static const String _prefsModelKey = 'prefs_model_v1';

  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_conversationsPrefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final loaded = <Conversation>[];
      for (final item in decoded) {
        try {
          if (item is Map<String, dynamic>) {
            loaded.add(Conversation.fromJson(item));
          } else if (item is Map) {
            loaded.add(Conversation.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (e) {
          debugPrint('Skipping corrupted conversation: $e');
        }
      }
      _conversations
        ..clear()
        ..addAll(loaded);
      // restore selected conversation
      final selectedId = prefs.getString(_selectedConversationPrefsKey);
      if (selectedId != null && _conversations.any((c) => c.id == selectedId)) {
        _selectedConversationId = selectedId;
      } else {
        _selectedConversationId = _conversations.isNotEmpty ? _conversations.first.id : null;
      }
    } catch (e) {
      debugPrint('Failed to load conversations: $e');
    }
  }

  Future<void> _saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _conversations.map((c) => c.toJson()).toList(growable: false);
      await prefs.setString(_conversationsPrefsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Failed to save conversations: $e');
    }
  }

  Future<void> _saveSelectedConversationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = _selectedConversationId;
      if (id == null) {
        await prefs.remove(_selectedConversationPrefsKey);
      } else {
        await prefs.setString(_selectedConversationPrefsKey, id);
      }
    } catch (e) {
      debugPrint('Failed to save selected conversation id: $e');
    }
  }

  Future<void> _loadUiPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_prefsLanguageKey);
      if (lang != null && (lang == 'en' || lang == 'fr')) {
        _languageCode = lang;
      }
      final role = prefs.getString(_prefsUserRoleKey);
      if (role != null) {
        final parsed = UserRoleUtils.tryParse(role);
        if (parsed != null) {
          _userRole = parsed;
        }
      }
      final model = prefs.getString(_prefsModelKey);
      if (model != null && model.isNotEmpty) {
        _currentModelId = model;
      }
    } catch (e) {
      debugPrint('Failed to load UI prefs: $e');
    }
  }

  Future<void> _saveUiPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsLanguageKey, _languageCode);
      // Persist as enum.name; loader supports legacy labels too
      await prefs.setString(_prefsUserRoleKey, _userRole.name);
      await prefs.setString(_prefsModelKey, _currentModelId);
    } catch (e) {
      debugPrint('Failed to save UI prefs: $e');
    }
  }
}

