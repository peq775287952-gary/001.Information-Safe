import 'dart:io';

void main() {
  final file = File('pubspec.yaml');
  final content = file.readAsStringSync();
  final regex = RegExp(r'^version: (\d+)\.(\d+)\.(\d+)\+(\d+)$', multiLine: true);
  final match = regex.firstMatch(content);
  if (match == null) {
    stderr.writeln('ERROR: Could not find version line in pubspec.yaml');
    exit(1);
  }
  final major = match.group(1)!;
  final minor = match.group(2)!;
  final patch = int.parse(match.group(3)!);
  final build = int.parse(match.group(4)!);
  final newPatch = patch + 1;
  final newBuild = build + 1;
  final oldLine = match.group(0)!;
  final newVer = '$major.$minor.$newPatch';
  final newLine = 'version: $newVer+$newBuild';
  final newContent = content.replaceFirst(oldLine, newLine);
  file.writeAsStringSync(newContent);
  print('Version: $major.$minor.$patch+$build → $newVer+$newBuild');
}
