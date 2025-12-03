import 'dart:async';
import '../models/message.dart';
import '../models/chat_event.dart';
import 'openrouter_service.dart';

/// Repository pattern for AI chat backends with event-based streaming.

/// Abstract interface for AI chat backends.
/// - **Streaming**: Must yield `ChatEvent`s as they occur
/// - **Error Handling**: Convert all errors to `ChatError` events
/// - **Completion**: Always end with `Finished` event on success
/// - **Cancellation**: Handle stream cancellation gracefully
///
/// ## Event Flow Pattern:
/// ```
/// [Start] → ResponseChunk* → Finished
///            ↓
///         ChatError (on failure)
/// ```
///
/// ## Custom Implementation Example:
/// ```dart
/// class MyCustomChatRepository implements ChatRepository {
///   @override
///   Stream<ChatEvent> streamChat({...}) async* {
///     try {
///       // Your custom AI service integration here
///       yield* myService.streamResponse(...).map(ResponseChunk.new);
///       yield Finished();
///     } catch (e) {
///       yield ChatError(e.toString());
///     }
///   }
/// }
/// ```
abstract class ChatRepository {
  /// Streams AI responses as events for real-time chat
  ///
  /// **Parameters:**
  /// - `history`: Previous messages for context
  /// - `modelId`: AI model identifier (e.g., 'openai/gpt-4o-mini')
  /// - `systemPrompt`: Optional system instructions
  ///
  /// **Returns:** Stream of `ChatEvent`s representing the AI response
  Stream<ChatEvent> streamChat({
    required List<Message> history,
    required String modelId,
    String? systemPrompt,
  });
}

/// Direct client-side repository using OpenRouterService (development only for web)
class OpenRouterChatRepository implements ChatRepository {
  final OpenRouterService _service;
  OpenRouterChatRepository(this._service);

  @override
  Stream<ChatEvent> streamChat({
    required List<Message> history,
    required String modelId,
    String? systemPrompt,
  }) async* {
    try {
      await for (final chunk in _service.sendMessageStream(
        messages: history,
        model: modelId,
        systemPrompt: systemPrompt,
      )) {
        yield ResponseChunk(chunk);
      }
      yield Finished();
    } catch (e) {
      yield ChatError(e.toString());
    }
  }
}

/// Placeholder Firebase repository that calls a proxy endpoint
class FirebaseChatRepository implements ChatRepository {
  final String proxyUrl;
  FirebaseChatRepository(this.proxyUrl);

  @override
  Stream<ChatEvent> streamChat({
    required List<Message> history,
    required String modelId,
    String? systemPrompt,
  }) async* {
    // TODO: Implement HTTP/SSE call to Firebase Functions proxy at proxyUrl
    // This is a stub to lay the foundation.
    yield ChatError(
      'Firebase proxy not configured. Set AppConfig.firebaseProxyUrl.',
    );
  }
}

/// Placeholder Supabase repository that calls an Edge Function
class SupabaseChatRepository implements ChatRepository {
  final String edgeFunctionUrl;
  SupabaseChatRepository(this.edgeFunctionUrl);

  @override
  Stream<ChatEvent> streamChat({
    required List<Message> history,
    required String modelId,
    String? systemPrompt,
  }) async* {
    // TODO: Implement HTTP/SSE call to Supabase Edge Function at edgeFunctionUrl
    // This is a stub to lay the foundation.
    yield ChatError(
      'Supabase proxy not configured. Set AppConfig.supabaseEdgeFunctionUrl.',
    );
  }
}