/// Configuration for Excel Translator
class ExcelTranslatorConfig {
  final String? excelFilePath;
  final String? outputDir;
  final String? className;
  final bool? includeFlutterDelegates;

  const ExcelTranslatorConfig({
    this.excelFilePath,
    this.outputDir,
    this.className,
    this.includeFlutterDelegates,
  });

  /// Create a copy with modified fields
  ExcelTranslatorConfig copyWith({
    String? excelFilePath,
    String? outputDir,
    String? className,
    bool? includeFlutterDelegates,
  }) {
    return ExcelTranslatorConfig(
      excelFilePath: excelFilePath ?? this.excelFilePath,
      outputDir: outputDir ?? this.outputDir,
      className: className ?? this.className,
      includeFlutterDelegates:
          includeFlutterDelegates ?? this.includeFlutterDelegates,
    );
  }

  /// Merge this config with another, giving priority to the other
  ExcelTranslatorConfig mergeWith(ExcelTranslatorConfig? other) {
    if (other == null) return this;

    return ExcelTranslatorConfig(
      excelFilePath: other.excelFilePath ?? excelFilePath,
      outputDir: other.outputDir ?? outputDir,
      className: other.className ?? className,
      includeFlutterDelegates: other.includeFlutterDelegates ?? includeFlutterDelegates,
    );
  }

  @override
  String toString() {
    return 'ExcelTranslatorConfig(excelFilePath: $excelFilePath, outputDir: $outputDir, className: $className, includeFlutterDelegates: $includeFlutterDelegates)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExcelTranslatorConfig &&
        other.excelFilePath == excelFilePath &&
        other.outputDir == outputDir &&
        other.className == className &&
        other.includeFlutterDelegates == includeFlutterDelegates;
  }

  @override
  int get hashCode {
    return excelFilePath.hashCode ^
        outputDir.hashCode ^
        className.hashCode ^
        includeFlutterDelegates.hashCode;
  }
}
