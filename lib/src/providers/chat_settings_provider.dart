import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Settings provider class
class ChatSettingsProvider extends ChangeNotifier {
  // Default values
  bool _autoScroll = true;
  double _splitPosition = 0.5;
  String _model = ChatGptConstants.model;

  // Getters
  bool get autoScroll => _autoScroll;
  double get splitPosition => _splitPosition;
  String get model => _model;

  // Private constructor
  ChatSettingsProvider._();

  // Singleton instance
  static ChatSettingsProvider? _instance;

  // Factory constructor to get or create the singleton instance
  static Future<ChatSettingsProvider> getInstance() async {
    if (_instance == null) {
      _instance = ChatSettingsProvider._();
      await _instance!._loadSettings();
    }
    return _instance!;
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoScroll = prefs.getBool('autoScroll') ?? true;
    _splitPosition = prefs.getDouble('splitPosition') ?? 0.5;
    _model = prefs.getString('model') ?? ChatGptConstants.model;
    notifyListeners();
  }

  // Update auto-scroll setting
  Future<void> setAutoScroll(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoScroll', value);
    _autoScroll = value;
    notifyListeners();
  }

  // Update split position setting
  Future<void> setSplitPosition(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('splitPosition', value);
    _splitPosition = value;
    notifyListeners();
  }

  // Update model setting
  Future<void> setModel(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model', value);
    _model = value;
    notifyListeners();
  }
}