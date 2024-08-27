/// The CPU Architecture that the app was designed to run on,
/// and therefore the architectures that are accepted by [inno_bundle] generated installer.
enum BuildArch {
  x64("x64os", "x86_64"),
  x64Compatible("x64compatible", "x86_64");

  final String value;
  final String cpu;
  const BuildArch(this.value, this.cpu);

  static final acceptedStringValues = ["x64", "x64_compatible"];

  /// Parses configuration option to the desired [BuildArch].
  static BuildArch fromOption(String? option) {
    return option == 'x64' ? x64 : x64Compatible;
  }
}
