import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _launchUrl() async {
    if (article.url.isEmpty) return;
    final Uri url = Uri.parse(article.url);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch \$url');
    }
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
          article.sourceName,
          style: GoogleFonts.sourceSans3(
            color: AppTheme.accent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: AppTheme.divider,
                  child: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                ),
                errorWidget: (context, url, err) => Container(
                  height: 250,
                  color: AppTheme.divider,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          article.sourceName,
                          style: GoogleFonts.sourceSans3(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        article.readableDate,
                        style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    article.title,
                    style: GoogleFonts.playfairDisplay(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    article.description.isNotEmpty ? article.description : 'No detailed description available.',
                    style: GoogleFonts.sourceSans3(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Content Preview
                  if (article.content.isNotEmpty)
                    Text(
                      article.content,
                      style: GoogleFonts.sourceSans3(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 48),

                  // Link Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _launchUrl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Read Full Article', style: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.open_in_new, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
