import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:due_guard/core/constants/app_colors.dart';
import 'package:due_guard/core/constants/app_routes.dart';
import 'package:due_guard/features/dueguard/presentation/provider/item_provider.dart';
import 'package:due_guard/features/dueguard/presentation/screens/home_screen.dart';
import 'package:due_guard/features/dueguard/presentation/screens/add_edit_screen.dart';
import 'package:due_guard/features/dueguard/presentation/screens/analytics_screen.dart';
import 'package:due_guard/features/dueguard/presentation/screens/profile_screen.dart';
import 'package:due_guard/features/dueguard/presentation/screens/get_started_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ItemProvider()..loadItems(),
      child: const DueGuardApp(),
    ),
  );
}

class DueGuardApp extends StatelessWidget {
  const DueGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DueGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: AppRoutes.start,
      routes: {
        AppRoutes.start: (context) => const GetStartedScreen(),
        AppRoutes.home: (context) => const AppShell(),
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  final _pages = const [
    HomeScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  void _openAdd() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddEditScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentTab: _tab,
        onHome: () => setState(() => _tab = 0),
        onInsights: () => setState(() => _tab = 1),
        onAdd: _openAdd,
        onProfile: () => setState(() => _tab = 2),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentTab;
  final VoidCallback onHome;
  final VoidCallback onInsights;
  final VoidCallback onAdd;
  final VoidCallback onProfile;

  const _BottomNav({
    required this.currentTab,
    required this.onHome,
    required this.onInsights,
    required this.onAdd,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(Icons.home_outlined, Icons.home, 'Home', 0, onHome),
              _navItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Insights',
                  1, onInsights),
              _navItem(Icons.add, Icons.add, 'Add', -1, onAdd),
              _navItem(Icons.person_outline, Icons.person, 'Profile', 2,
                  onProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index,
      VoidCallback onTap) {
    final selected = currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}
