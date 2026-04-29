import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
import '../app_constants.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isLoadingSummary = true;
  String _aiSummary = "";
  List<String> _aiKeywords = [];
  String _summaryError = "";

  @override
  void initState() {
    super.initState();
    _generateAiSummary();
  }

  Future<void> _generateAiSummary() async {
    final prompt = '''
You are an expert news summarizer. Given the following news article title, description, and content snippet:
Title: ${widget.article.title}
Description: ${widget.article.description}
Content: ${widget.article.content}

Please provide a short, engaging 2-3 sentence summary of the article. 
Then, on a new line separated by 'KEYWORDS:', provide 3 to 5 relevant keywords separated by commas.
Format exactly like this:
[Summary text here]
KEYWORDS: keyword1, keyword2, keyword3
''';

    final modelsToTry = [
      'gemini-3.1-flash-lite-preview',
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
    ];

    bool success = false;
    
    for (String modelName in modelsToTry) {
      if (success) break;
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: AppConstants.geminiApiKey,
        );

        final stream = model.generateContentStream([Content.text(prompt)]);
        
        String fullResult = "";
        
        await for (final chunk in stream) {
          if (!mounted) return;
          fullResult += (chunk.text ?? "");
          
          if (fullResult.contains('KEYWORDS:')) {
            final parts = fullResult.split('KEYWORDS:');
            setState(() {
              _aiSummary = parts[0].trim();
              _aiKeywords = parts[1].split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              _isLoadingSummary = false;
            });
          } else {
            setState(() {
              _aiSummary = fullResult.trim();
              _isLoadingSummary = false;
            });
          }
        }
        
        success = true;
      } catch (e) {
        // Silently continue to next model on failure (e.g. 503 Overloaded)
      }
    }

    if (!success && mounted) {
      setState(() {
        _summaryError = "Could not generate AI summary at this time (Servers overloaded).";
        _isLoadingSummary = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    if (widget.article.url.isEmpty) return;
    final Uri url = Uri.parse(widget.article.url);
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
          widget.article.sourceName,
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
            if (widget.article.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.article.imageUrl,
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
                          widget.article.sourceName,
                          style: GoogleFonts.sourceSans3(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.article.readableDate,
                        style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    widget.article.title,
                    style: GoogleFonts.playfairDisplay(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // AI Summary Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
                            const SizedBox(width: 8),
                            Text('AI Summary', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingSummary)
                          const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                        else if (_summaryError.isNotEmpty)
                          Text(_summaryError, style: const TextStyle(color: Colors.redAccent))
                        else ...[
                          Text(
                            _aiSummary,
                            style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 16, height: 1.6),
                          ),
                          if (_aiKeywords.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _aiKeywords.map((k) => Chip(
                                label: Text(k, style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                                backgroundColor: AppTheme.accent.withOpacity(0.1),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              )).toList(),
                            ),
                          ],
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Original content snippet (optional, but good to keep if summary fails)
                  if (_summaryError.isNotEmpty || widget.article.content.isNotEmpty)
                    Text(
                      widget.article.content,
                      style: GoogleFonts.sourceSans3(
                        color: AppTheme.textSecondary.withOpacity(0.5),
                        fontSize: 14,
                        height: 1.5,
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
