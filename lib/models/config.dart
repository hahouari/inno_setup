import 'dart:io';
import 'package:inno_bundle/models/build_type.dart';
import 'package:inno_bundle/models/language.dart';
import 'package:inno_bundle/utils/cli_logger.dart';
import 'package:inno_bundle/utils/constants.dart';
import 'package:inno_bundle/utils/functions.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

/// A class representing the configuration for building a Windows installer using Inno Setup.
class Config {
  /// The unique identifier (UUID) for the app being packaged.
  final String id;

  /// The global pubspec name attribute, same name of the exe generated from flutter build.
  final String pubspecName;

  /// The name of the app after packaging.
  final String name;

  /// A description of the app being packaged.
  final String description;

  /// The app's version.
  final String version;

  /// The name of the publisher or maintainer.
  final String publisher;

  /// The app's homepage URL.
  final String url;

  /// The URL for support resources.
  final String supportUrl;

  /// The URL for checking for updates.
  final String updatesUrl;

  /// The path to the installer icon file.
  final String installerIcon;

  // The path to the license file.
  final String licenseFile;

  /// The supported languages for the installer.
  final List<Language> languages;

  /// Whether the installer requires administrator privileges.
  final bool admin;

  /// The build type (debug or release).
  final BuildType type;

  /// Whether to include the app in the installer.
  final bool app;

  /// Whether to create an installer file.
  final bool installer;

  /// Arguments to be passed to flutter build.
  final String? buildArgs;

  /// Creates a [Config] instance with default values.
  const Config({
    required this.buildArgs,
    required this.id,
    required this.pubspecName,
    required this.name,
    required this.description,
    required this.version,
    required this.publisher,
    required this.url,
    required this.supportUrl,
    required this.updatesUrl,
    required this.installerIcon,
    required this.languages,
    required this.admin,
    required this.licenseFile,
    this.type = BuildType.debug,
    this.app = true,
    this.installer = true, 
  });

  /// The name of the executable file that is created with flutter build.
  String get exePubspecName => "$pubspecName.exe";

  /// The name of the executable file that will be created.
  String get exeName => "$name.exe";

