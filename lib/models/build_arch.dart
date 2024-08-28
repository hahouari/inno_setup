/// The CPU Architecture that the app was designed to run on,
/// and therefore the architectures that are accepted by [inno_bundle] generated installer.
enum BuildArch {
  x64("x64os", "x86_64"),
  x64Compatible("x64compatible", "x86_64");

  final String value;
  final String cpu;
  const BuildArch(this.value, this.cpu);

  static final acceptedStringValues = ["x64", "x64_compatible"];

  /// Validate configuration option for [BuildArch]
  static String? validationError(dynamic option) {
    if (option == null) return null;
    if (option is String && BuildArch.acceptedStringValues.contains(option)) {
      return null;
    }
    return "inno_bundle.sign_tool attribute is invalid in pubspec.yaml.";
  }

  /// Parses configuration option to the desired [BuildArch].
  static BuildArch fromOption(String? option) {
    return option == 'x64' ? x64 : x64Compatible;
  }
}
