// Excel Translator - Generate localizations from Excel files
library excel_translator;

// Export only WASM-compatible runtime parts for library users
export 'src/data/models/models.dart';

// Re-export flutter_localizations so users don't need to add it manually
export 'package:flutter_localizations/flutter_localizations.dart';
