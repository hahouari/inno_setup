import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:inno_bundle/utils/installer_icon.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

/// Convert yaml to map
Map<String, dynamic> yamlToMap(YamlMap yamlMap) {
  final map = <String, dynamic>{};
  for (final entry in yamlMap.entries) {
    if (entry.value is YamlList) {
      final list = <String>[];
      for (final value in entry.value as YamlList) {
        if (value is String) {
          list.add(value);
        }
      }
      map[entry.key as String] = list;
    } else if (entry.value is YamlMap) {
      map[entry.key as String] = yamlToMap(entry.value as YamlMap);
    } else {
      map[entry.key as String] = entry.value;
    }
  }
  return map;
}

/// Converts a string to camelCase.
///
/// Example: `camelCase("hello-world_out there")` returns "helloWorldOutThere".
String camelCase(String value) {
  return value
      .split(RegExp(r'[-_]|\s'))
      .map((word) => capitalize(word))
      .join('');
}

/// Capitalizes the first letter of a string.
///
/// Example: `capitalize("hello")` returns "Hello".
String capitalize(String value) {
  if (value.isEmpty) return "";
  return value[0].toUpperCase() + value.substring(1);
}

/// Persists the default installer icon to a file in the given directory.
///
/// Decodes a Base64-encoded icon string and writes it to a file in the
/// system temp directory.
///
/// Returns the absolute path of the saved icon file.
String persistDefaultInstallerIcon(String dirPath) {
  Directory(dirPath).createSync();
  final iconPath = p.join(dirPath, defaultInstallerIconFileName);
  File file = File(iconPath);
  Uint8List bytes = base64.decode(defaultInstallerIcon);
  file.writeAsBytesSync(bytes);
  return file.absolute.path;
}

/// Retrieves the user's home directory path.
///
/// Uses environment variables to determine the home directory based on the operating system.
String getHomeDir() {
  String home = "";
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS || Platform.isLinux) {
    home = envVars['HOME'] ?? home;
  } else if (Platform.isWindows) {
    home = envVars['UserProfile'] ?? home;
  }
  return home;
}

/// Retrieves the application name from the main.cpp file.
///
/// Takes the path of the current directory, concatenates it with the
/// subdirectories 'windows/runner', and reads the contents of 'main.cpp'
/// file. It then searches for a line that matches the regex pattern
/// 'Create(?:AndShow)?\(L"(.*?)"' and returns the first capturing group.
String? getWindowsAppName() {
  final String currentDir = Directory.current.path;
  final String mainCppPath =
      p.join(currentDir, 'windows', 'runner', 'main.cpp');
  final File mainCppFile = File(mainCppPath);

  if (!mainCppFile.existsSync()) {
    return null;
  }

  final List<String> lines = mainCppFile.readAsLinesSync();
  for (String line in lines) {
    final RegExp regex = RegExp(r'Create(?:AndShow)?\(L"(.*?)"');
    final Match? match = regex.firstMatch(line);
    if (match != null) {
      return match.group(1)?.trim();
    }
  }

  return null;
}
