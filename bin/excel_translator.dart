import 'dart:io';
import 'package:excel_translator/cli.dart';

/// Main entry point for CLI usage
void main(List<String> arguments) async {
  final cli = ExcelTranslatorCLI.create();
  
  try {
    await cli.run(arguments);
    exit(0);
  } catch (e) {
    exit(1);
  }
}
