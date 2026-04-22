import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/core/widgets/floating_tab_bar.dart';
import 'package:ai_books/features/home/screens/home_screen.dart';
import 'package:ai_books/features/library/screens/library_screen.dart';
import 'package:ai_books/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:ai_books/features/profile/screens/profile_screen.dart';

/// Tab indices for the floating bottom nav.
class MainShellTabs {
  MainShellTabs._();
  static const int home = 0;
  static const int library = 1;
  static const int saved = 2;
  static const int profile = 3;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Pop everything back to the root MainShell and switch to the given tab.
  /// Defaults to the Home tab.
  static void goToTab(BuildContext context, {int tab = MainShellTabs.home}) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    final state = context.findRootAncestorStateOfType<_MainShellState>();
    state?.switchTab(tab);
  }

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
    if (i == MainShellTabs.saved) {
      _bookmarksRefresh.value++;
    }
  }

  /// Public — switch to the given tab from anywhere in the widget tree.
  void switchTab(int tab) {
    if (tab < 0 || tab >= _screens.length) return;
    setState(() => _currentIndex = tab);
    if (tab == MainShellTabs.saved) {
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
