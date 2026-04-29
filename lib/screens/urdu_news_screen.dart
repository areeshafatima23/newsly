import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../provider/news_provider.dart';
import '../theme/app_theme.dart';
import '../models/article.dart';
import '../screens/article_detail_screen.dart';

class UrduNewsScreen extends StatefulWidget {
  const UrduNewsScreen({super.key});
  
  @override
  State<UrduNewsScreen> createState() => _UrduNewsScreenState();
}

class _UrduNewsScreenState extends State<UrduNewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<NewsProvider>().urduArticles.isEmpty) {
        context.read<NewsProvider>().fetchUrduNews();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<NewsProvider>().fetchUrduNews(loadMore: true);
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
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(
          'Urdu News (اردو خبریں)',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, prov, child) {
          final articles = prov.urduArticles;

          if (prov.isLoading && articles.isEmpty) {
             return _buildShimmerLoading();
          }
          if (prov.error.isNotEmpty && articles.isEmpty) {
            return Center(
              child: Text(
                'Failed to load news: \n${prov.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (articles.isEmpty) {
            return Center(
              child: Text(
                'No Urdu news available at the moment.',
                style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () => prov.fetchUrduNews(),
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
                return _buildUrduArticleTile(articles[index], context, prov);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Shimmer.fromColors(
          baseColor: AppTheme.cardBg,
          highlightColor: AppTheme.divider,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrduArticleTile(Article article, BuildContext context, NewsProvider prov) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  left: 10, // Urdu usually has actions on the left
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
                textDirection: TextDirection.rtl, // Set right-to-left direction for Urdu
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        article.sourceName,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.sourceSans3(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        article.readableDate,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      article.description,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

