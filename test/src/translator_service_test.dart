import 'package:test/test.dart';
import '../../lib/src/translator_service.dart';

void main() {
  group('TranslatorService Tests', () {
    test('should create service with factory constructor', () {
      // Act
      final service = TranslatorService.create();

      // Assert
      expect(service, isNotNull);
      expect(service, isA<TranslatorService>());
    });

    test('should have proper service architecture with all dependencies', () {
      // This test verifies that the service can be instantiated
      // with all its dependencies properly wired
      expect(() => TranslatorService.create(), returnsNormally);
    });
  });
}
