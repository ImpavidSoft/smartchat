import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_chat/common/environment.dart';

/// A singleton class to handle saving and retrieving values from SharedPreferences
class SharedPrefsHelper {
  // Singleton instance
  static SharedPrefsHelper? _instance;

  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Keys for specific properties
  static const String _keyAutoScroll = 'auto_scroll';
  static const String _keySplitPosition = 'split_position';
  static const String _keyModel = 'model';

  // Default values
  static bool _autoScroll = Environment.autoScroll;
  static double _splitPosition = Environment.splitPosition;
  static String _model = Environment.model;

  // Private constructor
  SharedPrefsHelper._();

  // Factory constructor
  factory SharedPrefsHelper() {
    _instance ??= SharedPrefsHelper._();
    return _instance!;
  }

  /// Initialize the SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Saves a value to SharedPreferences based on its type
  Future<bool> saveValue<T>(String key, T value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      throw ArgumentError('Unsupported type: ${T.toString()}');
    }
  }

  /// Retrieves a value from SharedPreferences with the specified type
  T? getValue<T>(String key) {
    if (T == String) {
      return _prefs.getString(key) as T?;
    } else if (T == int) {
      return _prefs.getInt(key) as T?;
    } else if (T == double) {
      return _prefs.getDouble(key) as T?;
    } else if (T == bool) {
      return _prefs.getBool(key) as T?;
    } else if (T == List<String>) {
      return _prefs.getStringList(key) as T?;
    } else {
      throw ArgumentError('Unsupported type: ${T.toString()}');
    }
  }

  /// Removes a value from SharedPreferences
  Future<bool> removeValue(String key) async {
    return await _prefs.remove(key);
  }

  /// Clears all values from SharedPreferences
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // Property getters and setters using Dart's property syntax

  /// Gets the autoScroll value from SharedPreferences
  bool get autoScroll {
    final bool? value = getValue<bool>(_keyAutoScroll);
    return value ?? _autoScroll;
  }

  /// Sets the autoScroll value in SharedPreferences
  set autoScroll(bool value) {
    _autoScroll = value; // Update in-memory default
    saveValue<bool>(_keyAutoScroll, value);
  }

  /// Gets the splitPosition value from SharedPreferences
  double get splitPosition {
    final double? value = getValue<double>(_keySplitPosition);
    return value ?? _splitPosition;
  }

  /// Sets the splitPosition value in SharedPreferences
  set splitPosition(double value) {
    _splitPosition = value; // Update in-memory default
    saveValue<double>(_keySplitPosition, value);
  }

  /// Gets the model value from SharedPreferences
  String get model {
    final String? value = getValue<String>(_keyModel);
    return value ?? _model;
  }

  /// Sets the model value in SharedPreferences
  set model(String value) {
    _model = value; // Update in-memory default
    saveValue<String>(_keyModel, value);
  }

  /// Asynchronous method to save autoScroll value
  /// Returns Future[bool] for operation success/failure
  Future<bool> saveAutoScroll(bool value) async {
    autoScroll = value;
    return await saveValue<bool>(_keyAutoScroll, value);
  }

  /// Asynchronous method to save splitPosition value
  /// Returns Future[bool] for operation success/failure
  Future<bool> saveSplitPosition(double value) async {
    splitPosition = value;
    return await saveValue<double>(_keySplitPosition, value);
  }

  /// Asynchronous method to save model value
  /// Returns Future[bool] for operation success/failure
  Future<bool> saveModel(String value) async {
    model = value;
    return await saveValue<String>(_keyModel, value);
  }
}