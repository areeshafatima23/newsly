// lib/models/article.dart
class Article {
  final String title;
  final String description;
  final String content;
  final String url;
  final String imageUrl;
  final String sourceName;
  final DateTime publishedAt;
  final String author;
  bool isSaved;

  Article({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    required this.author,
    this.isSaved = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      sourceName: json['source']?['name'] ?? 'Unknown',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      author: json['author'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'sourceName': sourceName,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      url: map['url'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      sourceName: map['sourceName'] ?? '',
      publishedAt: DateTime.tryParse(map['publishedAt'] ?? '') ?? DateTime.now(),
      author: map['author'] ?? '',
      isSaved: true,
    );
  }

  String get readableDate {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get readTime {
    final words = (content.split(' ').length);
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }
}