import 'dart:io';

import 'package:args/args.dart';
import 'package:inno_bundle/builders/app_builder.dart';
import 'package:inno_bundle/models/build_type.dart';
import 'package:inno_bundle/models/config.dart';
import 'package:inno_bundle/builders/installer_builder.dart';
import 'package:inno_bundle/builders/script_builder.dart';
import 'package:inno_bundle/utils/constants.dart';

/// Builds the application using the provided configuration.
///
/// Returns the directory containing the built application files.
Future<Directory> _buildApp(Config config) async {
  final builder = AppBuilder(config);
  return await builder.build();
}

/// Generates the Inno Setup script file for the installer.
///
/// Returns the generated Inno Setup script file.
Future<File> _buildScript(Config config, Directory appDir) async {
  final builder = ScriptBuilder(config, appDir);
  return await builder.build();
}

/// Builds the installer using the provided configuration and Inno Setup script file.
Future<void> _buildInstaller(Config config, File scriptFile) async {
  final builder = InstallerBuilder(config, scriptFile);
  await builder.build();
}

/// Run to build installer
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(BuildType.release.name, negatable: false)
    ..addFlag(BuildType.profile.name, negatable: false)
    ..addFlag(BuildType.debug.name, negatable: false, help: 'Default flag')
    ..addFlag('app', defaultsTo: true, help: 'Build app')
    ..addFlag('installer', defaultsTo: true, help: 'Build installer')
    ..addOption("build-args", help: "Appended to `flutter build`")
    ..addOption("app-version", help: "Override app version")
    ..addOption("sign-tool-name", help: "Override sign tool name")
    ..addOption("sign-tool-command", help: "Override sign tool command")
    ..addOption("sign-tool-params", help: "Override sign tool params")
    ..addFlag(
      'envs',
      defaultsTo: false,
      negatable: false,
      help: "Print env variables and exit",
    )
    ..addFlag('hf', defaultsTo: true, help: 'Print header and footer')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print help and exit');
  final parsedArgs = parser.parse(arguments);
  final envs = parsedArgs['envs'] as bool;
  final hf = parsedArgs['hf'] as bool;
  final help = parsedArgs['help'] as bool;

  if (hf) print(START_MESSAGE);

  if (help) {
    print("${parser.usage}\n");
    exit(0);
  }

  final config = Config.fromFile(
    type: BuildType.fromArgs(parsedArgs),
    app: parsedArgs['app'],
    installer: parsedArgs['installer'],
    buildArgs: parsedArgs['build-args'],
    appVersion: parsedArgs['app-version'],
    signToolName: parsedArgs['sign-tool-name'],
    signToolCommand: parsedArgs['sign-tool-command'],
    signToolParams: parsedArgs['sign-tool-params'],
  );

  if (envs) {
    print(config.toEnvironmentVariables());
    exit(0);
  }

  final appBuildDir = await _buildApp(config);
  final scriptFile = await _buildScript(config, appBuildDir);
  await _buildInstaller(config, scriptFile);

  if (hf) print(BUILD_END_MESSAGE);
}
