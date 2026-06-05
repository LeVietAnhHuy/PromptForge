import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_design.dart';

/// Visual identity for an LLM provider: a display name, a brand accent color,
/// and an optional bundled SVG logo (under `assets/provider_icons/`).
///
/// Adding a new provider is a one-line entry in [_registry]. If you also drop a
/// permissively licensed `assets/provider_icons/<id>.svg`, set [asset] to its
/// file name; otherwise the [ProviderLogo] widget renders a monogram badge.
@immutable
class ProviderIdentity {
  final String id;
  final String displayName;
  final Color accent;

  /// SVG file name under `assets/provider_icons/`, or null for a monogram.
  final String? asset;

  /// Whether the SVG is monochrome and should be tinted to [accent].
  /// Multi-color marks (e.g. the Microsoft squares) set this false.
  final bool tintable;

  const ProviderIdentity({
    required this.id,
    required this.displayName,
    required this.accent,
    this.asset,
    this.tintable = true,
  });

  String get _assetPath => 'assets/provider_icons/$asset';
}

// One row per provider. `accent` uses the provider's brand color, chosen to sit
// legibly on the dark forge surfaces. `asset` is set only where a bundled SVG
// exists (see THIRD_PARTY_NOTICES); the rest fall back to a monogram badge.
const Map<String, ProviderIdentity> _registry = {
  'openai': ProviderIdentity(
      id: 'openai', displayName: 'OpenAI', accent: Color(0xFF10A37F)),
  'anthropic': ProviderIdentity(
      id: 'anthropic',
      displayName: 'Anthropic',
      accent: Color(0xFFD97757),
      asset: 'anthropic.svg'),
  'google': ProviderIdentity(
      id: 'google',
      displayName: 'Google',
      accent: Color(0xFF4285F4),
      asset: 'google.svg'),
  'microsoft': ProviderIdentity(
      id: 'microsoft',
      displayName: 'Microsoft',
      accent: Color(0xFF00A4EF),
      asset: 'microsoft.svg',
      tintable: false),
  'meta': ProviderIdentity(
      id: 'meta',
      displayName: 'Meta',
      accent: Color(0xFF0866FF),
      asset: 'meta.svg'),
  'meta-llama': ProviderIdentity(
      id: 'meta-llama',
      displayName: 'Meta Llama',
      accent: Color(0xFF0866FF),
      asset: 'meta.svg'),
  'mistral': ProviderIdentity(
      id: 'mistral',
      displayName: 'Mistral',
      accent: Color(0xFFFA520F),
      asset: 'mistral.svg'),
  'mistral-ai': ProviderIdentity(
      id: 'mistral-ai',
      displayName: 'Mistral AI',
      accent: Color(0xFFFA520F),
      asset: 'mistral.svg'),
  'xai': ProviderIdentity(
      id: 'xai',
      displayName: 'xAI',
      accent: Color(0xFFD0D3D8),
      asset: 'xai.svg'),
  'deepseek': ProviderIdentity(
      id: 'deepseek',
      displayName: 'DeepSeek',
      accent: Color(0xFF4D6BFE),
      asset: 'deepseek.svg'),
  'alibaba': ProviderIdentity(
      id: 'alibaba',
      displayName: 'Alibaba / Qwen',
      accent: Color(0xFF615CED),
      asset: 'alibaba.svg'),
  'zhipu-ai': ProviderIdentity(
      id: 'zhipu-ai', displayName: 'Zhipu AI', accent: Color(0xFF3859FF)),
  'baidu': ProviderIdentity(
      id: 'baidu',
      displayName: 'Baidu',
      accent: Color(0xFF2932E1),
      asset: 'baidu.svg'),
  'cohere': ProviderIdentity(
      id: 'cohere', displayName: 'Cohere', accent: Color(0xFFFF7759)),
  'local': ProviderIdentity(
      id: 'local', displayName: 'Local', accent: Color(0xFF8C9A8E)),
  'other': ProviderIdentity(
      id: 'other', displayName: 'Other', accent: AppDesign.forgeOnSurfaceFaint),
};

/// Neutral fallback for providers without a registry entry.
const ProviderIdentity _unknownIdentity = ProviderIdentity(
  id: 'unknown',
  displayName: 'Unknown',
  accent: AppDesign.forgeOnSurfaceFaint,
);

class ProviderRegistry {
  ProviderRegistry._();

  /// Resolve an identity from a provider id (preferred) or display name.
  /// Always returns a usable identity — falling back to a neutral monogram
  /// keyed on [providerName] when nothing matches.
  static ProviderIdentity resolve({String? providerId, String? providerName}) {
    if (providerId != null) {
      final byId = _registry[providerId.toLowerCase()];
      if (byId != null) return byId;
    }
    if (providerName != null && providerName.trim().isNotEmpty) {
      final needle = providerName.toLowerCase().trim();
      for (final identity in _registry.values) {
        if (identity.displayName.toLowerCase() == needle ||
            identity.id == needle) {
          return identity;
        }
      }
      // Unknown provider: keep its name but use the neutral accent + monogram.
      return ProviderIdentity(
        id: 'unknown',
        displayName: providerName.trim(),
        accent: _unknownIdentity.accent,
      );
    }
    return _unknownIdentity;
  }
}

/// Renders a provider's logo: the bundled SVG (tinted to its accent when
/// monochrome) or a monogram badge built from its display name. Treats logos as
/// identification only and never modifies their geometry.
class ProviderLogo extends StatelessWidget {
  final ProviderIdentity identity;
  final double size;

  const ProviderLogo({super.key, required this.identity, this.size = 20});

  @override
  Widget build(BuildContext context) {
    if (identity.asset != null) {
      return SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          identity._assetPath,
          width: size,
          height: size,
          colorFilter: identity.tintable
              ? ColorFilter.mode(identity.accent, BlendMode.srcIn)
              : null,
        ),
      );
    }
    final letter = identity.displayName.isNotEmpty
        ? identity.displayName.characters.first.toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: identity.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: identity.accent.withValues(alpha: 0.55)),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: AppDesign.fontDisplay,
          fontSize: size * 0.55,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: identity.accent,
        ),
      ),
    );
  }
}
