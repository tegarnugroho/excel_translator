// Command line interface for Excel Translator
import 'dart:io';
import '../application/translator_service.dart';

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
    if (arguments.isEmpty || arguments.length < 2) {
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
      } else if (arg == '--no-flutter-delegates') {
        includeFlutterDelegates = false;
      } else if (arg == '--help' || arg == '-h') {
        _printUsage();
        exit(0);
      } else {
        print('❌ Unknown argument: $arg');
        _printUsage();
        exit(1);
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
      print('❌ Generation failed: $e');
      exit(1);
    }
  }

  /// Print usage information
  void _printUsage() {
    print(
        'Excel Translator - Generate Flutter localization files from Excel/CSV/ODS');
    print('');
    print('Usage:');
    print(
        '  dart run excel_translator <input_file> <output_directory> [options]');
    print('');
    print('Arguments:');
    print(
        '  input_file       Path to the Excel (.xlsx), CSV (.csv), or ODS (.ods) file');
    print('  output_directory Directory where generated files will be saved');
    print('');
    print('Options:');
    print(
        '  --class-name=<name>        Name of the main localization class (default: AppLocalizations)');
    print('  --no-flutter-delegates     Skip generating Flutter delegates');
    print('  --help, -h                 Show this help message');
    print('');
    print('Examples:');
    print(
        '  dart run excel_translator assets/localizations.xlsx lib/generated');
    print(
        '  dart run excel_translator data.csv output --class-name=MyLocalizations');
    print(
        '  dart run excel_translator file.ods lib/l10n --no-flutter-delegates');
    print('');
    print('Supported file formats:');
    print('  - Excel (.xlsx)');
    print('  - CSV (.csv)');
    print('  - OpenDocument Spreadsheet (.ods)');
  }
}
