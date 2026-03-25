import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/news_provider.dart';
import '../services/audio_service.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});
  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen>
    with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  TtsState _ttsState = TtsState.stopped;
  int _currentIndex = 0;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _waveController;
  late AnimationController _slideController;

  late Animation<double> _pulseAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _rotateController = AnimationController(
        vsync: this, duration: const Duration(seconds: 10));
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _rotateAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
    _slideAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _audio.init();
    _audio.onStateChanged = (state) {
      if (!mounted) return;
      setState(() => _ttsState = state);
      if (state == TtsState.playing) {
        _rotateController.repeat();
      } else {
        _rotateController.stop();
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchTrending();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  List<Article> get _articles => context.read<NewsProvider>().trendingArticles;

  void _play() {
    if (_articles.isEmpty) return;
    final a = _articles[_currentIndex];
    final text = a.description.isNotEmpty ? a.description : a.title;
    _audio.speak(a.title, text);
  }

  void _stopOrPlay() {
    if (_ttsState == TtsState.playing) {
      _audio.stop();
    } else {
      _play();
    }
  }

  void _next() {
    final articles = context.read<NewsProvider>().trendingArticles;
    if (_currentIndex < articles.length - 1) {
      setState(() => _currentIndex++);
      _audio.stop();
      _slideController.forward(from: 0);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _audio.stop();
      _slideController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Consumer<NewsProvider>(
        builder: (_, prov, __) {
          if (prov.trendingArticles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.accent),
                  const SizedBox(height: 16),
                  Text('Loading audio news...',
                      style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          final article = prov.trendingArticles[_currentIndex];
          final isPlaying = _ttsState == TtsState.playing;

          return SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Audio News',
                              style: GoogleFonts.playfairDisplay(
                                  color: AppTheme.textPrimary, fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                          Text('Listen hands-free',
                              style: GoogleFonts.sourceSans3(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      // Speed selector
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20)),
                          child: Text('1×',
                              style: GoogleFonts.sourceSans3(
                                  color: AppTheme.textSecondary, fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Now Playing card (album art + info) ────────
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: FadeTransition(
                      opacity: _slideAnim,
                      child: Column(
                        children: [
                          // Rotating album art
                          AnimatedBuilder(
                            animation: _rotateAnim,
                            builder: (_, child) => Transform.rotate(
                              angle: _rotateAnim.value,
                              child: child,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer ring glow
                                AnimatedBuilder(
                                  animation: _pulseAnim,
                                  builder: (_, __) => Transform.scale(
                                    scale: isPlaying ? _pulseAnim.value : 1.0,
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accent.withOpacity(
                                                isPlaying ? 0.35 : 0.1),
                                            blurRadius: isPlaying ? 40 : 20,
                                            spreadRadius: isPlaying ? 12 : 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Album art circle
                                ClipOval(
                                  child: Container(
                                    width: 210,
                                    height: 210,
                                    color: AppTheme.cardBg,
                                    child: article.imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                      imageUrl: article.imageUrl,
                                      fit: BoxFit.cover,
                                      width: 210, height: 210,
                                    )
                                        : const Icon(Icons.article, color: AppTheme.textSecondary, size: 60),
                                  ),
                                ),
                                // Center hole
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary,
                                    border: Border.all(
                                        color: isPlaying ? AppTheme.accent : AppTheme.divider,
                                        width: 2),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Source + title
                          Text(article.sourceName.toUpperCase(),
                              style: GoogleFonts.sourceSans3(
                                  color: AppTheme.accent, fontSize: 11,
                                  fontWeight: FontWeight.w800, letterSpacing: 2.5)),
                          const SizedBox(height: 8),
                          Text(
                            article.title,
                            style: GoogleFonts.playfairDisplay(
                              color: AppTheme.textPrimary, fontSize: 18,
                              fontWeight: FontWeight.w700, height: 1.35,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(article.readableDate,
                              style: GoogleFonts.sourceSans3(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),                  ),
                ),

                // ── Waveform visualizer ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (_, __) => _WaveformVisualizer(
                        isPlaying: isPlaying, animValue: _waveController.value),
                  ),
                ),

                // ── Player controls ────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: AppTheme.divider, borderRadius: BorderRadius.circular(2)),
                      ),

                      // Progress dots (episode indicators)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          min(prov.trendingArticles.length, 7),
                              (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _currentIndex % 7 ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _currentIndex % 7
                                  ? AppTheme.accent
                                  : AppTheme.divider,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Prev
                          _ControlButton(
                            icon: Icons.skip_previous_rounded,
                            size: 30,
                            color: _currentIndex > 0
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            onTap: _prev,
                          ),
                          const SizedBox(width: 20),

                          // Rewind 10s (decorative — TTS doesn't seek)
                          _ControlButton(
                            icon: Icons.replay_10_rounded,
                            size: 26,
                            color: AppTheme.textSecondary,
                            onTap: () {},
                          ),
                          const SizedBox(width: 20),

                          // Play / Stop — main CTA
                          GestureDetector(
                            onTap: _stopOrPlay,
                            child: AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Transform.scale(
                                scale: isPlaying ? _pulseAnim.value * 0.98 : 1.0,
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.accent, Color(0xFFCC1A0A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accent.withOpacity(isPlaying ? 0.5 : 0.25),
                                        blurRadius: isPlaying ? 28 : 14,
                                        spreadRadius: isPlaying ? 4 : 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white, size: 38,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Forward 10s
                          _ControlButton(
                            icon: Icons.forward_10_rounded,
                            size: 26,
                            color: AppTheme.textSecondary,
                            onTap: () {},
                          ),
                          const SizedBox(width: 20),

                          // Next
                          _ControlButton(
                            icon: Icons.skip_next_rounded,
                            size: 30,
                            color: _currentIndex < prov.trendingArticles.length - 1
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            onTap: _next,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Status text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          key: ValueKey(_ttsState),
                          isPlaying
                              ? '▶  Now reading aloud...'
                              : '  Tap play to listen',
                          style: GoogleFonts.sourceSans3(
                              color: isPlaying ? AppTheme.accent : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Up Next list ───────────────────────────────
                Container(
                  color: AppTheme.surface,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: color),
    );
  }
}

class _WaveformVisualizer extends StatelessWidget {
  final bool isPlaying;
  final double animValue;

  const _WaveformVisualizer({required this.isPlaying, required this.animValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(30, (i) {
        final h = isPlaying
            ? (sin(i * 0.2 + animValue * pi * 2) + 1) / 2 * 30 + 4
            : 4.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 3,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(isPlaying ? 0.8 : 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
