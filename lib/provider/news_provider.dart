// lib/providers/news_provider.dart
import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/database_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  final DatabaseService _dbService = DatabaseService();

  List<Article> _homeArticles = [];
  List<Article> _trendingArticles = [];
  List<Article> _categoryArticles = [];
  List<Article> _urduArticles = [];
  List<Article> _searchResults = [];
  List<Article> _savedArticles = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _error = '';
  String _selectedCategory = 'general';
  
  // Pagination counters
  int _homePage = 1;
  int _trendingPage = 1;
  int _categoryPage = 1;
  int _urduPage = 1;

  List<Article> get homeArticles => _homeArticles;
  List<Article> get trendingArticles => _trendingArticles;
  List<Article> get categoryArticles => _categoryArticles;
  List<Article> get urduArticles => _urduArticles;
  List<Article> get searchResults => _searchResults;
  List<Article> get savedArticles => _savedArticles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get error => _error;
  String get selectedCategory => _selectedCategory;

  NewsProvider() {
    fetchSavedArticles();
  }

  Future<void> fetchSavedArticles() async {
    _savedArticles = await _dbService.getSavedArticles();
    notifyListeners();
  }

  Future<void> toggleSaveArticle(Article article) async {
    bool isSaved = await _dbService.isArticleSaved(article.url);
    if (isSaved) {
      await _dbService.removeSavedArticle(article.url);
    } else {
      await _dbService.saveArticle(article);
    }
    await fetchSavedArticles();
  }

  bool isArticleSaved(String url) {
    return _savedArticles.any((a) => a.url == url);
  }

  Future<void> fetchHomeArticles({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore) return;
      _isLoadingMore = true;
      _homePage++;
      notifyListeners();
    } else {
      _setLoading(true);
      _homePage = 1;
    }
    try {
      final newArticles = await _newsService.getTopHeadlines(page: _homePage);
      if (loadMore) {
        _homeArticles.addAll(newArticles);
      } else {
        _homeArticles = newArticles;
      }
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingMore = false;
    _setLoading(false);
  }

  Future<void> fetchTrending({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore) return;
      _isLoadingMore = true;
      _trendingPage++;
      notifyListeners();
    } else {
      _setLoading(true);
      _trendingPage = 1;
    }
    try {
      final newArticles = await _newsService.getTrending(page: _trendingPage);
      if (loadMore) {
        _trendingArticles.addAll(newArticles);
      } else {
        _trendingArticles = newArticles;
      }
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingMore = false;
    _setLoading(false);
  }

  Future<void> fetchByCategory(String category, {bool loadMore = false}) async {
    if (category != _selectedCategory) {
      _selectedCategory = category;
      _categoryPage = 1;
    }
    if (loadMore) {
      if (_isLoadingMore) return;
      _isLoadingMore = true;
      _categoryPage++;
      notifyListeners();
    } else {
      _setLoading(true);
      if (_categoryPage > 1 && !loadMore) _categoryPage = 1;
    }
    try {
      final newArticles = await _newsService.getByCategory(category, page: _categoryPage);
      if (loadMore) {
        _categoryArticles.addAll(newArticles);
      } else {
        _categoryArticles = newArticles;
      }
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingMore = false;
    _setLoading(false);
  }

  Future<void> fetchUrduNews({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore) return;
      _isLoadingMore = true;
      _urduPage++;
      notifyListeners();
    } else {
      _setLoading(true);
      _urduPage = 1;
    }
    try {
      final newArticles = await _newsService.getUrduNews(page: _urduPage);
      if (loadMore) {
        _urduArticles.addAll(newArticles);
      } else {
        _urduArticles = newArticles;
      }
      _error = '';
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingMore = false;
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
    if (_isLoading != val) {
      _isLoading = val;
      notifyListeners();
    }
  }
}
