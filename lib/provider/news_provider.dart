
// lib/providers/news_provider.dart
import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<Article> _homeArticles = [];
  List<Article> _trendingArticles = [];
  List<Article> _categoryArticles = [];
  List<Article> _urduArticles = [];
  List<Article> _searchResults = [];

  bool _isLoading = false;
  String _error = '';
  String _selectedCategory = 'general';
  int _currentIndex = 0;

  List<Article> get homeArticles => _homeArticles;
  List<Article> get trendingArticles => _trendingArticles;
  List<Article> get categoryArticles => _categoryArticles;
  List<Article> get urduArticles => _urduArticles;
  List<Article> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedCategory => _selectedCategory;
  int get currentIndex => _currentIndex;

  void setIndex(int i) {
    _currentIndex = i;
    notifyListeners();
  }

  Future<void> fetchHomeArticles() async {
    _setLoading(true);
    try {
      _homeArticles = await _newsService.getTopHeadlines();
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> fetchTrending() async {
    _setLoading(true);
    try {
      _trendingArticles = await _newsService.getTrending();
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> fetchByCategory(String category) async {
    _selectedCategory = category;
    _setLoading(true);
    try {
      _categoryArticles = await _newsService.getByCategory(category);
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> fetchUrduNews() async {
    _setLoading(true);
    try {
      _urduArticles = await _newsService.getUrduNews();
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> searchArticles(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      _searchResults = await _newsService.searchArticles(query);
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
