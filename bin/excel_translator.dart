import 'dart:io';
import '../lib/src/generator.dart' as excel_gen;
import '../lib/src/config/excel_translator_config.dart';

/// Main entry point for CLI usage
void main(List<String> arguments) async {
  // Check for help flags
  if (arguments.contains('-h') || arguments.contains('--help')) {
    _printUsage();
    exit(0);
  }
  
  // Load configuration from pubspec.yaml
  final pubspecConfig = ExcelTranslatorConfig.fromPubspec();
  
  // Parse CLI arguments
  final cliConfig = _parseCliArguments(arguments);
  
  // Check if we have configuration from either source
  final hasCliConfig = cliConfig['excelFilePath'] != null;
  final hasPubspecConfig = pubspecConfig != null && pubspecConfig.excelFilePath != null;
  
  if (!hasCliConfig && !hasPubspecConfig) {
    print('❌ No configuration found!');
    print('');
    print('Either provide CLI arguments or add configuration to pubspec.yaml');
    print('');
    _printUsage();
    exit(1);
  }
  
  // Merge configurations with CLI taking precedence
  final finalConfig = (pubspecConfig ?? ExcelTranslatorConfig()).mergeWith(
    excelFilePath: cliConfig['excelFilePath'],
    outputDir: cliConfig['outputDir'],
    className: cliConfig['className'],
  );

  final config = finalConfig.getFinalConfig();

  // Validate required parameters
  final excelFilePath = config['excelFilePath'] as String;
  final outputDir = config['outputDir'] as String;
  final className = config['className'] as String;
  final includeFlutterDelegates = config['includeFlutterDelegates'] as bool;

  // Check if Excel file exists
  if (!File(excelFilePath).existsSync()) {
    print('❌ Excel file not found: $excelFilePath');
    print('');
    _printUsage();
    exit(1);
  }

  print('🚀 Generating localizations...');
  print('📂 Excel file: $excelFilePath');
  print('📁 Output directory: $outputDir');
  print('🎯 Class name: $className');
  if (pubspecConfig != null) {
    print('⚙️  Using configuration from pubspec.yaml');
  }
  print('');

  try {
    await excel_gen.ExcelLocalizationsGenerator.generateFromExcel(
      excelFilePath: excelFilePath,
      outputDir: outputDir,
      className: className,
      includeFlutterDelegates: includeFlutterDelegates,
    );
    print('✅ Localizations generated successfully!');
  } catch (e) {
    print('❌ Generation failed: $e');
    exit(1);
  }
}

/// Parse CLI arguments
Map<String, String?> _parseCliArguments(List<String> arguments) {
  // Filter out help flags for argument parsing
  final filteredArgs = arguments.where((arg) => arg != '-h' && arg != '--help').toList();
  
  if (filteredArgs.length > 3) {
    print('❌ Too many arguments provided');
    _printUsage();
    exit(1);
  }

  return {
    'excelFilePath': filteredArgs.isNotEmpty ? filteredArgs[0] : null,
    'outputDir': filteredArgs.length > 1 ? filteredArgs[1] : null,
    'className': filteredArgs.length > 2 ? filteredArgs[2] : null,
  };
}

/// Print usage information
void _printUsage() {
  print('🚀 Excel Translator');
  print('');
  print('USAGE:');
  print('  excel_translator [OPTIONS] [ARGUMENTS]');
  print('');
  print('OPTIONS:');
  print('  -h, --help    Show this help message');
  print('');
  print('ARGUMENTS:');
  print('  excel_translator                                           # Use pubspec.yaml config');
  print('  excel_translator <excel_file> [output_dir] [class_name]   # Use CLI arguments');
  print('');
  print('EXAMPLES:');
  print('  excel_translator                                           # Read config from pubspec.yaml');
  print('  excel_translator assets/localizations.xlsx                # Use defaults for output_dir and class_name');
  print('  excel_translator assets/localizations.xlsx lib/generated  # Use default class_name');
  print('  excel_translator assets/localizations.xlsx lib/generated AppLocalizations');
  print('');
  print('📄 CONFIGURATION via pubspec.yaml:');
  print('');
  print('excel_translator:');
  print('  excel_file: assets/localizations.xlsx');
  print('  output_directory: lib/generated');
  print('  class_name: AppLocalizations');
  print('  include_flutter_delegates: true');
  print('');
  print('💡 TIPS:');
  print('  • CLI arguments take precedence over pubspec.yaml configuration');
  print('  • If no pubspec.yaml config exists, CLI arguments are required');
  print('  • Use -h or --help to show this message');
}
