// Excel Translator - Generate localizations from Excel files
library excel_translator;

// Export domain layer (business logic)
export 'src/domain/domain.dart';

// Export application service
export 'src/application/translator_service.dart';

// Export core utilities
export 'src/core/core.dart';

// Export data layer for advanced usage (hiding conflicting names)
export 'src/data/data.dart' hide LocalizationSheet, LocalizationEntry;

// Re-export flutter_localizations so users don't need to add it manually
export 'package:flutter_localizations/flutter_localizations.dart';
