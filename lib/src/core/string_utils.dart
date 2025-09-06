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
    String cleaned =
        sheetName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

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

  /// Convert snake_case to camelCase
  static String toCamelCase(String snakeCase) {
    final parts = snakeCase.toLowerCase().split('_');
    if (parts.length <= 1) return snakeCase.toLowerCase();

    return parts.first +
        parts
            .skip(1)
            .map((part) => part.isEmpty ? '' : capitalize(part))
            .join('');
  }

  /// Convert camelCase to snake_case
  static String toSnakeCase(String camelCase) {
    return camelCase
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
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
