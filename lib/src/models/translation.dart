/// Represents a translation entry with a key and its values in different languages
class Translation {
  final String key;
  final Map<String, String> values;

  const Translation({
    required this.key,
    required this.values,
  });

  Translation copyWith({
    String? key,
    Map<String, String>? values,
  }) {
    return Translation(
      key: key ?? this.key,
      values: values ?? this.values,
    );
  }

  @override
  String toString() => 'Translation(key: $key, values: $values)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Translation &&
        other.key == key &&
        _mapEquals(other.values, values);
  }

  @override
  int get hashCode => key.hashCode ^ values.hashCode;

  bool _mapEquals(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}
