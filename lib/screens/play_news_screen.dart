// lib/screens/play_news_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../provider/news_provider.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class PlayNewsScreen extends StatefulWidget {
  const PlayNewsScreen({super.key});

  @override
  State<PlayNewsScreen> createState() => _PlayNewsScreenState();
}

class _PlayNewsScreenState extends State<PlayNewsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _showPlayer = false;
  Article? _currentArticle;
  double _currentSpeechRate = 0.5; // flutter_tts universally treats 0.5 as normal speed
  final List<double> _speedOptions = [0.5, 1.0]; // 0.5 is 1x normal, 1.0 is 2x fast
  final List<String> _speedLabels = ["1.0x", "2.0x"];
  int _speedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(_currentSpeechRate);
    
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    _flutterTts.setPauseHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _playArticle() async {
    if (_currentArticle == null) return;
    String textToRead = "${_currentArticle!.title}. \n\n ${_currentArticle!.description}";
    if (textToRead.trim().isEmpty) textToRead = "Sorry, there is no text available to read for this article.";

    await _flutterTts.setSpeechRate(_speedOptions[_speedIndex]);
    await _flutterTts.speak(textToRead);
    setState(() => _isPlaying = true);
  }

  void _pauseArticle() async {
    await _flutterTts.pause();
    setState(() => _isPlaying = false);
  }

  void _stopArticle() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  void _toggleSpeed() async {
    setState(() {
      _speedIndex = (_speedIndex + 1) % _speedOptions.length;
    });
    // Restart audio gracefully to apply the newly selected speed immediately
    if (_isPlaying) {
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 150));
      _playArticle();
    }
  }

  void _openPlayer(Article article) {
    setState(() {
      _currentArticle = article;
      _showPlayer = true;
    });
    // Optional: auto-play when opened
    // _playArticle();
  }

  void _closePlayer() {
    _stopArticle();
    setState(() {
      _showPlayer = false;
      _currentArticle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showPlayer ? _buildPlayerView() : _buildListView(),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final prov = context.watch<NewsProvider>();
    final articles = prov.homeArticles; // or a combined list if you prefer

    return Column(
      key: const ValueKey('ListView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 16, right: 24, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.headphones, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Text(
                'Audio Articles',
                style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Divider(color: AppTheme.divider, thickness: 1.5),
        ),
        if (prov.isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
        else if (articles.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No audio articles available.',
                style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return GestureDetector(
                  onTap: () => _openPlayer(article),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: article.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: article.imageUrl,
                                  width: 80, height: 80, fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(width: 80, height: 80, color: AppTheme.divider),
                                  errorWidget: (_, __, ___) => Container(width: 80, height: 80, color: AppTheme.divider, child: const Icon(Icons.broken_image)),
                                )
                              : Container(width: 80, height: 80, color: AppTheme.divider, child: const Icon(Icons.newspaper)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.play_circle_fill, color: AppTheme.accent, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Listen Now',
                                    style: GoogleFonts.sourceSans3(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerView() {
    if (_currentArticle == null) return const SizedBox.shrink();

    return Padding(
      key: const ValueKey('PlayerView'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header w/ Back Button
          Row(
            children: [
              GestureDetector(
                onTap: _closePlayer,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),
              const Spacer(),
              Text(
                'Play News',
                style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Empty box to balance the row
              const SizedBox(width: 40), 
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.divider, thickness: 1.5),
          const SizedBox(height: 20),

          // Content: Text taking priority with Image on the side
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Area (Expanded so it prioritizes screen real-estate)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary, fontSize: 20, height: 1.4, fontWeight: FontWeight.bold),
                            children: [TextSpan(text: _currentArticle!.title)],
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 16, height: 1.5),
                            children: [
                              TextSpan(text: _currentArticle!.description.isNotEmpty ? _currentArticle!.description : 'No description available for this top story.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Image on the Side
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _currentArticle!.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _currentArticle!.imageUrl,
                            width: 100, height: 120, fit: BoxFit.cover,
                            placeholder: (_, __) => Container(width: 100, height: 120, color: AppTheme.divider, child: const Center(child: CircularProgressIndicator())),
                            errorWidget: (_, __, ___) => Container(width: 100, height: 120, color: AppTheme.divider, child: const Icon(Icons.broken_image, size: 32)),
                          )
                        : Container(width: 100, height: 120, color: AppTheme.divider, child: const Icon(Icons.newspaper, size: 48)),
                  ),
                ],
              ),
            ),
          ),

          // Playback Controls
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speed Control Top Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.speed, size: 18, color: Colors.black54),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleSpeed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            "Speed: ${_speedLabels[_speedIndex]}",
                            style: GoogleFonts.sourceSans3(fontWeight: FontWeight.bold, color: AppTheme.accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Play/Pause/Stop Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isPlaying ? null : _playArticle,
                        child: Icon(Icons.play_arrow, size: 42, color: _isPlaying ? AppTheme.divider : Colors.black),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: _isPlaying ? _pauseArticle : null,
                        child: Icon(Icons.pause, size: 36, color: _isPlaying ? Colors.black : AppTheme.divider),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: _stopArticle,
                        child: const Icon(Icons.close, size: 32, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

