// lib/widgets/main_shell.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/play_news_screen.dart';
import '../screens/trending_news_screen.dart';
import '../screens/saved_articles_screen.dart';
import '../screens/ai_chatbot_screen.dart';
import '../theme/app_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    TrendingNewsScreen(),
    SavedArticlesScreen(),
    PlayNewsScreen(),
    AiChatbotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.accent,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 26),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department_rounded, size: 26),
              label: 'Trending',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_rounded, size: 26),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headphones_rounded, size: 26),
              label: 'Audio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded, size: 26),
              label: 'Chatbot',
            ),
          ],
        ),
      ),
    );
  }
}
