// Simple logger for Excel Translator

enum LogLevel { debug, info, warning, error }

/// Simple console logger
class Logger {
  static LogLevel _level = LogLevel.info;

  /// Set the minimum log level
  static void setLevel(LogLevel level) {
    _level = level;
  }

  /// Log debug message
  static void debug(String message) {
    if (_level.index <= LogLevel.debug.index) {
      print('DEBUG: $message');
    }
  }

  /// Log info message
  static void info(String message) {
    if (_level.index <= LogLevel.info.index) {
      print('INFO: $message');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (_level.index <= LogLevel.warning.index) {
      print('WARNING: $message');
    }
  }

  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_level.index <= LogLevel.error.index) {
      print('ERROR: $message');
      if (error != null) {
        print('   Cause: $error');
      }
      if (stackTrace != null) {
        print('   Stack trace: $stackTrace');
      }
    }
  }

  /// Log success message
  static void success(String message) {
    if (_level.index <= LogLevel.info.index) {
      print('SUCCESS: $message');
    }
  }

  /// Log progress message
  static void progress(String message) {
    if (_level.index <= LogLevel.info.index) {
      print('PROGRESS: $message');
    }
  }
}
