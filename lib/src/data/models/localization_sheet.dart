import 'localization_entry.dart';

class LocalizationSheet {
  final String name;
  final List<LocalizationEntry> entries;
  final List<String> languageCodes;

  const LocalizationSheet({
    required this.name,
    required this.entries,
    required this.languageCodes,
  });

  @override
  String toString() {
    return 'LocalizationSheet(name: $name, entries: ${entries.length}, languages: $languageCodes)';
  }
}
