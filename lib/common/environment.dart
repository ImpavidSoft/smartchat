import 'package:flutter/foundation.dart';

import '../src/chat_clients/chat_gpt/chat_gpt_constants.dart';

class Environment {
  // Default values
  static bool autoScroll = true;
  static double splitPosition = 0.5;
  static String model = ChatGptConstants.model;

  static bool get isDebugBuild => kDebugMode;
}