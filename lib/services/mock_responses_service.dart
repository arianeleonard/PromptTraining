import 'dart:async';
import 'dart:math';

/// **MockResponsesService** - Provides realistic demo responses for development
///
/// This service generates mock AI responses when no API key is configured,
/// enabling the template to work out-of-the-box for demos and development.
/// Responses simulate real AI behavior including streaming delays and varied content.
///
/// ## Key Features:
/// - **Realistic Streaming**: Word-by-word delivery with variable delays
/// - **Diverse Content**: Pool of responses covering different conversation styles
/// - **Educational Value**: Mock responses explain template features and setup
/// - **Demonstration Ready**: Perfect for showcasing template capabilities
///
/// ## Technical Implementation:
/// - Yields incremental chunks (individual words) for proper streaming
/// - Variable delays based on punctuation and word length
/// - Random response selection for conversation variety
/// - Thread name generation for conversation organization
///
/// ## Integration:
/// - Automatically used by `OpenRouterService` when `AppConfig.openRouterApiKey.isEmpty`
/// - Integrated into `ThreadNamingService` for consistent mock experience
/// - Designed to be indistinguishable from real API responses in UI
///
/// ## Customization Examples:
/// ```dart
/// // Add domain-specific responses:
/// class CustomMockService extends MockResponsesService {
///   static const List<String> _domainResponses = [
///     'Here\'s help with your Flutter development...',
///     'Let me explain this design pattern...',
///   ];
/// }
///
/// // Add conversation context:
/// class ContextualMockService extends MockResponsesService {
///   String generateContextualResponse(List<Message> history) {
///     // Generate responses based on conversation history
///   }
/// }
/// ```
class MockResponsesService {
  static final _random = Random();

  // Pool of realistic mock responses for different types of prompts
  static const List<String> _mockResponses = [
    '''Mock Reponse 1''',
    '''Mock Reponse 2'''
  ];

  static const List<String> _mockThreadNames = [
    'Flutter Development Help',
    'UI Design Discussion',
    'Mock API Integration',
    'Template Configuration',
    'Theme Implementation',
    'State Management Guide',
    'Component Architecture',
    'Development Workflow',
    'Code Review Session',
    'Feature Planning',
  ];

  /// Generate a mock response with realistic streaming delay
  /// Yields incremental chunks (individual words/tokens) for proper streaming
  Stream<String> generateMockResponse() async* {
    final response = _mockResponses[_random.nextInt(_mockResponses.length)];
    final words = response.split(' ');

    // Stream individual words with realistic typing delay
    for (int i = 0; i < words.length; i++) {
      // Yield just the new word (with space prefix except for first word)
      final chunk = i == 0 ? words[i] : ' ${words[i]}';
      yield chunk;

      // Vary delay based on word length and punctuation
      int baseDelay = 20;
      if (words[i].contains('\n')) baseDelay += 200;
      if (words[i].contains('.') ||
          words[i].contains('!') ||
          words[i].contains('?')) {
        baseDelay += 300;
      }
      if (words[i].length > 6) {
        baseDelay += 20;
      }

      // Add random variation
      final delayMs = baseDelay + _random.nextInt(30);
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  /// Generate a mock thread name
  String generateMockThreadName() {
    return _mockThreadNames[_random.nextInt(_mockThreadNames.length)];
  }

  /// Simulate processing delay
  Future<void> simulateProcessingDelay() async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
  }
}