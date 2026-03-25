// lib/widgets/main_shell.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/play_news_screen.dart';
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
    _PlaceholderScreen('Trending News'),
    _PlaceholderScreen('Saved News'),
    PlayNewsScreen(),
    _PlaceholderScreen('Chatbot'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppTheme.cardBg, // Use a clean white background
        selectedItemColor: AppTheme.accent, // Use deep purple for selected item
        unselectedItemColor: AppTheme.textSecondary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department, size: 28),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 28),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones, size: 28),
            label: 'Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy, size: 28),
            label: 'Chatbot',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black))),
      body: Center(
        child: Text(
          '$title (Coming Soon)',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }
}
