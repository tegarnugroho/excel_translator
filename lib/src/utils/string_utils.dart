// String utility functions for Excel Translator

/// String manipulation utilities
class StringUtils {
  /// Capitalize first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Sanitize sheet name for class naming
  static String sanitizeSheetName(String sheetName) {
    String cleaned = sheetName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    // If starts with number, add prefix
    if (cleaned.isNotEmpty && RegExp(r'^[0-9]').hasMatch(cleaned)) {
      return 'sheet\$${cleaned}';
    }
    return cleaned;
  }

  /// Sanitize method name - convert to camelCase
  /// Example: app_title -> appTitle, welcome_message -> welcomeMessage
  static String sanitizeMethodName(String key) {
    // Convert to camelCase
    final parts = key.toLowerCase().split('_');
    String result;
    
    if (parts.length <= 1) {
      result = key.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    } else {
      final camelCase = parts.first +
          parts
              .skip(1)
              .map((part) =>
                  part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1))
              .join('');

      result = camelCase.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }

    // Add key prefix if starts with number
    if (result.isNotEmpty && RegExp(r'^[0-9]').hasMatch(result)) {
      return 'key\$${result}';
    }
    return result;
  }

  /// Extract interpolation parameters from text
  /// Example: "Welcome {name}!" -> ["name"]
  static List<String> extractInterpolationParams(String text) {
    final regex = RegExp(r'\{([^}]+)\}');
    final matches = regex.allMatches(text);
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  /// Check if text contains interpolation parameters
  static bool hasInterpolation(String text) {
    return text.contains(RegExp(r'\{[^}]+\}'));
  }
}
