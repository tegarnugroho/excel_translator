// String utility functions for Excel Translator

/// String manipulation utilities
class StringUtils {
  /// Capitalize first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Sanitize class name for Dart classes
  /// Examples: "auth-errors" -> "AuthErrors", "mobile-errors" -> "MobileErrors"
  static String sanitizeClassName(String name) {
    if (name.isEmpty) return name;

    // Replace hyphens, underscores, and spaces with nothing, but treat them as word boundaries
    final parts = name.toLowerCase().split(RegExp(r'[-_\s]+'));

    // Capitalize each part and join
    final result = parts
        .where((part) => part.isNotEmpty)
        .map((part) => capitalize(part))
        .join('');

    // Remove any remaining non-alphanumeric characters
    final cleaned = result.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // If starts with number, add prefix
    if (cleaned.isNotEmpty && RegExp(r'^[0-9]').hasMatch(cleaned)) {
      return 'Class${cleaned}';
    }
    return cleaned;
  }

  /// Sanitize file name for Dart files
  /// Examples: "auth-errors" -> "auth_errors", "mobile-errors" -> "mobile_errors"
  static String sanitizeFileName(String name) {
    if (name.isEmpty) return name;

    // Convert to lowercase and replace hyphens and spaces with underscores
    final result = name
        .toLowerCase()
        .replaceAll(RegExp(r'[-\s]+'), '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    // If starts with number, add prefix
    if (result.isNotEmpty && RegExp(r'^[0-9]').hasMatch(result)) {
      return 'file_${result}';
    }
    return result;
  }

  /// Sanitize property name for Dart properties (camelCase)
  /// Examples: "auth-errors" -> "authErrors", "en_US" -> "enUs", "de_DE" -> "deDe"
  static String sanitizePropertyName(String name) {
    if (name.isEmpty) return name;

    // Convert to camelCase: split by hyphens/spaces/underscores, capitalize each word except first
    final parts = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\-\s_]'), '')
        .split(RegExp(r'[-\s_]+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'property';

    // First part lowercase, rest capitalize first letter
    final result =
        parts.first +
        parts
            .skip(1)
            .map(
              (part) => part.substring(0, 1).toUpperCase() + part.substring(1),
            )
            .join('');

    // If starts with number, add prefix
    if (result.isNotEmpty && RegExp(r'^[0-9]').hasMatch(result)) {
      return 'property${result.substring(0, 1).toUpperCase()}${result.substring(1)}';
    }

    return result;
  }

  /// Sanitize sheet name for class naming
  static String sanitizeSheetName(String sheetName) {
    String cleaned = sheetName.toLowerCase().replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );

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
      final camelCase =
          parts.first +
          parts
              .skip(1)
              .map(
                (part) => part.isEmpty
                    ? ''
                    : part[0].toUpperCase() + part.substring(1),
              )
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
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '');
  }

  /// Extract interpolation parameters from text
  /// Supports three formats:
  /// - Curly brace style: `{param}` → ["param"]
  /// - Positional printf style: `%1$s`, `%2$s` → ["1", "2"]
  /// - Named printf style: `%information$s`, `%name$s` → ["information", "name"]
  static List<String> extractInterpolationParams(String text) {
    // Matches {paramName}, %123$s (numeric), and %paramName$s (named)
    final regex = RegExp(r'\{([^}]+)\}|%([a-zA-Z_][a-zA-Z0-9_]*|\d+)\$s');
    final matches = regex.allMatches(text);

    final params = <String>{};

    for (final match in matches) {
      if (match.group(1) != null) {
        // Curly brace format: {param}
        params.add(match.group(1)!);
      } else if (match.group(2) != null) {
        // Printf format: %param$s or %123$s
        params.add(match.group(2)!);
      }
    }

    return params.toList();
  }

  /// Check if text contains interpolation parameters
  static bool hasInterpolation(String text) {
    return text.contains(RegExp(r'\{[^}]+\}|%([a-zA-Z_][a-zA-Z0-9_]*|\d+)\$s'));
  }

  /// Normalize interpolation parameters to curly brace format
  /// Converts `%param$s` to `{param}` for consistent handling
  static String normalizeInterpolation(String text) {
    return text.replaceAllMapped(
      RegExp(r'%([a-zA-Z_][a-zA-Z0-9_]*|\d+)\$s'),
      (match) => '{${match.group(1)}}',
    );
  }
}
