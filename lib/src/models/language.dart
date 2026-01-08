/// Represents a language with its code, name, and optional region
class Language {
  final String code;
  final String name;
  final String? region;

  const Language({
    required this.code,
    required this.name,
    this.region,
  });

  /// Create a locale-specific language (e.g., en_US, pt_BR)
  Language.locale({
    required this.code,
    required this.name,
    required this.region,
  });

  /// Get the full language code including region if present
  String get fullCode {
    if (region != null && region!.isNotEmpty) {
      return '${code}_$region';
    }
    return code;
  }

  /// Check if this is a locale-specific language
  bool get hasRegion => region != null && region!.isNotEmpty;

  Language copyWith({
    String? code,
    String? name,
    String? region,
  }) {
    return Language(
      code: code ?? this.code,
      name: name ?? this.name,
      region: region ?? this.region,
    );
  }

  @override
  String toString() =>
      'Language(code: $code, name: $name, region: $region)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language &&
        other.code == code &&
        other.name == name &&
        other.region == region;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ region.hashCode;
}
