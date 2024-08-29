/// Class holding the sign tool properties based on Inno Setup approach and Setup section directives
class SignTool {
  final String name;
  final String command;
  final String params;
  final int retryCount;
  final int retryDelay;

  const SignTool({
    required this.name,
    required this.command,
    required this.params,
    required this.retryCount,
    required this.retryDelay,
  });

  /// Validate configuration option for [SignTool]
  static String? validationError(
    dynamic option, {
    String? signToolName,
    String? signToolCommand,
    String? signToolParams,
  }) {
    if (option == null || option is String) return null;
    if (option is Map<String, dynamic>) {
      if ((signToolName ?? option['name']) == null &&
          (signToolCommand ?? option['command']) == null) {
        return "inno_bundle.sign_tool on pubspec.yaml is expected to be "
            "of type String or to at least have name or command fields.";
      }
      return null;
    }

    return "inno_bundle.sign_tool attribute is invalid in pubspec.yaml.";
  }

  /// Parses configuration option to the desired [SignTool].
  static SignTool? fromOption(
    dynamic option, {
    String? signToolName,
    String? signToolCommand,
    String? signToolParams,
  }) {
    // print(option);
    // print(signToolParams);
    // exit(0);
    if (option == null) {
      if (signToolName != null ||
          signToolCommand != null ||
          signToolParams != null) {
        return SignTool(
          name: signToolName ?? "InnoBundleTool",
          command: signToolCommand ?? "",
          params: signToolParams ?? "",
          retryCount: 2,
          retryDelay: 500,
        );
      } else {
        return null;
      }
    }
    if (option is String) {
      return SignTool(
        name: signToolName ?? "InnoBundleTool",
        command: signToolCommand ?? option,
        params: signToolParams ?? "",
        retryCount: 2,
        retryDelay: 500,
      );
    }
    final map = option as Map<String, dynamic>;
    return SignTool(
      name: signToolName ?? map['name'] ?? "InnoBundleTool",
      command: signToolCommand ?? map["command"] ?? "",
      params: signToolParams ?? map["params"] ?? "",
      retryCount: map["retry_count"] ?? 2,
      retryDelay: map["retry_delay"] ?? 500,
    );
  }

  String get inno {
    return """
SignTool=$name $params
SignToolRetryCount=$retryCount
SignToolRetryDelay=$retryDelay
""";
  }
}
