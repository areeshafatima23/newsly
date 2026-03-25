// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/news_provider.dart';
import '../theme/app_theme.dart';
import '../models/article.dart';
import '../screens/article_detail_screen.dart';
import '../app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // -1 means Home (Top Headlines)
  int _selectedCategoryIndex = -1; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<NewsProvider>().homeArticles.isEmpty) {
        context.read<NewsProvider>().fetchHomeArticles();
      }
    });
  }

  void _onCategorySelected(int index, BuildContext context) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    if (index == -1) {
      context.read<NewsProvider>().fetchHomeArticles();
    } else {
      context.read<NewsProvider>().fetchByCategory(AppConstants.categories[index]);
    }
    Navigator.pop(context); // Close Drawer
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
          _selectedCategoryIndex == -1 ? 'Top Headlines' : AppConstants.categoryLabels[_selectedCategoryIndex],
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Consumer<NewsProvider>(
        builder: (context, prov, child) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (prov.error.isNotEmpty) {
            return Center(
              child: Text(
                'Failed to load news: \n${prov.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final articles = _selectedCategoryIndex == -1 ? prov.homeArticles : prov.categoryArticles;

          if (articles.isEmpty) {
            return Center(
              child: Text(
                'No news available.',
                style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: () async {
              if (_selectedCategoryIndex == -1) {
                await prov.fetchHomeArticles();
              } else {
                await prov.fetchByCategory(AppConstants.categories[_selectedCategoryIndex]);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return _buildSimpleArticleTile(articles[index], context);
              },
            ),
          );
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20),
            color: AppTheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('NEWS', style: GoogleFonts.playfairDisplay(
                        color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    Text('LY', style: GoogleFonts.playfairDisplay(
                        color: AppTheme.accent, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Categories', style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_filled,
                  title: 'Home',
                  isSelected: _selectedCategoryIndex == -1,
                  onTap: () => _onCategorySelected(-1, context),
                ),
                const Divider(color: AppTheme.divider),
                ...List.generate(AppConstants.categoryLabels.length, (index) {
                  return _buildDrawerItem(
                    icon: _getIconForCategory(AppConstants.categories[index]),
                    title: AppConstants.categoryLabels[index],
                    isSelected: _selectedCategoryIndex == index,
                    onTap: () => _onCategorySelected(index, context),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.accent : AppTheme.textSecondary),
      title: Text(
        title,
        style: GoogleFonts.sourceSans3(
          color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppTheme.accent.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }

  IconData _getIconForCategory(String category) {
    switch(category.toLowerCase()) {
      case 'general': return Icons.public;
      case 'technology': return Icons.computer;
      case 'sports': return Icons.sports_soccer;
      case 'business': return Icons.business_center;
      case 'entertainment': return Icons.movie;
      case 'health': return Icons.local_hospital;
      case 'science': return Icons.science;
      default: return Icons.category;
    }
  }

  Widget _buildSimpleArticleTile(Article article, BuildContext context) {
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
            // Image
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
            // Caption / Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        article.sourceName,
                        style: GoogleFonts.sourceSans3(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold),
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

