# Third-Party Notices

PromptForge bundles the following third-party assets locally. Each is used
under a permissive license. No assets are hot-linked at runtime.

## Fonts (`assets/fonts/`)

All three font families are licensed under the **SIL Open Font License 1.1**
(OFL). The full license text for each ships alongside the font files
(`OFL-*.txt`).

| Family | Files | Role | Source |
| --- | --- | --- | --- |
| Space Grotesk | `SpaceGrotesk-Variable.ttf` | Display / brand headings | https://github.com/google/fonts (ofl/spacegrotesk) |
| Atkinson Hyperlegible | `AtkinsonHyperlegible-Regular.ttf`, `AtkinsonHyperlegible-Bold.ttf` | Body / UI text | https://github.com/google/fonts (ofl/atkinsonhyperlegible) |
| JetBrains Mono | `JetBrainsMono-Variable.ttf` | Monospace / prompt & code content | https://github.com/google/fonts (ofl/jetbrainsmono) |

## Provider logos (`assets/provider_icons/`)

Brand marks are used **only to identify the corresponding provider**, rendered
unmodified (tinted to a single fill where the source is monochrome). They are
not endorsements.

Most marks come from **Simple Icons** (licensed **CC0 1.0**; see
`assets/provider_icons/LICENSE-simple-icons.txt`):

| App provider id | File | Simple Icons slug |
| --- | --- | --- |
| anthropic | `anthropic.svg` | anthropic |
| google | `google.svg` | googlegemini |
| meta | `meta.svg` | meta |
| mistral | `mistral.svg` | mistralai |
| deepseek | `deepseek.svg` | deepseek |
| alibaba | `alibaba.svg` | qwen |
| baidu | `baidu.svg` | baidu |
| xai | `xai.svg` | x |

The following marks are **not** in the CC0 set and are handled separately:

- `microsoft.svg` — an authored four-square mark (simple geometric
  representation) for identification only.
- **OpenAI, Cohere, Zhipu AI, and any other provider without a bundled SVG**
  fall back to a generated monogram badge (first letter on the provider's
  accent color) rendered in-app — see
  `lib/shared/providers/provider_identity.dart`. No copyrighted logo is
  reproduced for these.

To add a logo for a new provider: drop a permissively licensed SVG into
`assets/provider_icons/<provider-id>.svg` and add a one-line entry to the
provider registry in `lib/shared/providers/provider_identity.dart`.
