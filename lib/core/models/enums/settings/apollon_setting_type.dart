enum ApollonSettingType {
  string,
  int,
  double,
  boolean;

  /// Hilfsmethode, um den String aus der Spring Boot DB (meist UPPERCASE)
  /// sauber in das Dart-Enum zu konvertieren.
  static ApollonSettingType fromString(String type) {
    return ApollonSettingType.values.firstWhere(
          (e) => e.name.toLowerCase() == type.toLowerCase(),
      orElse: () => ApollonSettingType.string, // Fallback
    );
  }
}