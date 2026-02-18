import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run bin/increase_version.dart <patch|minor|major>');
    exit(1);
  }

  final type = args[0].toLowerCase();
  if (!['patch', 'minor', 'major'].contains(type)) {
    print('Invalid version type. Use patch, minor, or major.');
    exit(1);
  }

  // Find project root directory (where pubspec.yaml is located)
  final scriptPath = Platform.script.toFilePath();
  final scriptDir = path.dirname(scriptPath);
  final projectRoot = path.dirname(scriptDir); // Parent of bin directory

  // Read pubspec.yaml
  final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
  final pubspecContent = pubspecFile.readAsStringSync();
  final pubspecYaml = loadYaml(pubspecContent) as Map;

  final currentVersion = pubspecYaml['version'] as String;
  final newVersion = increaseVersion(currentVersion, type);

  print('Increasing version from $currentVersion to $newVersion');

  // Update pubspec.yaml
  final updatedPubspec = pubspecContent.replaceFirst(
    'version: $currentVersion',
    'version: $newVersion',
  );
  pubspecFile.writeAsStringSync(updatedPubspec);

  // Update README.md
  final readmeFile = File(path.join(projectRoot, 'README.md'));
  final readmeContent = readmeFile.readAsStringSync();
  final updatedReadme = readmeContent.replaceFirst(
    RegExp(r'excel_translator: \^\d+\.\d+\.\d+'),
    'excel_translator: ^${newVersion.split('+').first}',
  );
  readmeFile.writeAsStringSync(updatedReadme);

  // Update CHANGELOG.md
  final changelogFile = File(path.join(projectRoot, 'CHANGELOG.md'));
  final today = DateTime.now().toIso8601String().split('T').first;
  final changes = generateChangelog(currentVersion);

  // Build new changelog entry (EXACT format)
  final newEntry =
      '## [$newVersion] - $today\n\n'
      '### Changes\n\n'
      '$changes';

  // Read existing changelog (if any)
  var oldContent = changelogFile.existsSync()
      ? changelogFile.readAsStringSync()
      : '';

  const marker = '# Changelog';

  // Ensure marker exists
  if (!oldContent.contains(marker)) {
    oldContent = '$marker\n\n';
  }

  // Extract content AFTER marker
  final markerIndex = oldContent.indexOf(marker);
  var rest = oldContent.substring(markerIndex + marker.length);

  // Normalize old content:
  // - remove leading/trailing blank lines
  // - ensure exactly ONE blank line between sections
  rest = rest
      .replaceAll(RegExp(r'\r\n'), '\n')
      .replaceFirst(RegExp(r'^\n+'), '')
      .replaceFirst(RegExp(r'\n+$'), '');

  // Rebuild changelog from scratch (THIS IS THE KEY)
  final finalContent = [
    marker,
    '',
    newEntry,
    if (rest.isNotEmpty) '',
    rest,
  ].join('\n');

  changelogFile.writeAsStringSync('$finalContent\n');

  // Update hardcoded version in cli.dart
  final cliFile = File(path.join(projectRoot, 'lib/src/cli.dart'));
  final cliContent = cliFile.readAsStringSync();
  final updatedCli = cliContent.replaceFirst(
    "print('Excel Translator v2.0.0');",
    "print('Excel Translator v$newVersion');",
  );
  cliFile.writeAsStringSync(updatedCli);
  // Create git tag
  try {
    Process.runSync('git', ['tag', 'v$newVersion']);
    print('Created git tag v$newVersion');
  } catch (e) {
    print('Failed to create git tag');
  }
  print('Version updated successfully!');
}

String generateChangelog(String currentVersion) {
  try {
    // Get commits from main to HEAD with file changes
    final result = Process.runSync('git', [
      'log',
      '--oneline',
      '--name-status',
      'main..HEAD',
    ]);
    if (result.exitCode == 0) {
      final output = (result.stdout as String).trim();
      if (output.isNotEmpty) {
        // Parse the output
        final lines = output.split('\n');
        final changelog = <String>[];
        String? currentCommit;
        for (final line in lines) {
          if (line.contains(' ') &&
              !line.startsWith('M\t') &&
              !line.startsWith('A\t') &&
              !line.startsWith('D\t')) {
            // Commit line: hash message
            currentCommit = line.split(' ').skip(1).join(' ');
          } else if ((line.startsWith('M\t') ||
                  line.startsWith('A\t') ||
                  line.startsWith('D\t')) &&
              currentCommit != null) {
            // File change
            final parts = line.split('\t');
            final status = parts[0];
            final file = parts[1];
            final statusText = status == 'M'
                ? 'Modified'
                : status == 'A'
                ? 'Added'
                : 'Deleted';
            changelog.add('- $currentCommit ($statusText: $file)');
            currentCommit = null; // One entry per commit-file
          }
        }
        if (changelog.isNotEmpty) {
          return changelog.join('\n');
        }
      }
    }
  } catch (e) {
    // If git fails, fall back
  }
  return '- Version bump';
}

String increaseVersion(String version, String type) {
  final parts = version.split('.').map(int.parse).toList();
  if (type == 'patch') {
    parts[2]++;
  } else if (type == 'minor') {
    parts[1]++;
    parts[2] = 0;
  } else if (type == 'major') {
    parts[0]++;
    parts[1] = 0;
    parts[2] = 0;
  }
  return parts.join('.');
}
