part of "theme.dart";

const _light = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFF57C00), // Slightly muted orange
  onPrimary: Color(0xFFFFFFFF), // White
  secondary: Color(0xFFFFCC80), // Light, pastel orange
  onSecondary: Color(0xFF5D4037), // Muted brown
  error: Color(0xFFD32F2F), // Dark Red (still distinct)
  onError: Color(0xFFFFFFFF), // White
  surface: Color(0xFFF8F8F8), // Off-white
  onSurface: Color(0xFF424242), // Dark Gray
);

const _dark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFDC5C00), // Slightly brighter than light mode primary
  onPrimary: Color(0xFF263238), // Dark Grayish Blue
  secondary: Color(0xFF263238), // Deeper, more subdued orange
  onSecondary: Color(0xFFD64E0B), // Light Gray
  error: Color(0xFFEF9A9A), // Lighter Red
  onError: Color(0xFF263238), // Dark Grayish Blue
  surface: Color(0xFF212121), // Dark Gray
  onSurface: Color(0xFFEEEEEE), // Light Gray
);