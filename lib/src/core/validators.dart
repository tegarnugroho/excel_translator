// Validation utilities for Excel Translator
import 'dart:io';

/// Validation utilities
class Validators {
  /// Validate file exists
  static bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Validate directory exists
  static bool directoryExists(String dirPath) {
    return Directory(dirPath).existsSync();
  }

  /// Validate file extension
  static bool hasValidExtension(String filePath, List<String> validExtensions) {
    final extension = filePath.toLowerCase().split('.').last;
    return validExtensions.any((ext) => ext.toLowerCase() == extension);
  }

  /// Validate class name format
  static bool isValidClassName(String className) {
    if (className.isEmpty) return false;
    
    // Must start with letter or underscore
    if (!RegExp(r'^[a-zA-Z_]').hasMatch(className)) return false;
    
    // Can only contain letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(className)) return false;
    
    return true;
  }

  /// Validate method name format
  static bool isValidMethodName(String methodName) {
    if (methodName.isEmpty) return false;
    
    // Must start with letter or underscore
    if (!RegExp(r'^[a-zA-Z_]').hasMatch(methodName)) return false;
    
    // Can only contain letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(methodName)) return false;
    
    return true;
  }

  /// Validate non-empty string
  static bool isNonEmptyString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate language code format (basic validation)
  static bool isValidLanguageCodeFormat(String code) {
    if (code.isEmpty) return false;
    
    // Basic format: 2-3 letters, optionally followed by underscore/dash and 2 letters
    return RegExp(r'^[a-zA-Z]{2,3}([_-][a-zA-Z]{2})?$').hasMatch(code);
  }
}
