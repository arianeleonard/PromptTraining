/// Backend connection modes: direct (dev only), firebase/supabase (production)
enum BackendProvider { direct, firebase, supabase }

/// Central configuration for API keys, models, and backend selection.
///
/// **Security**: Use `direct` mode for development only. Production apps must use
/// backend proxy to keep API keys secure.
class AppConfig {
  // SECURITY WARNING:
  // For local testing only, you can set your API key below.
  // ⚠️  NEVER commit or deploy with this key set - it becomes publicly visible in web builds!
  // ⚠️  For production deployment, use backend proxy to keep API keys secure.
  static const String testingOnlyOpenRouterApiKey =
      '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'; // Paste your key here for local testing only

  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: testingOnlyOpenRouterApiKey,
  );

  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';

  static const String appName = 'AI Chat Template';
  static const String appUrl =
      'https://your-app-url.com'; // Optional for rankings

  // Backend provider mode. 'direct' calls OpenRouter from the client (dev only).
  // For production, switch to 'firebase' or 'supabase' and configure the proxy URLs below.
  static const BackendProvider backendProvider = BackendProvider.direct;

  // Helper to check if API key is configured
  static bool get isApiKeyConfigured => openRouterApiKey.isNotEmpty;

  // Backend proxy endpoints (configure when using firebase/supabase)
  // Firebase HTTPS Function or Cloud Run URL that proxies OpenRouter
  static const String firebaseProxyUrl = '';
  // Supabase Edge Function URL that proxies OpenRouter
  static const String supabaseEdgeFunctionUrl = '';

  // Available models on OpenRouter
  static const List<String> availableModels = [
    'openai/gpt-5',
    'openai/gpt-5-mini',
    'openai/gpt-5-nano',
    'openai/chatgpt-4o-latest',
    'openai/gpt-4o-mini',
    'anthropic/claude-sonnet-4',
    'anthropic/claude-sonnet-4.5',
    'anthropic/claude-3.7-sonnet',
    'anthropic/claude-3.5-haiku',
    'google/gemini-2.5-flash-lite',
  ];

  static const Map<String, String> modelDisplayNames = {
    'openai/gpt-5': 'GPT-5',
    'openai/gpt-5-mini': 'GPT-5 Mini',
    'openai/gpt-5-nano': 'GPT-5 Nano',
    'openai/chatgpt-4o-latest': 'ChatGPT 4o',
    'openai/gpt-4o-mini': 'GPT-4o Mini',
    'anthropic/claude-sonnet-4': 'Claude Sonnet 4',
    'anthropic/claude-sonnet-4.5': 'Claude Sonnet 4.5',
    'anthropic/claude-3.7-sonnet': 'Claude 3.7 Sonnet',
    'anthropic/claude-3.5-haiku': 'Claude 3.5 Haiku',
    'google/gemini-2.5-flash-lite': 'Gemini 2.5 Flash Lite',
  };
}
