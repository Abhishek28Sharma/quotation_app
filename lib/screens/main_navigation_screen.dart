import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'generator_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  AgencySettings _settings = const AgencySettings();
  bool _isLoading = true;

  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
  }

  Future<void> _loadInitialSettings() async {
    final settings = await StorageService.loadSettings();
    if (mounted) {
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    }
  }

  void _onQuoteSaved() {
    _historyKey.currentState?.loadQuotes();
  }

  void _onSettingsUpdated(AgencySettings updated) {
    setState(() {
      _settings = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primarySky),
        ),
      );
    }

    final pages = [
      GeneratorScreen(
        settings: _settings,
        onQuoteSaved: _onQuoteSaved,
      ),
      HistoryScreen(
        key: _historyKey,
        settings: _settings,
      ),
      SettingsScreen(
        currentSettings: _settings,
        onSettingsUpdated: _onSettingsUpdated,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            _historyKey.currentState?.loadQuotes();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: AppTheme.primarySky),
            label: 'New Quote',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.primarySky),
            label: 'Saved Quotes',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune, color: AppTheme.primarySky),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
