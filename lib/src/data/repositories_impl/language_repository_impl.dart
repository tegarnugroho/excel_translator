// Implementation of language repository
import '../../domain/repositories/repositories.dart';
import '../sources/language_json_data_source.dart';
import '../sources/language_fallback_data_source.dart';

/// Implementation of language repository using data sources
class LanguageRepositoryImpl implements ILanguageRepository {
  final LanguageJsonDataSource _jsonDataSource;
  
  Set<String>? _validLanguageCodes;
  Map<String, String>? _languageNames;

  LanguageRepositoryImpl({
    LanguageJsonDataSource? jsonDataSource,
  }) : _jsonDataSource = jsonDataSource ?? LanguageJsonDataSource();

  @override
  Set<String> getValidLanguageCodes() {
    _ensureDataLoaded();
    return _validLanguageCodes!;
  }

  @override
  Map<String, String> getLanguageNames() {
    _ensureDataLoaded();
    return _languageNames!;
  }

  @override
  String getLanguageName(String code) {
    final lowercaseCode = code.toLowerCase();
    return getLanguageNames()[lowercaseCode] ?? lowercaseCode;
  }

  @override
  bool isValidLanguageCode(String code) {
    return getValidLanguageCodes().contains(code.toLowerCase());
  }

  @override
  Future<void> reload() async {
    _validLanguageCodes = null;
    _languageNames = null;
    _loadLanguageData();
  }

  void _ensureDataLoaded() {
    if (_validLanguageCodes == null || _languageNames == null) {
      _loadLanguageData();
    }
  }

  void _loadLanguageData() {
    try {
      final jsonData = _jsonDataSource.loadLanguageData();
      
      if (jsonData != null) {
        _parseJsonData(jsonData);
      } else {
        _useFallbackData();
      }
    } catch (e) {
      _useFallbackData();
    }
  }

  void _parseJsonData(Map<String, dynamic> data) {
    // Parse JSON data - direct array of language objects or wrapped in 'lang' property
    List<dynamic> langArray;
    
    if (data.containsKey('lang')) {
      // Format: {"lang": [...]}
      langArray = data['lang'] as List;
    } else {
      // Assume the data itself contains language info, convert to list
      throw Exception('Invalid language data format - expected "lang" property with array');
    }

    _validLanguageCodes = <String>{};
    _languageNames = <String, String>{};

    for (final langItem in langArray) {
      final langMap = langItem as Map<String, dynamic>;

      // Support both old and new formats
      String code;
      String name;

      if (langMap.containsKey('languageCode')) {
        // New format
        code = langMap['languageCode'] as String;
        name = langMap['language'] as String;
      } else {
        // Old format compatibility
        code = langMap['code'] as String;
        name = langMap['name'] as String;
      }

      _validLanguageCodes!.add(code.toLowerCase());
      _languageNames![code.toLowerCase()] = name.toLowerCase();
    }
  }

  void _useFallbackData() {
    _validLanguageCodes = LanguageFallbackDataSource.getFallbackLanguageCodes();
    _languageNames = LanguageFallbackDataSource.getFallbackLanguageNames();
  }
}
