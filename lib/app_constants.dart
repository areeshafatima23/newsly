
class AppConstants {
  // ── Replace with your actual News API key ──────────────────
  static const String newsApiKey = 'a17d79eb3f184bbbb74ebff399f967c9';
  static const String newsApiBase = 'https://newsapi.org/v2';

  // ── Replace with your Gemini API key ──────────────────────
  // static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static const String geminiApiKey = 'AIzaSyAg0ncqmJ60S5--jBFd8Fiei-5Tt-kInx0';

  static const List<String> categories = [
    'general', 'technology', 'sports', 'business', 'entertainment', 'health', 'science',
  ];

  static const List<String> categoryLabels = [
    'General', 'Technology', 'Sports', 'Business', 'Entertainment', 'Health', 'Science',
  ];

  static const List<String> categoryIcons = [
    '🌐', '💻', '⚽', '💼', '🎬', '❤️', '🔬',
  ];
}
