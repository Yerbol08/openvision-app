import 'package:flutter/material.dart';

import 'ov_tokens.dart';

/// Тень шитов и плавающей кнопки (`shadow-sheet`). Карточки — без теней.
const ovSheetShadow = [
  BoxShadow(color: Color(0x29000000), blurRadius: 24, offset: Offset(0, 8)),
];

/// Табличные цифры для чисел и времени.
const ovTabular = [FontFeature.tabularFigures()];

ThemeData buildOvTheme(Brightness brightness) {
  final c = brightness == Brightness.light ? OvColors.light : OvColors.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.brand,
    onPrimary: c.onBrand,
    primaryContainer: c.brandSoft,
    onPrimaryContainer: c.ink,
    secondary: c.brand,
    onSecondary: c.onBrand,
    error: c.danger,
    onError: c.onDanger,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.inkMuted,
    surfaceContainerHighest: c.surfaceSunken,
    outline: c.lineStrong,
    outlineVariant: c.line,
    scrim: c.scrim,
  );

  TextStyle ink(TextStyle s) => s.copyWith(color: c.ink);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: OvText.sansFamily,
    extensions: [c],
    dividerColor: c.line,
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    textTheme: TextTheme(
      displaySmall: ink(OvText.display),
      titleLarge: ink(OvText.title),
      titleMedium: ink(OvText.headline),
      bodyLarge: ink(OvText.body),
      bodyMedium: ink(OvText.body),
      bodySmall: OvText.caption.copyWith(color: c.inkMuted),
      labelLarge: ink(OvText.bodyStrong),
      labelMedium: ink(OvText.label),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.brand,
      selectionColor: c.brand.withValues(alpha: .3),
      selectionHandleColor: c.brand,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.brand),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: OvText.body.copyWith(color: c.bg),
      actionTextColor: c.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OvRadius.radiusSm)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      modalBarrierColor: c.scrim,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OvRadius.radiusLg)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      barrierColor: c.scrim,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OvRadius.radiusLg)),
      titleTextStyle: ink(OvText.title),
      contentTextStyle: OvText.body.copyWith(color: c.inkMuted),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

extension OvThemeContext on BuildContext {
  OvColors get ov => Theme.of(this).extension<OvColors>()!;
}
