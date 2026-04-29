import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/news_provider.dart';
import '../theme/app_theme.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class TrendingNewsScreen extends StatefulWidget {
  const TrendingNewsScreen({super.key});

  @override
  State<TrendingNewsScreen> createState() => _TrendingNewsScreenState();
}

class _TrendingNewsScreenState extends State<TrendingNewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<NewsProvider>().trendingArticles.isEmpty) {
        context.read<NewsProvider>().fetchTrending();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<NewsProvider>().fetchTrending(loadMore: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text(
          'Trending News',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, prov, child) {
          if (prov.isLoading && prov.trendingArticles.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (prov.error.isNotEmpty && prov.trendingArticles.isEmpty) {
            return Center(
              child: Text(
                'Failed to load trending news: \n${prov.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final articles = prov.trendingArticles;

          if (articles.isEmpty) {
            return Center(
              child: Text(
                'No trending news available.',
                style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () => prov.fetchTrending(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: articles.length + (prov.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                  );
                }
                return _buildTrendingArticleTile(articles[index], context, prov);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingArticleTile(Article article, BuildContext context, NewsProvider prov) {
    bool isSaved = prov.isArticleSaved(article.url);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (article.imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: AppTheme.divider,
                      child: const Center(child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: AppTheme.divider,
                      child: const Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 48),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: AppTheme.divider,
                    child: const Icon(Icons.newspaper, color: AppTheme.textSecondary, size: 48),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AppTheme.accent : Colors.white,
                      size: 28,
                    ),
                    onPressed: () => prov.toggleSaveArticle(article),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: AppTheme.accent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'TRENDING',
                              style: GoogleFonts.sourceSans3(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        article.readableDate,
                        style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: GoogleFonts.playfairDisplay(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
