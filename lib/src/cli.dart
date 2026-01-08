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
        exit(0);
      } else if (arguments[0] == 'log') {
        await _printConfig();
        exit(0);
      }
    }

    // Require at least 2 arguments for manual mode
    if (arguments.length < 2) {
      _printUsage();
      exit(1);
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
      } else if (arg == '--no-delegates' || arg == '-nd') {
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
      exit(0);
    } catch (e) {
      print('Error: $e');
      exit(1);
    }
  }

  // Private methods

  Future<void> _runFromPubspec() async {
    try {
      await _translatorService.generateFromPubspec();
      exit(0);
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
      exit(1);
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
          'Include Delegates: ${config.includeFlutterDelegates ? "true" : "false"}');
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
    print('Excel Translator - Generate type-safe Flutter localizations');
    print('');
    print('Usage:');
    print('  dart run excel_translator                    # Auto-detect from pubspec.yaml');
    print('  dart run excel_translator <file> <output>    # Generate from file');
    print('  dart run excel_translator log                # Show current config');
    print('  dart run excel_translator --help             # Show this help');
    print('');
    print('Arguments:');
    print('  <file>                  Excel/CSV/ODS file path (.xlsx, .csv, .ods)');
    print('  <output>                Output directory');
    print('');
    print('Options:');
    print('  -c, --class-name=NAME   Generated class name (default: AppLocalizations)');
    print('  -d, --delegates=BOOL    Include Flutter delegates (default: true)');
    print('  --no-delegates          Disable Flutter delegates');
    print('  -h, --help              Show this help');
    print('');
    print('Examples:');
    print('  dart run excel_translator assets/localizations.xlsx lib/generated');
    print('  dart run excel_translator file.csv lib/l10n --class-name=L10n');
    print('  dart run excel_translator file.ods lib/i18n --no-delegates');
    print('');
    print('Configuration (pubspec.yaml):');
    print('  excel_translator:');
    print('    excel_file: assets/localizations.xlsx');
    print('    output_dir: lib/generated');
    print('    class_name: AppLocalizations  # optional');
  }
}
