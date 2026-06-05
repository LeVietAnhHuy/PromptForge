import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:promptforge/shared/providers/provider_identity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The Stage 24 Part B minimum logo set.
  const minimumSet = [
    'openai',
    'anthropic',
    'google',
    'microsoft',
    'meta',
    'mistral',
    'xai',
    'deepseek',
    'alibaba',
    'cohere',
  ];

  test('every minimum-set provider resolves to a bundled logo (no monogram)',
      () {
    for (final id in minimumSet) {
      final identity = ProviderRegistry.resolve(providerId: id);
      expect(identity.id, id, reason: '$id should be a known provider');
      expect(identity.asset, isNotNull,
          reason: '$id must ship a real logo, not a monogram fallback');
    }
  });

  test(
      'every bundled provider logo exists in the asset bundle and parses as SVG',
      () async {
    final withAsset = ProviderRegistry.identitiesWithAsset.toList();
    expect(withAsset, isNotEmpty);
    for (final identity in withAsset) {
      final path = identity.assetPath!;
      final svg = await rootBundle.loadString(path);
      expect(svg.contains('<svg'), isTrue,
          reason: '$path should contain an <svg> root');
      // Compiles the SVG via flutter_svg; throws if it is malformed.
      await SvgStringLoader(svg).loadBytes(null);
    }
  });

  test('unknown providers still fall back to a monogram (null asset)', () {
    final unknown = ProviderRegistry.resolve(providerName: 'Totally New Co');
    expect(unknown.asset, isNull);
    expect(unknown.id, 'unknown');
  });
}
