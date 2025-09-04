// Mapper untuk konversi antara domain entities dan old models
import '../../domain/entities/entities.dart' as domain;
import '../models/models.dart' as oldModel;

/// Mapper untuk konversi antara domain dan old models
class EntityModelMapper {
  /// Convert domain LocalizationSheet to old model
  static oldModel.LocalizationSheet toOldModel(domain.LocalizationSheet domainSheet) {
    final entries = domainSheet.translations.map((translation) {
      return oldModel.LocalizationEntry(
        key: translation.key,
        translations: translation.values,
      );
    }).toList();

    return oldModel.LocalizationSheet(
      name: domainSheet.name,
      entries: entries,
      languageCodes: domainSheet.languageCodes,
    );
  }

  /// Convert old model LocalizationSheet to domain
  static domain.LocalizationSheet toDomainModel(oldModel.LocalizationSheet oldSheet) {
    final translations = oldSheet.entries.map((entry) {
      return domain.Translation(
        key: entry.key,
        values: entry.translations,
      );
    }).toList();

    final languages = oldSheet.languageCodes.map((code) {
      final normalizedCode = code.toLowerCase().trim();
      String languageCode;
      String? region;
      
      if (normalizedCode.contains('_')) {
        final parts = normalizedCode.split('_');
        languageCode = parts[0];
        region = parts.length > 1 ? parts[1] : null;
      } else if (normalizedCode.contains('-')) {
        final parts = normalizedCode.split('-');
        languageCode = parts[0];
        region = parts.length > 1 ? parts[1] : null;
      } else {
        languageCode = normalizedCode;
        region = null;
      }

      return domain.Language(
        code: languageCode,
        name: languageCode,
        region: region,
      );
    }).toList();

    return domain.LocalizationSheet(
      name: oldSheet.name,
      translations: translations,
      supportedLanguages: languages,
    );
  }

  /// Convert list of domain sheets to old models
  static List<oldModel.LocalizationSheet> toOldModels(List<domain.LocalizationSheet> domainSheets) {
    return domainSheets.map(toOldModel).toList();
  }

  /// Convert list of old models to domain sheets
  static List<domain.LocalizationSheet> toDomainModels(List<oldModel.LocalizationSheet> oldSheets) {
    return oldSheets.map(toDomainModel).toList();
  }
}
