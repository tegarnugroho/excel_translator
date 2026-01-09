import 'dart:io';
import 'package:yaml/yaml.dart';

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

  // Read pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
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
  final readmeFile = File('README.md');
  final readmeContent = readmeFile.readAsStringSync();
  final updatedReadme = readmeContent.replaceFirst(
    RegExp(r'excel_translator: \^\d+\.\d+\.\d+'),
    'excel_translator: ^${newVersion.split('+').first}',
  );
  readmeFile.writeAsStringSync(updatedReadme);

  // Update CHANGELOG.md
  final changelogFile = File('CHANGELOG.md');
  final changelogContent = changelogFile.readAsStringSync();
  final today = DateTime.now().toIso8601String().split('T').first;
  final changes = generateChangelog(currentVersion);
  final newEntry = '## [$newVersion] - $today\n\n### Changes\n\n$changes\n';
  final updatedChangelog = newEntry + changelogContent;
  changelogFile.writeAsStringSync(updatedChangelog);

  // Update hardcoded version in cli.dart
  final cliFile = File('lib/src/cli.dart');
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
    // Get the latest tag
    final tagResult = Process.runSync('git', ['describe', '--tags', '--abbrev=0']);
    final latestTag = tagResult.exitCode == 0 ? (tagResult.stdout as String).trim() : 'HEAD~10'; // fallback

    final result = Process.runSync('git', ['log', '--oneline', '$latestTag..HEAD']);
    if (result.exitCode == 0) {
      final commits = (result.stdout as String).trim().split('\n');
      if (commits.isNotEmpty && commits.first.isNotEmpty) {
        return commits.map((commit) => '- ${commit.split(' ').skip(1).join(' ')}').join('\n');
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