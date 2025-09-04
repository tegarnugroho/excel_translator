// Base generator interface
import '../../data/models/models.dart';

/// Base interface for code generators
abstract class BaseGenerator {
  /// Generate code for the given sheets
  Future<void> generate(
    List<LocalizationSheet> sheets,
    String outputDir, {
    Map<String, dynamic>? options,
  });

  /// Get generator name for logging
  String get generatorName;

  /// Validate input before generation
  bool validateInput(List<LocalizationSheet> sheets) {
    return sheets.isNotEmpty;
  }
}
