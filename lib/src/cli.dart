import 'dart:io';
import 'translator_service.dart';
import 'services/services.dart';

/// Command line interface for Excel Translator
class ExcelTranslatorCLI {
  final TranslatorService _translatorService;

  ExcelTranslatorCLI(this._translatorService);

  /// Factory constructor with default service
  factory ExcelTranslatorCLI.create() {
    return ExcelTranslatorCLI(TranslatorService.create());
  }

  /// Run the CLI with provided arguments
  Future<void> run(List<String> arguments) async {
    // If no arguments, try to auto-detect from pubspec.yaml
    if (arguments.isEmpty) {
      await _runFromPubspec();
      return;
    }

    // Handle special commands first
    if (arguments.length == 1) {
      if (arguments[0] == '--help' || arguments[0] == '-h') {
        _printUsage();
        return;
      } else if (arguments[0] == '--version' || arguments[0] == '-v') {
        _printVersion();
        return;
      } else if (arguments[0] == 'log') {
        await _printConfig();
        return;
      }
    }

    // Require at least 2 arguments for manual mode
    if (arguments.length < 2) {
      _printUsage();
      throw Exception(
        'Insufficient arguments. Use --help for usage information.',
      );
    }

    final filePath = arguments[0];
    final outputDir = arguments[1];
    String className = 'AppLocalizations';
    bool includeFlutterDelegates = true;

    // Parse optional arguments
    for (int i = 2; i < arguments.length; i++) {
      final arg = arguments[i];
      if (arg.startsWith('--class-name=')) {
        className = arg.substring('--class-name='.length);
      } else if (arg.startsWith('-c=')) {
        className = arg.substring('-c='.length);
      } else if (arg == '--no-delegates' ||
          arg == '--no-flutter-delegates' ||
          arg == '-nd') {
        includeFlutterDelegates = false;
      } else if (arg.startsWith('--delegates=')) {
        final value = arg.substring('--delegates='.length);
        includeFlutterDelegates = value.toLowerCase() == 'true';
      } else if (arg.startsWith('-d=')) {
        final value = arg.substring('-d='.length);
        includeFlutterDelegates = value.toLowerCase() == 'true';
      }
    }

    try {
      await _translatorService.generateFromFile(
        filePath: filePath,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates,
      );
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // Private methods

  Future<void> _runFromPubspec() async {
    try {
      await _translatorService.generateFromPubspec();
    } catch (e) {
      print('Error: $e');
      print('\nTip: Add excel_translator configuration to your pubspec.yaml:');
      print('');
      print('excel_translator:');
      print('  excel_file: assets/localizations.xlsx');
      print('  output_dir: lib/generated');
      print('  class_name: AppLocalizations  # optional');
      print('');
      print('Or provide parameters:');
      print('  dart run excel_translator <file> <output_dir>');
      rethrow;
    }
  }

  Future<void> _printConfig() async {
    final configService = ConfigService();
    final config = configService.loadFromPubspec();

    print('Excel Translator Configuration:');
    print('================================');

    if (config != null) {
      print('Excel File: ${config.excelFilePath ?? "(not set)"}');
      print('Output Dir: ${config.outputDir ?? "(not set)"}');
      print('Class Name: ${config.className ?? "AppLocalizations"}');
      print(
        'Include Delegates: ${(config.includeFlutterDelegates ?? true) ? "true" : "false"}',
      );
    } else {
      print('No configuration found in pubspec.yaml');
      print('');
      print('Add excel_translator section to pubspec.yaml:');
      print('');
      print('excel_translator:');
      print('  excel_file: assets/localizations.xlsx');
      print('  output_dir: lib/generated');
      print('  class_name: AppLocalizations  # optional');
    }
  }

  void _printUsage() {
    // Show version first
    _printVersion();
    print('');
    print('Excel Translator - Generate type-safe Flutter localizations');
    print('');
    print('Usage:');
    print(
      '  dart run excel_translator                    # Auto-detect from pubspec.yaml',
    );
    print(
      '  dart run excel_translator <file> <output>    # Generate from file',
    );
    print(
      '  dart run excel_translator log                # Show current config',
    );
    print('  dart run excel_translator --help             # Show this help');
    print('  dart run excel_translator --version          # Show version');
    print('');
    print('Arguments:');
    print(
      '  <file>                  Excel/CSV/ODS file path (.xlsx, .csv, .ods)',
    );
    print('  <output>                Output directory');
    print('');
    print('Options:');
    print(
      '  -c, --class-name=NAME   Generated class name (default: AppLocalizations)',
    );
    print(
      '  -d, --delegates=BOOL    Include Flutter delegates (default: true)',
    );
    print('  --no-delegates          Disable Flutter delegates');
    print('  -v, --version           Show version');
    print('  -h, --help              Show this help');
    print('');
    print('Examples:');
    print(
      '  dart run excel_translator assets/localizations.xlsx lib/generated',
    );
    print('  dart run excel_translator file.csv lib/l10n --class-name=L10n');
    print('  dart run excel_translator file.ods lib/i18n --no-delegates');
    print('');
    print('Configuration (pubspec.yaml):');
    print('  excel_translator:');
    print('    excel_file: assets/localizations.xlsx');
    print('    output_dir: lib/generated');
    print('    class_name: AppLocalizations  # optional');
  }

  void _printVersion() {
    // Try to read version from pubspec.yaml in current directory
    try {
      final pubspecFile = File('pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final versionMatch = RegExp(r'version:\s*([^\s]+)').firstMatch(content);
        if (versionMatch != null) {
          final version = versionMatch.group(1)!;
          // If we're in an example or test directory, try to find the main package version
          if (version.contains('1.0.0') &&
              File('../pubspec.yaml').existsSync()) {
            final mainPubspec = File('../pubspec.yaml');
            final mainContent = mainPubspec.readAsStringSync();
            final mainVersionMatch = RegExp(
              r'version:\s*([^\s]+)',
            ).firstMatch(mainContent);
            if (mainVersionMatch != null) {
              print('Excel Translator v${mainVersionMatch.group(1)}');
              return;
            }
          }
          print('Excel Translator v$version');
          return;
        }
      }
    } catch (e) {
      // Fall back to hardcoded version if reading fails
    }
    print('Excel Translator v2.0.0');
  }
}
