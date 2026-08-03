/// Represents a language with its code, name, and optional region
class Language {
  final String code;
  final String name;
  final String? region;

  const Language({required this.code, required this.name, this.region});

  /// Create a locale-specific language (e.g., en_US, pt_BR)
  Language.locale({
    required this.code,
    required this.name,
    required this.region,
  });

  /// Canonical form of a raw header code: 'en-US', ' EN_us ' -> 'en_us'.
  ///
  /// Translation values must be keyed by this form, otherwise they no longer
  /// match [fullCode] and the whole column reads as empty.
  static String normalizeCode(String raw) =>
      raw.toLowerCase().trim().replaceAll('-', '_');

  /// Build a language from a raw header code ('en', 'en_US', 'pt-BR').
  factory Language.fromCode(String raw) {
    final parts = normalizeCode(raw).split('_');
    return Language(
      code: parts.first,
      name: parts.first, // Will be resolved by validation repository
      region: parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null,
    );
  }

  /// Get the full language code including region if present
  String get fullCode {
    if (region != null && region!.isNotEmpty) {
      return '${code}_$region';
    }
    return code;
  }

  /// Check if this is a locale-specific language
  bool get hasRegion => region != null && region!.isNotEmpty;

  Language copyWith({String? code, String? name, String? region}) {
    return Language(
      code: code ?? this.code,
      name: name ?? this.name,
      region: region ?? this.region,
    );
  }

  @override
  String toString() => 'Language(code: $code, name: $name, region: $region)';

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
