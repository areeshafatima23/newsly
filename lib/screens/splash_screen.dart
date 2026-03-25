// lib/screens/splash_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/news_provider.dart';
import 'home_screen.dart';
import '../widgets/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  Future<void> _loadDataAndNavigate() async {
    // Start fetching news
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    
    // We can run these in parallel
    await Future.wait([
      newsProvider.fetchHomeArticles(),
      // Add a minimum delay of 2.5 seconds so the user can see the splash screen
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEADDFF), // Light purple background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mocking the news icon from the screenshot
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                size: 64,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            
            // Dashed border around NEWSLY
            CustomPaint(
              painter: _DashedRectPainter(color: Colors.deepPurple),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                child: Text(
                  'NEWSLY',
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            
            // Loading text
            const Text(
              'Loading News for you...',
              style: TextStyle(
                fontFamily: 'Playfair',
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            
            // Spinner
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const CupertinoActivityIndicator(
                radius: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double dashWidth = 8, dashSpace = 6;
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), 
        const Radius.circular(8));
        
    Path path = Path()..addRRect(rrect);
    
    // Create dashed path
    Path dashPath = Path();
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0;
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth), 
          Offset.zero
        );
        distance += dashWidth + dashSpace;
      }
    }
    
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
