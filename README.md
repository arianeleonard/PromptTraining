# AI Chat Template

A complete AI chat application built with Flutter Web. Features clean architecture, dual-mode operation (mock/real AI), responsive design, and streaming responses.

## 🚀 Quick Start

### Instant Demo (0 setup)
The template works immediately with realistic mock responses - no API key needed!

### Real AI Integration (30 seconds)
1. Get your free API key from [OpenRouter.ai](https://openrouter.ai)
2. Add it to `lib/core/config.dart`:
   ```dart
   static const String testingOnlyOpenRouterApiKey = 'your-key-here';
   ```
3. Start chatting with 20+ AI models!

## ✨ Key Features

- **Demo Mode**: Works instantly with mock responses
- **Real AI**: Connect to 20+ models via OpenRouter
- **Streaming**: Real-time response generation
- **Responsive**: Mobile drawer + desktop sidebar
- **Themes**: Light/dark/system theme support
- **Clean Architecture**: Provider pattern with repository abstraction

## 🏗️ Architecture

```
🎨 UI Layer (widgets/) - Layout, messages, input components
🧠 State Layer (presentation/) - ChatProvider, ThemeProvider  
📡 Service Layer (data/) - Repositories, AI services, mock responses
⚙️ Core Layer (core/) - Configuration, models
```

**Key Components:**
- **ChatProvider**: Manages conversations, messages, streaming
- **Repository Pattern**: Abstracts AI service backends (OpenRouter, Firebase, Supabase)
- **MockResponsesService**: Realistic demo responses with streaming simulation

## 🎮 Operation Modes

**Demo Mode** (Default): Mock responses, no API key required
**Development Mode**: Real AI with API key in config or `--dart-define`
**Production Mode**: Backend proxy with server-side API keys

## 🔧 Quick Customizations

### Change Branding
```dart
// In main.dart
MaterialApp(title: 'My AI Assistant')

// In AppConfig
static const String appName = 'My AI Assistant';
```

### Add AI Models
```dart
// In AppConfig
static const List<String> availableModels = [
  'openai/gpt-4o-mini',
  'anthropic/claude-3.5-sonnet',
  'my-custom/model-id', // Add here
];
```

### Customize Theme
```dart
// In theme.dart
class LightColors {
  static const primary = Color(0xFF6366F1); // Your brand color
}
```

## 🔐 Security

**Development**: Safe to use `testingOnlyOpenRouterApiKey` for local testing
**Production**: ⚠️ **Never deploy with `BackendProvider.direct`** - API keys become public!

**Recommended Production Setup:**
```dart
// 1. Switch to backend mode
static const BackendProvider backendProvider = BackendProvider.firebase;

// 2. Configure proxy URL  
static const String firebaseProxyUrl = 'https://your-project.cloudfunctions.net/chatProxy';
```

## 🧩 Extension Examples

### Message Persistence
```dart
class PersistentChatProvider extends ChatProvider {
  late final HiveBox<Conversation> _conversationBox;
  
  @override
  List<Conversation> get conversations => _conversationBox.values.toList();
}
```

### Custom Backend
```dart
class MyAIServiceRepository implements ChatRepository {
  @override
  Stream<ChatEvent> streamChat({required List<Message> history, required String modelId}) async* {
    // Your custom AI service integration
    yield* myService.streamResponse(history).map(ResponseChunk.new);
  }
}
```

### Voice Input
```dart
class VoicePromptInput extends PromptInputComplete {
  Widget _buildVoiceButton() => IconButton(
    icon: Icon(_isListening ? LucideIcons.micOff : LucideIcons.mic),
    onPressed: _toggleVoiceInput,
  );
}
```

## 📁 File Structure

```
lib/
├── core/config.dart          # API keys, models, backend selection
├── data/
│   ├── models.dart           # Message, Conversation, ChatStatus
│   ├── repositories.dart     # ChatRepository interface
│   └── services/             # OpenRouter, mock responses, thread naming
├── presentation/
│   ├── providers/            # ChatProvider, ThemeProvider
│   └── pages/chat_page.dart  # Main chat interface
└── widgets/                  # UI components (sidebar, messages, input)
```