import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/core/widgets/floating_tab_bar.dart';
import 'package:ai_books/features/home/screens/home_screen.dart';
import 'package:ai_books/features/library/screens/library_screen.dart';
import 'package:ai_books/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:ai_books/features/profile/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Bumped each time the Saved tab is tapped — BookmarksScreen listens and reloads.
  final ValueNotifier<int> _bookmarksRefresh = ValueNotifier<int>(0);

  late final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    BookmarksScreen(refreshTrigger: _bookmarksRefresh),
    const ProfileScreen(),
  ];

  void _onTabTap(int i) {
    setState(() => _currentIndex = i);
    if (i == 2) {
      // Trigger reload of saved items
      _bookmarksRefresh.value++;
    }
  }

  @override
  void dispose() {
    _bookmarksRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: FloatingTabBar(
                currentIndex: _currentIndex,
                onTap: _onTabTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
