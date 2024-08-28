class SignTool {
  final String name;
  final String params;
  final String command;
  final int retryCount;
  final int retryDelay;

  const SignTool({
    required this.name,
    required this.params,
    required this.command,
    required this.retryCount,
    required this.retryDelay,
  });

  /// Validate configuration option for [SignTool]
  static String? validationError(dynamic option) {
    if (option == null || option is String) return null;
    if (option is Map<String, dynamic>) {
      if (option['name'] == null && option['command'] == null) {
        return "inno_bundle.sign_tool on pubspec.yaml is expected to be "
            "of type String or to at least have name or command fields.";
      }
      return null;
    }

    return "inno_bundle.sign_tool attribute is invalid in pubspec.yaml.";
  }

  /// Parses configuration option to the desired [SignTool].
  static SignTool? fromOption(dynamic option) {
    if (option == null) return null;
    if (option is String) {
      return SignTool(
        name: "InnoBundleTool",
        params: "",
        command: option,
        retryCount: 2,
        retryDelay: 500,
      );
    }
    final map = option as Map<String, dynamic>;
    return SignTool(
      name: map['name'] ?? "InnoBundleTool",
      params: map["params"] ?? "",
      command: map["command"] ?? "",
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
