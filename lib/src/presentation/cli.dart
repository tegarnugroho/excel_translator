// Command line interface for Excel Translator
import 'dart:io';
import '../application/translator_service.dart';
import '../data/sources/config_data_source.dart';

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

  /// Run using configuration from pubspec.yaml
  Future<void> _runFromPubspec() async {
    try {
      print('📖 Loading configuration from pubspec.yaml...');
      
      await _translatorService.generateFromPubspec('./pubspec.yaml');
    } catch (e) {
      print('❌ Failed to load from pubspec.yaml: $e');
      print('');
      print('💡 Make sure you have excel_translator configuration in your pubspec.yaml:');
      print('');
      print('excel_translator:');
      print('  excel_file: assets/localizations.xlsx');
      print('  output_dir: lib/generated');
      print('  class_name: AppLocalizations  # optional');
      print('');
      print('Or use manual arguments:');
      _printUsage();
      exit(1);
    }
  }

  /// Print current configuration from pubspec.yaml
  Future<void> _printConfig() async {
    try {
      final configDataSource = ConfigDataSource();
      final config = configDataSource.loadConfigFromPubspec();

      if (config == null) {
        print('❌ No excel_translator configuration found in pubspec.yaml');
        print('');
        print('💡 Add configuration to your pubspec.yaml:');
        print('');
        print('excel_translator:');
        print('  excel_file: assets/localizations.xlsx');
        print('  output_dir: lib/generated');
        print('  class_name: AppLocalizations  # optional');
        return;
      }

      print('📋 Excel Translator Configuration:');
      print('═══════════════════════════════════════');
      
      final excelFile = config['excel_file'] as String?;
      final outputDir = config['output_dir'] as String?;
      final className = config['class_name'] as String?;

      if (excelFile != null) {
        print('📁 Excel File: $excelFile');
      }
      
      if (outputDir != null) {
        print('📂 Output Directory: $outputDir');
      }
      
      if (className != null) {
        print('🏷️  Class Name: $className');
      } else {
        print('🏷️  Class Name: AppLocalizations (default)');
      }

      // Check if files exist
      print('');
      print('📊 File Status:');
      if (excelFile != null) {
        final file = File(excelFile);
        if (file.existsSync()) {
          print('✅ Excel file exists: $excelFile');
        } else {
          print('❌ Excel file not found: $excelFile');
        }
      }

      if (outputDir != null) {
        final dir = Directory(outputDir);
        if (dir.existsSync()) {
          print('✅ Output directory exists: $outputDir');
        } else {
          print('⚠️  Output directory will be created: $outputDir');
        }
      }

    } catch (e) {
      print('❌ Error reading configuration: $e');
    }
  }

  /// Print usage information
  void _printUsage() {
    print(
        'Excel Translator - Generate Flutter localization files from Excel/CSV/ODS');
    print('');
    print('Usage:');
    print('  dart run excel_translator                           # Auto-detect from pubspec.yaml');
    print('  dart run excel_translator log                       # Show current configuration');
    print(
        '  dart run excel_translator <input_file> <output_directory> [options]');
    print('');
    print('Commands:');
    print('  log                      Show current configuration from pubspec.yaml');
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
    print('Auto-detect Configuration (pubspec.yaml):');
    print('  excel_translator:');
    print('    excel_file: assets/localizations.xlsx');
    print('    output_dir: lib/generated');
    print('    class_name: AppLocalizations  # optional');
    print('');
    print('Examples:');
    print('  dart run excel_translator                           # Use pubspec.yaml config');
    print('  dart run excel_translator log                       # Show configuration');
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
