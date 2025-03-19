
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'environment.dart';

final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

String _getLoggingTime() {
  return _dateTimeFormat.format(DateTime.now());
}

void logDebug(final Object o) {
  if (!Environment.isDebugBuild) {
    _log('DEBUG', '$o', false);
  }
}

void logDebugT(final Object o) {
  if (!Environment.isDebugBuild) {
    _log('DEBUG', '$o', true);
  }
}

void logInfo(final Object o) {
  _log('INFO', '$o', false);
}

void logInfoT(final Object o) {
  _log('INFO', '$o', true);
}

void logWarn(final Object o, [final Exception? ex]) {
  final String exceptionString = (ex != null ? ': $ex' : '');
  _log('WARN', '$o $exceptionString', false);
}

void logWarnT(final Object o, [final Exception? ex]) {
  final String exceptionString = (ex != null ? ': $ex' : '');
  _log('WARN', '$o $exceptionString', true);
}

void logError(final Object o, [final Exception? ex]) {
  final String exceptionString = (ex != null ? ': $ex' : '');
  _log('ERROR', '$o $exceptionString', false);
}

void logErrorT(final Object o, [final Exception? ex]) {
  final String exceptionString = (ex != null ? ': $ex' : '');
  _log('ERROR', '$o $exceptionString', true);
}

void _log(final String level, final String message, final bool withTime) {
  int chunkSize = 1024;
  if (message.length > chunkSize) {
    _debugPrint(level, '-- LONG MESSAGE START --', withTime);
    List<String> chunks = _splitString(message, chunkSize);
    for (String chunk in chunks) {
      debugPrint(chunk, wrapWidth: chunkSize);
    }
    _debugPrint(level, '-- LONG MESSAGE END --', withTime);
  } else {
    _debugPrint(level, message, withTime);
  }
}

void _debugPrint(final String level, final String message, final bool withTime) {
  if (withTime) {
    debugPrint('${_getLoggingTime()} [$level]: $message - [$level]', wrapWidth: 256);
  } else {
    debugPrint('[$level]: $message - [$level]', wrapWidth: 256);
  }
}

List<String> _splitString(String input, int chunkSize) {
  List<String> chunks = [];
  for (int i = 0; i < input.length; i += chunkSize) {
    int end = (i + chunkSize < input.length) ? i + chunkSize : input.length;
    chunks.add(input.substring(i, end));
  }
  return chunks;
}
