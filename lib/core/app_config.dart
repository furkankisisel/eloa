/// Application configuration and environment credentials management.
///
/// Keys are supplied at build or run time via `--dart-define`:
/// ```bash
/// flutter run \
///   --dart-define=GEMINI_API_KEY=your_gemini_key \
///   --dart-define=GROQ_API_KEY=your_groq_key
/// ```
class AppConfig {
  /// Google Gemini API Key for multimodal hand & face analysis and dream interpretation.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDbnTcHFYi-eexcars1zCguBtyrWxkGyAk',
  );

  /// Groq API Key (Llama 3.3) for fast semantic synthesis commentary.
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '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',
  );

  /// Gemini API Base URL
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Default Gemini Models
  static const String geminiVisionModel = 'gemini-2.5-flash-lite';
  static const String geminiTextModel = 'gemini-2.5-flash-lite';

  /// Groq Base URL & Model
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.3-70b-versatile';

  /// Helper to check if production keys are set via environment
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  static bool get hasGroqKey => groqApiKey.isNotEmpty;
}
