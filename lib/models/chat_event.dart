/// Base class for all chat streaming events
sealed class ChatEvent {}

class ResponseChunk extends ChatEvent {
  final String text;
  ResponseChunk(this.text);
}

class ReasoningChunk extends ChatEvent {
  final String text;
  ReasoningChunk(this.text);
}

class Finished extends ChatEvent {}

class ChatError extends ChatEvent {
  final String message;
  ChatError(this.message);
}