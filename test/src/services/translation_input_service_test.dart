import 'dart:convert';
import 'dart:io';

import 'package:excel_translator/src/services/translation_input_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const commonCsv = 'key,en,id\napp_name,Example,Contoh\n';
  const authCsv = 'key,en,id\nlogin_title,Sign in,Masuk\n';

  group('TranslationInputService', () {
    late TranslationInputService service;

    setUp(() => service = TranslationInputService());

    test(
      'derives CSV modules from filenames and preserves translations',
      () async {
        final contents = {
          'assets/common.csv': commonCsv,
          'assets/auth.csv': authCsv,
          'assets/home_explore.csv':
              'key,en,id\nexplore_title,Explore,Jelajahi\n',
          'assets/events.csv': 'key,en,id\nevent_title,Events,Acara\n',
        };

        final sheets = await service.parseFiles(
          contents.keys.toList(),
          loadBytes: (filePath) async => utf8.encode(contents[filePath]!),
        );

        expect(
          sheets.map((sheet) => sheet.name),
          equals(['common', 'auth', 'home_explore', 'events']),
        );
        expect(sheets[1].languageCodes, equals(['en', 'id']));
        expect(sheets[1].getValue('login_title', 'id'), equals('Masuk'));
        expect(sheets[2].getValue('explore_title', 'en'), equals('Explore'));
      },
    );

    test('rejects duplicate file paths', () async {
      expect(
        () => service.parseFiles([
          'assets/auth.csv',
          'assets/auth.csv',
        ], loadBytes: (_) async => utf8.encode(authCsv)),
        throwsA(
          predicate(
            (error) =>
                error.toString().contains('Duplicate translation file path'),
          ),
        ),
      );
    });

    test('rejects duplicate generated module names', () async {
      expect(
        () => service.parseFiles([
          'features/auth.csv',
          'legacy/auth.csv',
        ], loadBytes: (_) async => utf8.encode(authCsv)),
        throwsA(
          predicate(
            (error) => error.toString().contains(
              'Duplicate localization module "auth"',
            ),
          ),
        ),
      );
    });

    test('rejects unsupported extensions before loading', () async {
      expect(
        () => service.parseFiles([
          'assets/auth.json',
        ], loadBytes: (_) async => const []),
        throwsA(
          predicate(
            (error) => error.toString().contains('Unsupported file format'),
          ),
        ),
      );
    });

    test('rejects invalid generated module names', () async {
      expect(
        () => service.parseFiles([
          'assets/!!!.csv',
        ], loadBytes: (_) async => utf8.encode(authCsv)),
        throwsA(
          predicate(
            (error) =>
                error.toString().contains('Invalid localization module "!!!"'),
          ),
        ),
      );
    });

    test('reports missing filesystem inputs', () async {
      final missingPath = '${Directory.systemTemp.path}/missing_l10n.csv';

      expect(
        () => service.parseFileSystemFiles([missingPath]),
        throwsA(
          predicate(
            (error) =>
                error.toString().contains('File not found: $missingPath'),
          ),
        ),
      );
    });
  });
}
