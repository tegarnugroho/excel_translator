import 'package:excel_translator/cli.dart';

/// Main entry point for CLI usage
void main(List<String> arguments) async {
  final cli = ExcelTranslatorCLI.create();
  await cli.run(arguments);
}
