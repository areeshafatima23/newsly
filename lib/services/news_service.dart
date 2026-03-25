// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../app_constants.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  final String _baseUrl = AppConstants.newsApiBase;
  final String _apiKey = AppConstants.newsApiKey;

  /// Fetch top headlines (homepage)
  Future<List<Article>> getTopHeadlines({String country = 'us'}) async {
    final url = Uri.parse('$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey&pageSize=20');
    return _fetchArticles(url);
  }

  /// Fetch trending / everything endpoint sorted by popularity
  Future<List<Article>> getTrending() async {
    final url = Uri.parse(
        '$_baseUrl/top-headlines?sources=bbc-news,cnn,reuters,the-verge&apiKey=$_apiKey&pageSize=20');
    return _fetchArticles(url);
  }

  /// Fetch news by category
  Future<List<Article>> getByCategory(String category) async {
    final url =
    Uri.parse('$_baseUrl/top-headlines?category=$category&language=en&apiKey=$_apiKey&pageSize=20');
    return _fetchArticles(url);
  }

  /// Search articles
  Future<List<Article>> searchArticles(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        '$_baseUrl/everything?q=$encodedQuery&sortBy=publishedAt&language=en&apiKey=$_apiKey&pageSize=20');
    return _fetchArticles(url);
  }

  /// Fetch Urdu news (Pakistani sources)
  Future<List<Article>> getUrduNews() async {
    // Using geo.tv, dawn, and ARY as Pakistani English sources; for Urdu,
    // you'd need a separate Urdu API or RSS feed.
    final url = Uri.parse(
        '$_baseUrl/top-headlines?sources=geo-news&apiKey=$_apiKey&pageSize=20');
    return _fetchArticles(url);
  }

  Future<List<Article>> _fetchArticles(Uri url) async {
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List articles = data['articles'] ?? [];
        return articles
            .map((json) => Article.fromJson(json))
            .where((a) => a.title != '[Removed]' && a.imageUrl.isNotEmpty)
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}