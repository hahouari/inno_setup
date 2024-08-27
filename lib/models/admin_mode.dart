/// An enum representing the different privilege modes to be asked by installer.
enum AdminMode {
  admin,
  nonAdmin,
  auto;

  /// Parses configuration option to the desired [AdminMode].
  static AdminMode fromOption(dynamic option) {
    if (option is bool) {
      return option ? admin : nonAdmin;
    }
    return auto;
  }
}
