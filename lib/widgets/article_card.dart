// lib/widgets/article_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
// import 'article_detail_screen.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onSaveToggle;
  final bool isCompact;

  const ArticleCard({
    super.key,
    required this.article,
    this.onSaveToggle,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => ArticleDetailScreen(article: article),
      //   ),
      // ),
      child: isCompact ? _compactCard() : _fullCard(),
    );
  }

  Widget _fullCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: _buildImage(height: 190),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source + time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.sourceName.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(article.readableDate,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    const SizedBox(width: 8),
                    if (onSaveToggle != null)
                      GestureDetector(
                        onTap: onSaveToggle,
                        child: Icon(
                          article.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: article.isSaved ? AppTheme.accentGold : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    fontFamily: 'Playfair',
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Description
                if (article.description.isNotEmpty)
                  Text(
                    article.description,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Text(
                  article.readTime,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImage(width: 80, height: 80),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.sourceName.toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(article.title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(article.readableDate,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    const Spacer(),
                    if (onSaveToggle != null)
                      GestureDetector(
                        onTap: onSaveToggle,
                        child: Icon(
                          article.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: article.isSaved ? AppTheme.accentGold : AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage({double? width, double? height}) {
    if (article.imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppTheme.divider,
        child: const Icon(Icons.image_not_supported, color: AppTheme.textSecondary),
      );
    }
    return CachedNetworkImage(
      imageUrl: article.imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.cardBg,
        highlightColor: AppTheme.divider,
        child: Container(color: AppTheme.cardBg, width: width, height: height),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppTheme.divider,
        child: const Icon(Icons.broken_image, color: AppTheme.textSecondary),
      ),
    );
  }
}