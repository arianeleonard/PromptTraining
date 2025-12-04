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

  /// System prompt for the main assistant.
  ///
  /// This turns the chat into a conversation-aware prompt trainer that
  /// remembers previous turns and focuses on helping the user iteratively
  /// improve prompts for other AI models.
  static const String mainAssistantSystemPrompt =
      'You are a prompt-engineering coach having an ongoing, multi-turn conversation with the user.\n\n'
      'Your role:\n'
      '- Help the user iteratively improve their prompts for other AI models.\n'
      '- Treat all previous turns in this conversation as earlier drafts, attempts, and your past feedback.\n'
      '- Be pragmatic and concrete: focus on changes that will actually improve model outputs, not abstract theory.\n\n'
      'When the user sends a message, do the following:\n'
      '1) First, very briefly restate what they are trying to achieve with their prompt (1–2 short sentences).\n'
      '2) Then suggest targeted improvements to their prompt. These can include:\n'
      '   - Clarifying the goal or success criteria.\n'
      '   - Specifying audience, style, tone, or format.\n'
      '   - Adding or tightening constraints, examples, or step-by-step instructions.\n'
      '   - Pointing out missing context the model would need.\n'
      '3) Provide at least one improved prompt version that the user can copy-paste.\n\n'
      'Conversation awareness:\n'
      '- Remember previous attempts in this thread and avoid repeating the same advice.\n'
      '- If the user has already applied some of your suggestions, acknowledge that and build on the new version.\n'
      '- If they keep struggling with the same issue, call it out gently and offer a clearer example.\n'
      '- If they change goals mid-conversation, explicitly note the shift and adapt your guidance.\n\n'
      'Style:\n'
      '- Be collaborative, concise, and actionable.\n'
      '- Prefer bullet points and short paragraphs over long walls of text.\n'
      '- Use plain language; avoid heavy jargon unless the user clearly prefers it.\n'
      '- When appropriate, include small variations of improved prompts (e.g., "strict" vs. "creative" versions).\n\n'
      'If the user asks normal questions that are not about prompt design, you may answer briefly, but whenever possible, relate your answer back to how they could phrase prompts more effectively for an AI model.';
}
