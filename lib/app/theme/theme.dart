import 'package:flutter/material.dart';
import 'app_design.dart';

/// PromptForge "forge" theme: dark-first, deep warm charcoal surfaces with an
/// ember/amber accent. Built directly from [AppDesign] tokens. The dark
/// [ColorScheme] fills the Material 3 surface-container slots that existing
/// screens already reference, so the whole app adopts the palette without
/// touching each widget.
class AppTheme {
  AppTheme._();

  /// Dark forge [ColorScheme] — the primary theme.
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppDesign.emberPrimary,
    onPrimary: AppDesign.emberOnPrimary,
    primaryContainer: AppDesign.emberContainer,
    onPrimaryContainer: AppDesign.emberOnContainer,
    secondary: Color(0xFFCBA17A),
    onSecondary: Color(0xFF20160C),
    secondaryContainer: Color(0xFF362A1E),
    onSecondaryContainer: Color(0xFFEBD0B5),
    tertiary: Color(0xFF8FB7C9),
    onTertiary: Color(0xFF0E1F27),
    tertiaryContainer: Color(0xFF21323B),
    onTertiaryContainer: Color(0xFFC4DEEA),
    error: AppDesign.danger,
    onError: Color(0xFF2A0C09),
    errorContainer: AppDesign.dangerContainer,
    onErrorContainer: Color(0xFFFFD7D1),
    surface: AppDesign.forgeSurface,
    onSurface: AppDesign.forgeOnSurface,
    onSurfaceVariant: AppDesign.forgeOnSurfaceVariant,
    surfaceDim: AppDesign.forgeBackground,
    surfaceBright: AppDesign.forgeSurface3,
    surfaceContainerLowest: AppDesign.forgeBackground,
    surfaceContainerLow: AppDesign.forgeSurfaceLow,
    surfaceContainer: AppDesign.forgeSurface1,
    surfaceContainerHigh: AppDesign.forgeSurface2,
    surfaceContainerHighest: AppDesign.forgeSurface3,
    outline: AppDesign.forgeOutline,
    outlineVariant: AppDesign.forgeBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppDesign.forgeOnSurface,
    onInverseSurface: AppDesign.forgeSurface,
    inversePrimary: AppDesign.emberContainer,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get darkTheme =>
      _buildTheme(darkColorScheme, ForgeTokens.dark);

  /// Light variant — structural placeholder so a light theme is possible later
  /// without rework. The app pins dark; this keeps the API symmetrical.
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppDesign.emberPrimary,
      brightness: Brightness.light,
    );
    return _buildTheme(scheme, ForgeTokens.dark);
  }

  static TextTheme _forgeTextTheme(Color onSurface, Color variant) {
    const display = AppDesign.fontDisplay;
    const body = AppDesign.fontBody;
    TextStyle d(double size, FontWeight w, {double? height, double? ls}) =>
        TextStyle(
          fontFamily: display,
          fontSize: size,
          fontWeight: w,
          height: height,
          letterSpacing: ls,
          color: onSurface,
        );
    TextStyle b(double size, FontWeight w, {Color? color, double? height}) =>
        TextStyle(
          fontFamily: body,
          fontSize: size,
          fontWeight: w,
          height: height,
          color: color ?? onSurface,
        );
    return TextTheme(
      displayLarge: d(48, FontWeight.w700, ls: -1.0),
      displayMedium: d(36, FontWeight.w700, ls: -0.5),
      displaySmall: d(30, FontWeight.w600),
      headlineLarge: d(28, FontWeight.w600, ls: -0.3),
      headlineMedium: d(24, FontWeight.w600),
      headlineSmall: d(20, FontWeight.w600),
      titleLarge: d(18, FontWeight.w600),
      titleMedium: b(16, FontWeight.w600),
      titleSmall: b(14, FontWeight.w600),
      bodyLarge: b(16, FontWeight.w400, height: 1.45),
      bodyMedium: b(14, FontWeight.w400, height: 1.45),
      bodySmall: b(12.5, FontWeight.w400, color: variant, height: 1.4),
      labelLarge: b(14, FontWeight.w600),
      labelMedium: b(12, FontWeight.w600, color: variant),
      labelSmall: b(11, FontWeight.w600, color: variant),
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, ForgeTokens forge) {
    final textTheme =
        _forgeTextTheme(colorScheme.onSurface, colorScheme.onSurfaceVariant);
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: isDark ? forge.background : colorScheme.surface,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      fontFamily: AppDesign.fontBody,
      textTheme: textTheme,
      extensions: [forge],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: AppDesign.elevationNone,
        scrolledUnderElevation: AppDesign.elevationSm,
        backgroundColor: isDark ? forge.background : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: AppDesign.elevationNone,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderLg,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surfaceContainerHigh,
        margin: const EdgeInsets.only(bottom: AppDesign.spacingMd),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingMd,
          vertical: AppDesign.spacingMd,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppDesign.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDesign.borderMd,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDesign.borderMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDesign.borderMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDesign.borderMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppDesign.borderMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.spacingLg,
            vertical: AppDesign.spacingMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppDesign.elevationNone,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: AppDesign.borderMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.spacingLg,
            vertical: AppDesign.spacingMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: AppDesign.borderMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.spacingLg,
            vertical: AppDesign.spacingMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? forge.background : colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape:
            const RoundedRectangleBorder(borderRadius: AppDesign.borderMd),
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: colorScheme.primary),
        unselectedLabelTextStyle: textTheme.labelMedium,
        labelType: NavigationRailLabelType.all,
        useIndicator: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape:
            const RoundedRectangleBorder(borderRadius: AppDesign.borderMd),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: AppDesign.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderMd,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: AppDesign.elevationModal,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderModal,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        titleTextStyle: textTheme.headlineSmall,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppDesign.borderSm),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.spacingSm, vertical: 2),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: AppDesign.borderSm,
        ),
        textStyle: textTheme.labelMedium
            ?.copyWith(color: colorScheme.onInverseSurface),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium,
        actionTextColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesign.borderMd,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: colorScheme.primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}
