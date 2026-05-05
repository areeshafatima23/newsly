import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // ── Replace with your actual News API key ──────────────────
  static const String newsApiKey = 'a17d79eb3f184bbbb74ebff399f967c9';
  static const String newsApiBase = 'https://newsapi.org/v2';

  // ── Replace with your Gemini API key ──────────────────────
  static String geminiApiKey =
      dotenv.env['GEMINI_API_KEY'] ?? '';

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