  /// Creates a [Config] instance from a JSON map, typically read from `pubspec.yaml`.
  ///
  /// Validates the configuration and exits with an error if invalid values are found.
  factory Config.fromJson(
    Map<String, dynamic> json, {
    BuildType type = BuildType.debug,
    bool app = true,
    bool installer = true,
    required String? buildArgs,
    required String? appVersion,
  }) {
    if (json['inno_bundle'] is! Map<String, dynamic>) {
      CliLogger.exitError("inno_bundle section is missing from pubspec.yaml.");
    }
    final Map<String, dynamic> inno = json['inno_bundle'];

    if (inno['id'] is! String) {
      CliLogger.exitError(
          "inno_bundle.id attribute is missing from pubspec.yaml. "
          "Run `dart run inno_bundle:guid` to generate a new one, "
          "then put it in your pubspec.yaml.");
    } else if (!Uuid.isValidUUID(fromString: inno['id'])) {
      CliLogger.exitError("inno_bundle.id from pubspec.yaml is not valid. "
          "Run `dart run inno_bundle:guid` to generate a new one, "
          "then put it in your pubspec.yaml.");
    }
    final String id = inno['id'];

    if (json['name'] is! String) {
      CliLogger.exitError("name attribute is missing from pubspec.yaml.");
    }
    final String pubspecName = json['name'];

    if (inno['name'] != null && !validFilenameRegex.hasMatch(inno['name'])) {
      CliLogger.exitError("inno_bundle.name from pubspec.yaml is not valid. "
          "`${inno['name']}` is not a valid file name.");
    }
    final String name = inno['name'] ?? pubspecName;

    if ((appVersion ?? inno['version'] ?? json['version']) is! String) {
      CliLogger.exitError("version attribute is missing from pubspec.yaml.");
    }
    final String version = appVersion ?? inno['version'] ?? json['version'];

    if ((inno['description'] ?? json['description']) is! String) {
      CliLogger.exitError(
          "description attribute is missing from pubspec.yaml.");
    }
    final String description = inno['description'] ?? json['description'];

    if ((inno['publisher'] ?? json['maintainer']) is! String) {
      CliLogger.exitError("maintainer or inno_bundle.publisher attributes are "
          "missing from pubspec.yaml.");
    }
    final String publisher = inno['publisher'] ?? json['maintainer'];

    final url = (inno['url'] ?? json['homepage'] ?? "") as String;
    final supportUrl = (inno['support_url'] as String?) ?? url;
    final updatesUrl = (inno['updates_url'] as String?) ?? url;

    if (inno['installer_icon'] != null && inno['installer_icon'] is! String) {
      CliLogger.exitError("inno_bundle.installer_icon attribute is invalid "
          "in pubspec.yaml.");
    }
    final installerIcon = inno['installer_icon'] != null
        ? p.join(
            Directory.current.path,
            p.fromUri(inno['installer_icon']),
          )
        : defaultInstallerIconPlaceholder;
    if (installerIcon != defaultInstallerIconPlaceholder &&
        !File(installerIcon).existsSync()) {
      CliLogger.exitError(
          "inno_bundle.installer_icon attribute value is invalid, "
          "`$installerIcon` file does not exist.");
    }

    if (inno['languages'] != null && inno['languages'] is! List<String>) {
      CliLogger.exitError("inno_bundle.languages attribute is invalid "
          "in pubspec.yaml, only a list of strings is allowed.");
    }
    final languages = (inno['languages'] as List<String>?)?.map((l) {
          final language = Language.getByNameOrNull(l);
          if (language == null) {
            CliLogger.exitError("problem in inno_bundle.languages attribute "
                "in pubspec.yaml, language `$l` is not supported.");
          }
          return language!;
        }).toList(growable: false) ??
        Language.values;

    if (inno['admin'] != null && inno['admin'] is! bool) {
      CliLogger.exitError(
          "inno_bundle.admin attribute is invalid boolean value "
          "in pubspec.yaml");
    }
    final bool admin = inno['admin'] ?? true;

    if (inno['license_file'] != null && inno['license_file'] is! String) {
      CliLogger.exitError("inno_bundle.installer_icon attribute is invalid "
          "in pubspec.yaml.");
    }

    final licenseFile = File(inno['license_file'] != null
                ? p.join(
                    Directory.current.path, p.fromUri(inno['license_file']))
                : p.join(Directory.current.path, 'LICENSE'))
            .existsSync()
        ? File(inno['license_file'] != null
                ? p.join(
                    Directory.current.path, p.fromUri(inno['license_file']))
                : p.join(Directory.current.path, 'LICENSE'))
            .path
        : "";

    return Config(
      buildArgs: buildArgs,
      id: id,
      pubspecName: pubspecName,
      name: name,
      description: description,
      version: version,
      publisher: publisher,
      url: url,
      supportUrl: supportUrl,
      updatesUrl: updatesUrl,
      installerIcon: installerIcon,
      languages: languages,
      admin: admin,
      type: type,
      app: app,
      installer: installer,
      licenseFile: licenseFile,
    );
  }

  /// Creates a [Config] instance directly from the `pubspec.yaml` file.
  ///
  /// Provides a convenient way to load configuration without manual JSON parsing.
  factory Config.fromFile({
    BuildType type = BuildType.debug,
    bool app = true,
    bool installer = true,
    required String? buildArgs,
    required String? appVersion,
  }) {
    const filePath = 'pubspec.yaml';
    final yamlMap = loadYaml(File(filePath).readAsStringSync()) as Map;
    // yamlMap has the type YamlMap, which has several unwanted side effects
    final yamlConfig = yamlToMap(yamlMap as YamlMap);
    return Config.fromJson(
      yamlConfig,
      type: type,
      app: app,
      installer: installer,
      buildArgs: buildArgs,
      appVersion: appVersion,
    );
  }

  /// Returns a string containing the config attributes as environment variables.
  String toEnvironmentVariables() {
    final variables = <String, String>{
      'APP_ID': id,
      'PUBSPEC_NAME': pubspecName,
      'APP_NAME': name,
      'APP_NAME_CAMEL_CASE': camelCase(name),
      'APP_DESCRIPTION': description,
      'APP_VERSION': version,
      'APP_PUBLISHER': publisher,
      'APP_URL': url,
      'APP_SUPPORT_URL': supportUrl,
      'APP_UPDATES_URL': updatesUrl,
      'APP_INSTALLER_ICON': installerIcon,
      'APP_LANGUAGES': languages.map((l) => l.name).join(','),
      'APP_ADMIN': admin.toString(),
      'APP_TYPE': type.name,
      'APP_BUILD_APP': app.toString(),
      'APP_BUILD_INSTALLER': installer.toString(),
    };

    return variables.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('\n');
  }
}
