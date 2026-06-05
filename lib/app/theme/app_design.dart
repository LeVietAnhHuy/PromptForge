import 'package:flutter/material.dart';

/// Centralized design tokens for PromptForge.
///
/// Aesthetic direction: **"forge"** — deep warm charcoal surfaces with a warm
/// ember/amber accent, precise and workshop-like. Tokens here are the single
/// source of truth: spacing, radii, motion, elevation, the forge color ramp,
/// and the self-hosted font families. Avoid hardcoding colors/spacing in
/// widgets; reference these (or the [ThemeData] derived from them) instead.
class AppDesign {
  AppDesign._(); // Prevent instantiation

  // --- Spacing (4px base scale) ---
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // --- Radii ---
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusModal = 20.0;

  static const BorderRadius borderSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderModal =
      BorderRadius.all(Radius.circular(radiusModal));

  // --- Durations ---
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 350);

  // --- Motion easings ---
  static const Curve easeStandard = Curves.easeOutCubic;
  static const Curve easeEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Returns [base], or [Duration.zero] when the platform requests reduced
  /// motion (`prefers-reduced-motion`). Use for any non-essential animation.
  static Duration motion(BuildContext context, Duration base) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false
        ? Duration.zero
        : base;
  }

  // --- Elevation/Shadows ---
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationModal = 24.0;

  // --- Dimensions ---
  static const double maxContentWidth = 800.0;
  static const double mobileBreakpoint = 700.0;

  /// Breakpoint at/above which the Edit Prompt screen splits into two columns.
  static const double splitBreakpoint = 1100.0;

  // --- Fonts (self-hosted, see pubspec.yaml + THIRD_PARTY_NOTICES) ---
  /// Display / brand headings.
  static const String fontDisplay = 'SpaceGrotesk';

  /// Body / UI text.
  static const String fontBody = 'AtkinsonHyperlegible';

  /// Code / prompt / monospace content.
  static const String fontMono = 'JetBrainsMono';

  // --- Forge color ramp (dark, primary theme) ---
  // Distinct elevation steps with visible contrast between them.
  static const Color forgeBackground =
      Color(0xFF14110E); // deepest app background
  static const Color forgeSurface = Color(0xFF1C1814); // base surface
  static const Color forgeSurfaceLow = Color(0xFF1A1612);
  static const Color forgeSurface1 = Color(0xFF221D18); // raised container
  static const Color forgeSurface2 = Color(0xFF29231D); // card
  static const Color forgeSurface3 = Color(0xFF312A22); // raised card / hover
  static const Color forgeBorder = Color(0xFF3A312A);
  static const Color forgeBorderStrong = Color(0xFF4E4339);
  static const Color forgeOutline = Color(0xFF5A4E43);

  static const Color forgeOnSurface = Color(0xFFF2E9E0); // warm off-white
  static const Color forgeOnSurfaceVariant = Color(0xFFB6A99B); // muted
  static const Color forgeOnSurfaceFaint = Color(0xFF8A7D6F);

  // Ember accent (warm amber-orange range).
  static const Color emberPrimary = Color(0xFFE8833A);
  static const Color emberBright = Color(0xFFF6A45E);
  static const Color emberOnPrimary = Color(0xFF1F1206);
  static const Color emberContainer = Color(0xFF492D16);
  static const Color emberOnContainer = Color(0xFFFFD7B5);

  // Semantic.
  static const Color success = Color(0xFF53B98A);
  static const Color successContainer = Color(0xFF15392B);
  static const Color warning = Color(0xFFE0A33B);
  static const Color warningContainer = Color(0xFF3E2F12);
  static const Color danger = Color(0xFFE5564B);
  static const Color dangerContainer = Color(0xFF45201B);
  static const Color info = Color(0xFF5AA6D0);
  static const Color infoContainer = Color(0xFF18313D);
}

/// Forge-specific tokens that don't map cleanly onto Material's [ColorScheme]
/// (extra elevation step, semantic accents). Read via
/// `Theme.of(context).extension<ForgeTokens>()!` or the [ForgeContext] helper.
@immutable
class ForgeTokens extends ThemeExtension<ForgeTokens> {
  final Color background;
  final Color surfaceRaised; // one step above cards, e.g. hover / popovers
  final Color borderStrong;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color info;
  final Color infoContainer;

  const ForgeTokens({
    required this.background,
    required this.surfaceRaised,
    required this.borderStrong,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.info,
    required this.infoContainer,
  });

  static const ForgeTokens dark = ForgeTokens(
    background: AppDesign.forgeBackground,
    surfaceRaised: AppDesign.forgeSurface3,
    borderStrong: AppDesign.forgeBorderStrong,
    success: AppDesign.success,
    successContainer: AppDesign.successContainer,
    warning: AppDesign.warning,
    warningContainer: AppDesign.warningContainer,
    danger: AppDesign.danger,
    dangerContainer: AppDesign.dangerContainer,
    info: AppDesign.info,
    infoContainer: AppDesign.infoContainer,
  );

  @override
  ForgeTokens copyWith({
    Color? background,
    Color? surfaceRaised,
    Color? borderStrong,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? info,
    Color? infoContainer,
  }) {
    return ForgeTokens(
      background: background ?? this.background,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      borderStrong: borderStrong ?? this.borderStrong,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
    );
  }

  @override
  ForgeTokens lerp(ThemeExtension<ForgeTokens>? other, double t) {
    if (other is! ForgeTokens) return this;
    return ForgeTokens(
      background: Color.lerp(background, other.background, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}

/// Convenience accessors for forge tokens off a [BuildContext].
extension ForgeContext on BuildContext {
  ForgeTokens get forge =>
      Theme.of(this).extension<ForgeTokens>() ?? ForgeTokens.dark;
}
