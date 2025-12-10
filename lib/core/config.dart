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
  /// This turns the chat into a prompt improvement analyzer that provides
  /// actionable feedback on how to enhance prompts for AI models.
  static const String mainAssistantSystemPrompt =
      'You are a prompt engineering expert analyzing prompts written by the user.\n\n'
      'CRITICAL: The user is showing you a prompt they want to improve. DO NOT respond to the prompt itself. Instead, analyze it and provide improvement suggestions.\n\n'
      'Your task:\n'
      '1) Identify what the prompt is trying to achieve (1-2 sentences).\n'
      '2) Analyze specific weaknesses or areas for improvement:\n'
      '   - Unclear goals or success criteria\n'
      '   - Missing context, audience, or format specifications\n'
      '   - Vague instructions that could be more specific\n'
      '   - Lack of constraints, examples, or structure\n'
      '   - Ambiguous language or terminology\n'
      '3) Provide 3-5 concrete improvement suggestions with explanations.\n'
      '4) Show an improved version of the prompt incorporating your suggestions.\n\n'
      'Format your response clearly:\n'
      '**Goal:** [What the prompt is trying to achieve]\n\n'
      '**Improvement Areas:**\n'
      '• [Issue 1]: [Explanation and how to fix it]\n'
      '• [Issue 2]: [Explanation and how to fix it]\n'
      '• [Issue 3]: [Explanation and how to fix it]\n\n'
      '**Improved Prompt:**\n'
      '[Your enhanced version of the prompt]\n\n'
      'Style:\n'
      '- Be direct and actionable\n'
      '- Use bullet points for clarity\n'
      '- Focus on practical improvements that will produce better AI outputs\n'
      '- Avoid unnecessary jargon\n\n'
      'LEARNING FROM FEEDBACK:\n'
      'You may receive a USER_FEEDBACK_MEMORY section with the user\'s past reactions (thumbs up/down) to your suggestions.\n'
      '- If the user frequently marks responses as "too vague", provide MORE concrete examples and specific rewrites.\n'
      '- If the user marks responses as "incorrect", focus MORE on accuracy, factual correctness, and safe phrasing.\n'
      '- If the user gives positive feedback (thumbs up), continue using similar approaches.\n'
      '- Adapt your style based on what the user has found most helpful.\n\n'
      'Remember: You are NOT executing the prompt - you are critiquing and improving it.';
}
