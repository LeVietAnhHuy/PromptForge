class LlmModelOption {
  final String id;
  final String displayName;
  final String family;
  final int approximateReleaseOrder;
  final bool isLegacy;
  final bool isPreview;
  final bool isDeprecated;
  final bool supportsText;
  final bool supportsImageInput;
  final bool supportsFileInput;
  final bool supportsVideo;
  final String? notes;

  const LlmModelOption({
    required this.id,
    required this.displayName,
    required this.family,
    required this.approximateReleaseOrder,
    this.isLegacy = false,
    this.isPreview = false,
    this.isDeprecated = false,
    this.supportsText = true,
    this.supportsImageInput = false,
    this.supportsFileInput = false,
    this.supportsVideo = false,
    this.notes,
  });
}

class LlmModelCatalog {
  final String providerId;
  final String providerName;
  final List<LlmModelOption> models;

  const LlmModelCatalog({
    required this.providerId,
    required this.providerName,
    required this.models,
  });
}

/// Capability buckets used by the model picker to separate everyday chat/text
/// families (shown first) from specialized modalities (collapsed at the bottom
/// and behind filter chips).
enum ModelCapability { chat, image, audio, video, embedding, other }

extension ModelCapabilityLabel on ModelCapability {
  String get label => switch (this) {
        ModelCapability.chat => 'Chat',
        ModelCapability.image => 'Image',
        ModelCapability.audio => 'Audio',
        ModelCapability.video => 'Video',
        ModelCapability.embedding => 'Embedding',
        ModelCapability.other => 'Other',
      };
}

/// Classifies a model family into a [ModelCapability]. The catalog already
/// groups non-chat models into capability-named families (Audio, Video, Image,
/// Embedding, Moderation, OSS, Imagen, Veo, Lyria, Nano, Vision, ...), so a
/// family-name heuristic is reliable; anything unmatched is treated as chat.
ModelCapability capabilityOfFamily(String family) {
  final f = family.toLowerCase();
  if (f.contains('embedding')) return ModelCapability.embedding;
  if (f.contains('moderation')) return ModelCapability.other;
  if (f.contains('image') ||
      f.contains('imagen') ||
      f.contains('vision') ||
      f.contains('nano')) {
    return ModelCapability.image;
  }
  if (f.contains('video') || f.contains('veo') || f.contains('sora')) {
    return ModelCapability.video;
  }
  if (f.contains('audio') || f.contains('lyria') || f.contains('voice')) {
    return ModelCapability.audio;
  }
  if (f == 'oss' ||
      f.contains('agent') ||
      f.contains('robotics') ||
      f.contains('deep research') ||
      f.contains('computer') ||
      f == 'other') {
    return ModelCapability.other;
  }
  return ModelCapability.chat;
}

ModelCapability capabilityOf(LlmModelOption model) =>
    capabilityOfFamily(model.family);

final Map<String, LlmModelCatalog> defaultModelCatalog = {
  'openai': const LlmModelCatalog(
    providerId: 'openai',
    providerName: 'OpenAI',
    models: [
      LlmModelOption(
          id: 'gpt-3.5-turbo',
          displayName: 'GPT-3.5 Turbo',
          family: 'GPT-3.5',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-4',
          displayName: 'GPT-4',
          family: 'GPT-4',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-4-turbo-preview',
          displayName: 'GPT-4 Turbo Preview',
          family: 'GPT-4',
          approximateReleaseOrder: 3,
          isLegacy: true,
          isPreview: true),
      LlmModelOption(
          id: 'gpt-4-turbo',
          displayName: 'GPT-4 Turbo',
          family: 'GPT-4',
          approximateReleaseOrder: 4,
          isLegacy: true),
      LlmModelOption(
          id: 'chatgpt-4o-latest',
          displayName: 'ChatGPT-4o',
          family: 'GPT-4o',
          approximateReleaseOrder: 5,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-4o',
          displayName: 'GPT-4o',
          family: 'GPT-4o',
          approximateReleaseOrder: 6,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-4o-mini',
          displayName: 'GPT-4o mini',
          family: 'GPT-4o',
          approximateReleaseOrder: 7),
      LlmModelOption(
          id: 'gpt-4o-search-preview',
          displayName: 'GPT-4o Search Preview',
          family: 'GPT-4o',
          approximateReleaseOrder: 8,
          isLegacy: true,
          isPreview: true),
      LlmModelOption(
          id: 'gpt-4o-mini-search-preview',
          displayName: 'GPT-4o mini Search Preview',
          family: 'GPT-4o',
          approximateReleaseOrder: 9,
          isLegacy: true,
          isPreview: true),
      LlmModelOption(
          id: 'computer-use-preview',
          displayName: 'computer-use-preview',
          family: 'Other',
          approximateReleaseOrder: 10,
          isLegacy: true,
          isPreview: true),
      LlmModelOption(
          id: 'o1-preview',
          displayName: 'o1 Preview',
          family: 'o-series',
          approximateReleaseOrder: 11,
          isLegacy: true,
          isPreview: true),
      LlmModelOption(
          id: 'o1-mini',
          displayName: 'o1-mini',
          family: 'o-series',
          approximateReleaseOrder: 12,
          isLegacy: true),
      LlmModelOption(
          id: 'o1',
          displayName: 'o1',
          family: 'o-series',
          approximateReleaseOrder: 13,
          isLegacy: true),
      LlmModelOption(
          id: 'o1-pro',
          displayName: 'o1-pro',
          family: 'o-series',
          approximateReleaseOrder: 14,
          isLegacy: true),
      LlmModelOption(
          id: 'o4-mini',
          displayName: 'o4-mini',
          family: 'o-series',
          approximateReleaseOrder: 15,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-4.5-preview',
          displayName: 'GPT-4.5 Preview',
          family: 'GPT-4.5',
          approximateReleaseOrder: 16,
          isLegacy: true,
          isPreview: true),
      LlmModelOption(
          id: 'gpt-4.1-nano',
          displayName: 'GPT-4.1 nano',
          family: 'GPT-4.1',
          approximateReleaseOrder: 17,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-4.1-mini',
          displayName: 'GPT-4.1 mini',
          family: 'GPT-4.1',
          approximateReleaseOrder: 18),
      LlmModelOption(
          id: 'gpt-4.1',
          displayName: 'GPT-4.1',
          family: 'GPT-4.1',
          approximateReleaseOrder: 19),
      LlmModelOption(
          id: 'o3-mini',
          displayName: 'o3-mini',
          family: 'o-series',
          approximateReleaseOrder: 20,
          isLegacy: true),
      LlmModelOption(
          id: 'o3',
          displayName: 'o3',
          family: 'o-series',
          approximateReleaseOrder: 21),
      LlmModelOption(
          id: 'o3-pro',
          displayName: 'o3-pro',
          family: 'o-series',
          approximateReleaseOrder: 22),
      LlmModelOption(
          id: 'o3-deep-research',
          displayName: 'o3-deep-research',
          family: 'o-series',
          approximateReleaseOrder: 23,
          isLegacy: true),
      LlmModelOption(
          id: 'o4-mini-deep-research',
          displayName: 'o4-mini-deep-research',
          family: 'o-series',
          approximateReleaseOrder: 24,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-codex',
          displayName: 'GPT-5-Codex',
          family: 'GPT-5',
          approximateReleaseOrder: 25,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-nano',
          displayName: 'GPT-5-nano',
          family: 'GPT-5',
          approximateReleaseOrder: 26),
      LlmModelOption(
          id: 'gpt-5-mini',
          displayName: 'GPT-5-mini',
          family: 'GPT-5',
          approximateReleaseOrder: 27),
      LlmModelOption(
          id: 'gpt-5-pro',
          displayName: 'GPT-5-pro',
          family: 'GPT-5',
          approximateReleaseOrder: 28),
      LlmModelOption(
          id: 'gpt-5-1-codex',
          displayName: 'GPT-5.1 Codex',
          family: 'GPT-5.1',
          approximateReleaseOrder: 29,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-1-codex-max',
          displayName: 'GPT-5.1-Codex-Max',
          family: 'GPT-5.1',
          approximateReleaseOrder: 30,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-1-codex-mini',
          displayName: 'GPT-5.1 Codex mini',
          family: 'GPT-5.1',
          approximateReleaseOrder: 31,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-1-chat-latest',
          displayName: 'GPT-5.1 Chat',
          family: 'GPT-5.1',
          approximateReleaseOrder: 32,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-2',
          displayName: 'GPT-5.2',
          family: 'GPT-5.2',
          approximateReleaseOrder: 33),
      LlmModelOption(
          id: 'gpt-5-2-pro',
          displayName: 'GPT-5.2 pro',
          family: 'GPT-5.2',
          approximateReleaseOrder: 34),
      LlmModelOption(
          id: 'gpt-5-2-codex',
          displayName: 'GPT-5.2-Codex',
          family: 'GPT-5.2',
          approximateReleaseOrder: 35,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-2-chat-latest',
          displayName: 'GPT-5.2 Chat',
          family: 'GPT-5.2',
          approximateReleaseOrder: 36,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-3-chat-latest',
          displayName: 'GPT-5.3 Chat',
          family: 'GPT-5.3',
          approximateReleaseOrder: 37,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-5-3-codex',
          displayName: 'GPT-5.3-Codex',
          family: 'GPT-5.3',
          approximateReleaseOrder: 38),
      LlmModelOption(
          id: 'gpt-5-4',
          displayName: 'GPT-5.4',
          family: 'GPT-5.4',
          approximateReleaseOrder: 39),
      LlmModelOption(
          id: 'gpt-5-4-pro',
          displayName: 'GPT-5.4 pro',
          family: 'GPT-5.4',
          approximateReleaseOrder: 40),
      LlmModelOption(
          id: 'gpt-5-4-mini',
          displayName: 'GPT-5.4-mini',
          family: 'GPT-5.4',
          approximateReleaseOrder: 41),
      LlmModelOption(
          id: 'gpt-5-4-nano',
          displayName: 'GPT-5.4-nano',
          family: 'GPT-5.4',
          approximateReleaseOrder: 42),
      LlmModelOption(
          id: 'gpt-5-5',
          displayName: 'GPT-5.5',
          family: 'GPT-5.5',
          approximateReleaseOrder: 43),
      LlmModelOption(
          id: 'gpt-5-5-pro',
          displayName: 'GPT-5.5 pro',
          family: 'GPT-5.5',
          approximateReleaseOrder: 44),
      LlmModelOption(
          id: 'gpt-oss-20b',
          displayName: 'gpt-oss-20b',
          family: 'OSS',
          approximateReleaseOrder: 45),
      LlmModelOption(
          id: 'gpt-oss-120b',
          displayName: 'gpt-oss-120b',
          family: 'OSS',
          approximateReleaseOrder: 46),
      LlmModelOption(
          id: 'gpt-oss-safeguard-20b',
          displayName: 'gpt-oss-safeguard-20b',
          family: 'OSS',
          approximateReleaseOrder: 47),
      LlmModelOption(
          id: 'gpt-oss-safeguard-120b',
          displayName: 'gpt-oss-safeguard-120b',
          family: 'OSS',
          approximateReleaseOrder: 48),
      LlmModelOption(
          id: 'gpt-image-1',
          displayName: 'GPT Image 1',
          family: 'Image',
          approximateReleaseOrder: 49,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-image-1.5',
          displayName: 'GPT Image 1.5',
          family: 'Image',
          approximateReleaseOrder: 50,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-image-2',
          displayName: 'GPT Image 2',
          family: 'Image',
          approximateReleaseOrder: 51),
      LlmModelOption(
          id: 'sora-2',
          displayName: 'Sora 2',
          family: 'Video',
          approximateReleaseOrder: 52,
          isLegacy: true),
      LlmModelOption(
          id: 'sora-2-pro',
          displayName: 'Sora 2 Pro',
          family: 'Video',
          approximateReleaseOrder: 53,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-realtime',
          displayName: 'gpt-realtime',
          family: 'Audio',
          approximateReleaseOrder: 54),
      LlmModelOption(
          id: 'gpt-audio',
          displayName: 'gpt-audio',
          family: 'Audio',
          approximateReleaseOrder: 55),
      LlmModelOption(
          id: 'gpt-realtime-mini',
          displayName: 'gpt-realtime-mini',
          family: 'Audio',
          approximateReleaseOrder: 56,
          isLegacy: true),
      LlmModelOption(
          id: 'gpt-realtime-1.5',
          displayName: 'gpt-realtime-1.5',
          family: 'Audio',
          approximateReleaseOrder: 57),
      LlmModelOption(
          id: 'gpt-audio-1.5',
          displayName: 'gpt-audio-1.5',
          family: 'Audio',
          approximateReleaseOrder: 58),
      LlmModelOption(
          id: 'gpt-realtime-translate',
          displayName: 'gpt-realtime-translate',
          family: 'Audio',
          approximateReleaseOrder: 59),
      LlmModelOption(
          id: 'gpt-realtime-2',
          displayName: 'gpt-realtime-2',
          family: 'Audio',
          approximateReleaseOrder: 60),
      LlmModelOption(
          id: 'gpt-realtime-whisper',
          displayName: 'gpt-realtime-whisper',
          family: 'Audio',
          approximateReleaseOrder: 61),
      LlmModelOption(
          id: 'gpt-4o-transcribe',
          displayName: 'GPT-4o Transcribe',
          family: 'Audio',
          approximateReleaseOrder: 62),
      LlmModelOption(
          id: 'gpt-4o-mini-transcribe',
          displayName: 'GPT-4o mini Transcribe',
          family: 'Audio',
          approximateReleaseOrder: 63),
      LlmModelOption(
          id: 'omni-moderation-latest',
          displayName: 'omni-moderation',
          family: 'Moderation',
          approximateReleaseOrder: 64),
      LlmModelOption(
          id: 'text-moderation-latest',
          displayName: 'text-moderation',
          family: 'Moderation',
          approximateReleaseOrder: 65,
          isLegacy: true),
      LlmModelOption(
          id: 'text-moderation-stable',
          displayName: 'text-moderation-stable',
          family: 'Moderation',
          approximateReleaseOrder: 66,
          isLegacy: true),
      LlmModelOption(
          id: 'babbage-002',
          displayName: 'babbage-002',
          family: 'Legacy',
          approximateReleaseOrder: 67,
          isLegacy: true),
      LlmModelOption(
          id: 'davinci-002',
          displayName: 'davinci-002',
          family: 'Legacy',
          approximateReleaseOrder: 68,
          isLegacy: true),
      LlmModelOption(
          id: 'text-embedding-ada-002',
          displayName: 'text-embedding-ada-002',
          family: 'Embedding',
          approximateReleaseOrder: 69,
          isLegacy: true),
      LlmModelOption(
          id: 'text-embedding-3-small',
          displayName: 'text-embedding-3-small',
          family: 'Embedding',
          approximateReleaseOrder: 70),
      LlmModelOption(
          id: 'text-embedding-3-large',
          displayName: 'text-embedding-3-large',
          family: 'Embedding',
          approximateReleaseOrder: 71),
    ],
  ),
  'anthropic': const LlmModelCatalog(
    providerId: 'anthropic',
    providerName: 'Anthropic',
    models: [
      LlmModelOption(
          id: 'claude-instant',
          displayName: 'Claude Instant',
          family: 'Claude',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'claude-1',
          displayName: 'Claude 1',
          family: 'Claude 1',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'claude-1.3',
          displayName: 'Claude 1.3',
          family: 'Claude 1',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'claude-2',
          displayName: 'Claude 2',
          family: 'Claude 2',
          approximateReleaseOrder: 4,
          isLegacy: true),
      LlmModelOption(
          id: 'claude-2.1',
          displayName: 'Claude 2.1',
          family: 'Claude 2',
          approximateReleaseOrder: 5,
          isLegacy: true),
      LlmModelOption(
          id: 'claude-3-opus-20240304',
          displayName: 'Claude 3 Opus',
          family: 'Claude 3',
          approximateReleaseOrder: 6),
      LlmModelOption(
          id: 'claude-3-sonnet-20240304',
          displayName: 'Claude 3 Sonnet',
          family: 'Claude 3',
          approximateReleaseOrder: 7),
      LlmModelOption(
          id: 'claude-3-haiku-20240307',
          displayName: 'Claude 3 Haiku',
          family: 'Claude 3',
          approximateReleaseOrder: 8),
      LlmModelOption(
          id: 'claude-3-5-sonnet-20240620',
          displayName: 'Claude 3.5 Sonnet',
          family: 'Claude 3.5',
          approximateReleaseOrder: 9),
      LlmModelOption(
          id: 'claude-3-5-sonnet-20241022',
          displayName: 'Claude 3.5 Sonnet [New]',
          family: 'Claude 3.5',
          approximateReleaseOrder: 10),
      LlmModelOption(
          id: 'claude-3-5-haiku-20241104',
          displayName: 'Claude 3.5 Haiku',
          family: 'Claude 3.5',
          approximateReleaseOrder: 11),
      LlmModelOption(
          id: 'claude-3-7-sonnet-20250224',
          displayName: 'Claude 3.7 Sonnet',
          family: 'Claude 3.7',
          approximateReleaseOrder: 12),
      LlmModelOption(
          id: 'claude-opus-4',
          displayName: 'Claude Opus 4',
          family: 'Claude 4',
          approximateReleaseOrder: 13),
      LlmModelOption(
          id: 'claude-sonnet-4',
          displayName: 'Claude Sonnet 4',
          family: 'Claude 4',
          approximateReleaseOrder: 14),
      LlmModelOption(
          id: 'claude-opus-4-1',
          displayName: 'Claude Opus 4.1',
          family: 'Claude 4',
          approximateReleaseOrder: 15),
      LlmModelOption(
          id: 'claude-sonnet-4-5',
          displayName: 'Claude Sonnet 4.5',
          family: 'Claude 4',
          approximateReleaseOrder: 16),
      LlmModelOption(
          id: 'claude-haiku-4-5-20251001',
          displayName: 'Claude Haiku 4.5',
          family: 'Claude 4',
          approximateReleaseOrder: 17),
      LlmModelOption(
          id: 'claude-opus-4-5',
          displayName: 'Claude Opus 4.5',
          family: 'Claude 4',
          approximateReleaseOrder: 18),
      LlmModelOption(
          id: 'claude-opus-4-6',
          displayName: 'Claude Opus 4.6',
          family: 'Claude 4',
          approximateReleaseOrder: 19),
      LlmModelOption(
          id: 'claude-sonnet-4-6',
          displayName: 'Claude Sonnet 4.6',
          family: 'Claude 4',
          approximateReleaseOrder: 20),
      LlmModelOption(
          id: 'claude-opus-4-7',
          displayName: 'Claude Opus 4.7',
          family: 'Claude 4',
          approximateReleaseOrder: 21),
      LlmModelOption(
          id: 'claude-opus-4-8',
          displayName: 'Claude Opus 4.8',
          family: 'Claude 4',
          approximateReleaseOrder: 22),
      LlmModelOption(
          id: 'claude-mythos-preview',
          displayName: 'Claude Mythos Preview',
          family: 'Claude',
          approximateReleaseOrder: 23,
          isPreview: true),
    ],
  ),
  'google': const LlmModelCatalog(
    providerId: 'google',
    providerName: 'Google',
    models: [
      LlmModelOption(
          id: 'text-bison',
          displayName: 'text-bison',
          family: 'PaLM',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'chat-bison',
          displayName: 'chat-bison',
          family: 'PaLM',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'code-gecko',
          displayName: 'code-gecko',
          family: 'PaLM',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'textembedding-gecko@001',
          displayName: 'textembedding-gecko@001',
          family: 'PaLM',
          approximateReleaseOrder: 4,
          isLegacy: true),
      LlmModelOption(
          id: 'textembedding-gecko@002',
          displayName: 'textembedding-gecko@002',
          family: 'PaLM',
          approximateReleaseOrder: 5,
          isLegacy: true),
      LlmModelOption(
          id: 'textembedding-gecko-multilingual@001',
          displayName: 'textembedding-gecko-multilingual@001',
          family: 'PaLM',
          approximateReleaseOrder: 6,
          isLegacy: true),
      LlmModelOption(
          id: 'textembedding-gecko@003',
          displayName: 'textembedding-gecko@003',
          family: 'PaLM',
          approximateReleaseOrder: 7,
          isLegacy: true),
      LlmModelOption(
          id: 'imagetext',
          displayName: 'imagetext',
          family: 'Vision',
          approximateReleaseOrder: 8,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-1.0-pro-001',
          displayName: 'gemini-1.0-pro-001',
          family: 'Gemini 1.0',
          approximateReleaseOrder: 9,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-1.0-pro-002',
          displayName: 'gemini-1.0-pro-002',
          family: 'Gemini 1.0',
          approximateReleaseOrder: 10,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-1.0-pro-vision-001',
          displayName: 'gemini-1.0-pro-vision-001',
          family: 'Gemini 1.0',
          approximateReleaseOrder: 11,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-1.5-pro-001',
          displayName: 'gemini-1.5-pro-001',
          family: 'Gemini 1.5',
          approximateReleaseOrder: 12,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-1.5-pro-002',
          displayName: 'gemini-1.5-pro-002',
          family: 'Gemini 1.5',
          approximateReleaseOrder: 13,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-1.5-flash-001',
          displayName: 'gemini-1.5-flash-001',
          family: 'Gemini 1.5',
          approximateReleaseOrder: 14,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-1.5-flash-002',
          displayName: 'gemini-1.5-flash-002',
          family: 'Gemini 1.5',
          approximateReleaseOrder: 15,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-2.0-flash',
          displayName: 'gemini-2.0-flash',
          family: 'Gemini 2.0',
          approximateReleaseOrder: 16,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-2.0-flash-lite',
          displayName: 'gemini-2.0-flash-lite',
          family: 'Gemini 2.0',
          approximateReleaseOrder: 17,
          isLegacy: true),
      LlmModelOption(
          id: 'gemini-2.5-pro',
          displayName: 'gemini-2.5-pro',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 18),
      LlmModelOption(
          id: 'gemini-2.5-flash',
          displayName: 'gemini-2.5-flash',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 19),
      LlmModelOption(
          id: 'gemini-2.5-flash-lite',
          displayName: 'gemini-2.5-flash-lite',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 20),
      LlmModelOption(
          id: 'gemini-live-2.5-flash-native-audio',
          displayName: 'gemini-live-2.5-flash-native-audio',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 21),
      LlmModelOption(
          id: 'gemini-2.5-flash-image',
          displayName: 'gemini-2.5-flash-image',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 22),
      LlmModelOption(
          id: 'gemini-2.5-flash-live-preview',
          displayName: 'gemini-2.5-flash-live-preview',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 23,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-2.5-flash-tts-preview',
          displayName: 'gemini-2.5-flash-tts-preview',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 24,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-2.5-pro-tts-preview',
          displayName: 'gemini-2.5-pro-tts-preview',
          family: 'Gemini 2.5',
          approximateReleaseOrder: 25,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-3-pro-preview',
          displayName: 'Gemini 3 Pro [Preview]',
          family: 'Gemini 3',
          approximateReleaseOrder: 26,
          isLegacy: true,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-3-flash-preview',
          displayName: 'Gemini 3 Flash [Preview]',
          family: 'Gemini 3',
          approximateReleaseOrder: 27,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-3-1-pro-preview',
          displayName: 'Gemini 3.1 Pro [Preview]',
          family: 'Gemini 3.1',
          approximateReleaseOrder: 28,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-3-1-flash-lite',
          displayName: 'Gemini 3.1 Flash-Lite',
          family: 'Gemini 3.1',
          approximateReleaseOrder: 29),
      LlmModelOption(
          id: 'gemini-3-1-flash-live-preview',
          displayName: 'Gemini 3.1 Flash Live [Preview]',
          family: 'Gemini 3.1',
          approximateReleaseOrder: 30,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-3-1-flash-tts-preview',
          displayName: 'Gemini 3.1 Flash TTS [Preview]',
          family: 'Gemini 3.1',
          approximateReleaseOrder: 31,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-3.5-flash',
          displayName: 'Gemini 3.5 Flash',
          family: 'Gemini 3.5',
          approximateReleaseOrder: 32),
      LlmModelOption(
          id: 'imagen-4',
          displayName: 'Imagen 4',
          family: 'Imagen',
          approximateReleaseOrder: 33),
      LlmModelOption(
          id: 'nano-banana',
          displayName: 'Nano Banana',
          family: 'Nano',
          approximateReleaseOrder: 34),
      LlmModelOption(
          id: 'nano-banana-pro',
          displayName: 'Nano Banana Pro',
          family: 'Nano',
          approximateReleaseOrder: 35),
      LlmModelOption(
          id: 'nano-banana-2',
          displayName: 'Nano Banana 2',
          family: 'Nano',
          approximateReleaseOrder: 36),
      LlmModelOption(
          id: 'veo-2.0-generate-001',
          displayName: 'Veo 2.0',
          family: 'Veo',
          approximateReleaseOrder: 37),
      LlmModelOption(
          id: 'veo-3.0-generate-001',
          displayName: 'Veo 3.0',
          family: 'Veo',
          approximateReleaseOrder: 38),
      LlmModelOption(
          id: 'veo-3.1-generate-001',
          displayName: 'Veo 3.1 Preview',
          family: 'Veo',
          approximateReleaseOrder: 39,
          isPreview: true),
      LlmModelOption(
          id: 'veo-3.1-fast-generate-001',
          displayName: 'Veo 3.1 Lite Preview',
          family: 'Veo',
          approximateReleaseOrder: 40,
          isPreview: true),
      LlmModelOption(
          id: 'lyria-3-pro-preview',
          displayName: 'Lyria 3 Pro Preview',
          family: 'Lyria',
          approximateReleaseOrder: 41,
          isPreview: true),
      LlmModelOption(
          id: 'lyria-3-clip-preview',
          displayName: 'Lyria 3 Clip Preview',
          family: 'Lyria',
          approximateReleaseOrder: 42,
          isPreview: true),
      LlmModelOption(
          id: 'lyria-realtime-experimental',
          displayName: 'Lyria RealTime Experimental',
          family: 'Lyria',
          approximateReleaseOrder: 43),
      LlmModelOption(
          id: 'computer-use-preview',
          displayName: 'Computer Use Preview',
          family: 'Other',
          approximateReleaseOrder: 44,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-deep-research-preview',
          displayName: 'Gemini Deep Research Preview',
          family: 'Deep Research',
          approximateReleaseOrder: 45,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-deep-research-max-preview',
          displayName: 'Gemini Deep Research Max Preview',
          family: 'Deep Research',
          approximateReleaseOrder: 46,
          isPreview: true),
      LlmModelOption(
          id: 'antigravity-agent-preview',
          displayName: 'Antigravity Agent Preview',
          family: 'Agent',
          approximateReleaseOrder: 47,
          isPreview: true),
      LlmModelOption(
          id: 'gemini-robotics-er-1-6-preview',
          displayName: 'Gemini Robotics-ER 1.6 Preview',
          family: 'Robotics',
          approximateReleaseOrder: 48,
          isPreview: true),
      LlmModelOption(
          id: 'multimodalembedding@001',
          displayName: 'multimodalembedding@001',
          family: 'Embedding',
          approximateReleaseOrder: 49),
      LlmModelOption(
          id: 'text-embedding-004',
          displayName: 'text-embedding-004',
          family: 'Embedding',
          approximateReleaseOrder: 50),
      LlmModelOption(
          id: 'text-embedding-005',
          displayName: 'text-embedding-005',
          family: 'Embedding',
          approximateReleaseOrder: 51),
      LlmModelOption(
          id: 'text-multilingual-embedding-002',
          displayName: 'text-multilingual-embedding-002',
          family: 'Embedding',
          approximateReleaseOrder: 52),
      LlmModelOption(
          id: 'gemini-embedding-001',
          displayName: 'gemini-embedding-001',
          family: 'Embedding',
          approximateReleaseOrder: 53),
    ],
  ),
  'deepseek': const LlmModelCatalog(
    providerId: 'deepseek',
    providerName: 'DeepSeek',
    models: [
      LlmModelOption(
          id: 'deepseek-chat',
          displayName: 'deepseek-chat',
          family: 'DeepSeek',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'deepseek-reasoner',
          displayName: 'deepseek-reasoner',
          family: 'DeepSeek',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'deepseek-v3',
          displayName: 'DeepSeek-V3',
          family: 'DeepSeek',
          approximateReleaseOrder: 3),
      LlmModelOption(
          id: 'deepseek-v3-0324',
          displayName: 'DeepSeek-V3-0324',
          family: 'DeepSeek',
          approximateReleaseOrder: 4),
      LlmModelOption(
          id: 'deepseek-v3-1-base',
          displayName: 'DeepSeek-V3.1 Base',
          family: 'DeepSeek',
          approximateReleaseOrder: 5),
      LlmModelOption(
          id: 'deepseek-v3-2-speciale',
          displayName: 'DeepSeek-V3.2 Speciale',
          family: 'DeepSeek',
          approximateReleaseOrder: 6),
      LlmModelOption(
          id: 'deepseek-r1',
          displayName: 'DeepSeek-R1',
          family: 'DeepSeek',
          approximateReleaseOrder: 7),
      LlmModelOption(
          id: 'deepseek-r1-0528',
          displayName: 'DeepSeek-R1-0528',
          family: 'DeepSeek',
          approximateReleaseOrder: 8),
      LlmModelOption(
          id: 'deepseek-v4-flash',
          displayName: 'deepseek-v4-flash',
          family: 'DeepSeek',
          approximateReleaseOrder: 9),
      LlmModelOption(
          id: 'deepseek-v4-pro',
          displayName: 'deepseek-v4-pro',
          family: 'DeepSeek',
          approximateReleaseOrder: 10),
      LlmModelOption(
          id: 'deepseek-r1-distill-qwen-1-5b',
          displayName: 'DeepSeek-R1-Distill-Qwen-1.5B',
          family: 'DeepSeek',
          approximateReleaseOrder: 11),
      LlmModelOption(
          id: 'deepseek-r1-distill-qwen-7b',
          displayName: 'DeepSeek-R1-Distill-Qwen-7B',
          family: 'DeepSeek',
          approximateReleaseOrder: 12),
      LlmModelOption(
          id: 'deepseek-r1-distill-llama-8b',
          displayName: 'DeepSeek-R1-Distill-Llama-8B',
          family: 'DeepSeek',
          approximateReleaseOrder: 13),
      LlmModelOption(
          id: 'deepseek-r1-distill-qwen-14b',
          displayName: 'DeepSeek-R1-Distill-Qwen-14B',
          family: 'DeepSeek',
          approximateReleaseOrder: 14),
      LlmModelOption(
          id: 'deepseek-r1-distill-qwen-32b',
          displayName: 'DeepSeek-R1-Distill-Qwen-32B',
          family: 'DeepSeek',
          approximateReleaseOrder: 15),
      LlmModelOption(
          id: 'deepseek-r1-distill-llama-70b',
          displayName: 'DeepSeek-R1-Distill-Llama-70B',
          family: 'DeepSeek',
          approximateReleaseOrder: 16),
    ],
  ),
  'mistral-ai': const LlmModelCatalog(
    providerId: 'mistral-ai',
    providerName: 'Mistral AI',
    models: [
      LlmModelOption(
          id: 'open-mistral-nemo-2407',
          displayName: 'open-mistral-nemo-2407',
          family: 'Mistral',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-large-2407',
          displayName: 'mistral-large-2407',
          family: 'Mistral',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-small-2409',
          displayName: 'mistral-small-2409',
          family: 'Mistral',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-moderation-2411',
          displayName: 'mistral-moderation-2411',
          family: 'Mistral',
          approximateReleaseOrder: 4,
          isLegacy: true),
      LlmModelOption(
          id: 'ministral-3b-2410',
          displayName: 'ministral-3b-2410',
          family: 'Mistral',
          approximateReleaseOrder: 5,
          isLegacy: true),
      LlmModelOption(
          id: 'ministral-8b-2410',
          displayName: 'ministral-8b-2410',
          family: 'Mistral',
          approximateReleaseOrder: 6,
          isLegacy: true),
      LlmModelOption(
          id: 'pixtral-12b-2409',
          displayName: 'pixtral-12b-2409',
          family: 'Mistral',
          approximateReleaseOrder: 7,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-large-2411',
          displayName: 'mistral-large-2411',
          family: 'Mistral',
          approximateReleaseOrder: 8,
          isLegacy: true),
      LlmModelOption(
          id: 'pixtral-large-2411',
          displayName: 'pixtral-large-2411',
          family: 'Mistral',
          approximateReleaseOrder: 9,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-small-2501',
          displayName: 'mistral-small-2501',
          family: 'Mistral',
          approximateReleaseOrder: 10,
          isLegacy: true),
      LlmModelOption(
          id: 'codestral-2501',
          displayName: 'codestral-2501',
          family: 'Mistral',
          approximateReleaseOrder: 11),
      LlmModelOption(
          id: 'mistral-ocr-2503',
          displayName: 'mistral-ocr-2503',
          family: 'Mistral',
          approximateReleaseOrder: 12,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-saba-2502',
          displayName: 'mistral-saba-2502',
          family: 'Mistral',
          approximateReleaseOrder: 13,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-small-2503',
          displayName: 'mistral-small-2503',
          family: 'Mistral',
          approximateReleaseOrder: 14,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-medium-2505',
          displayName: 'mistral-medium-2505',
          family: 'Mistral',
          approximateReleaseOrder: 15,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-ocr-2505',
          displayName: 'mistral-ocr-2505',
          family: 'Mistral',
          approximateReleaseOrder: 16,
          isLegacy: true),
      LlmModelOption(
          id: 'labs-devstral-small-2505',
          displayName: 'devstral-small-2505',
          family: 'Mistral',
          approximateReleaseOrder: 17,
          isLegacy: true),
      LlmModelOption(
          id: 'devstral-medium-2507',
          displayName: 'devstral-medium-2507',
          family: 'Mistral',
          approximateReleaseOrder: 18,
          isLegacy: true),
      LlmModelOption(
          id: 'devstral-small-2507',
          displayName: 'devstral-small-2507',
          family: 'Mistral',
          approximateReleaseOrder: 19,
          isLegacy: true),
      LlmModelOption(
          id: 'voxtral-mini-2507',
          displayName: 'voxtral-mini-2507',
          family: 'Mistral',
          approximateReleaseOrder: 20,
          isLegacy: true),
      LlmModelOption(
          id: 'magistral-small-2507',
          displayName: 'magistral-small-2507',
          family: 'Mistral',
          approximateReleaseOrder: 21,
          isLegacy: true),
      LlmModelOption(
          id: 'magistral-medium-2507',
          displayName: 'magistral-medium-2507',
          family: 'Mistral',
          approximateReleaseOrder: 22,
          isLegacy: true),
      LlmModelOption(
          id: 'magistral-small-2509',
          displayName: 'magistral-small-2509',
          family: 'Mistral',
          approximateReleaseOrder: 23,
          isLegacy: true),
      LlmModelOption(
          id: 'magistral-medium-2509',
          displayName: 'magistral-medium-2509',
          family: 'Mistral',
          approximateReleaseOrder: 24,
          isLegacy: true),
      LlmModelOption(
          id: 'labs-devstral-small-2512',
          displayName: 'devstral-small-2512',
          family: 'Mistral',
          approximateReleaseOrder: 25,
          isLegacy: true),
      LlmModelOption(
          id: 'labs-mistral-small-creative',
          displayName: 'labs-mistral-small-creative',
          family: 'Mistral',
          approximateReleaseOrder: 26,
          isLegacy: true),
      LlmModelOption(
          id: 'devstral-2512',
          displayName: 'devstral-2512',
          family: 'Mistral',
          approximateReleaseOrder: 27,
          isLegacy: true),
      LlmModelOption(
          id: 'labs-leanstral-2603',
          displayName: 'labs-leanstral-2603',
          family: 'Mistral',
          approximateReleaseOrder: 28,
          isLegacy: true),
      LlmModelOption(
          id: 'mistral-small-4',
          displayName: 'Mistral Small 4',
          family: 'Mistral',
          approximateReleaseOrder: 29),
      LlmModelOption(
          id: 'mistral-medium-3.5',
          displayName: 'Mistral Medium 3.5',
          family: 'Mistral',
          approximateReleaseOrder: 30),
      LlmModelOption(
          id: 'mistral-large-3',
          displayName: 'Mistral Large 3',
          family: 'Mistral',
          approximateReleaseOrder: 31),
      LlmModelOption(
          id: 'ministral-3-3b',
          displayName: 'Ministral 3 3B',
          family: 'Mistral',
          approximateReleaseOrder: 32),
      LlmModelOption(
          id: 'ministral-3-8b',
          displayName: 'Ministral 3 8B',
          family: 'Mistral',
          approximateReleaseOrder: 33),
      LlmModelOption(
          id: 'ministral-3-14b',
          displayName: 'Ministral 3 14B',
          family: 'Mistral',
          approximateReleaseOrder: 34),
      LlmModelOption(
          id: 'devstral-2',
          displayName: 'Devstral 2',
          family: 'Mistral',
          approximateReleaseOrder: 35),
      LlmModelOption(
          id: 'ocr-3',
          displayName: 'OCR 3',
          family: 'Mistral',
          approximateReleaseOrder: 36),
      LlmModelOption(
          id: 'voxtral-mini-transcribe-realtime',
          displayName: 'Voxtral Mini Transcribe Realtime',
          family: 'Mistral',
          approximateReleaseOrder: 37),
      LlmModelOption(
          id: 'voxtral-tts',
          displayName: 'Voxtral TTS',
          family: 'Mistral',
          approximateReleaseOrder: 38),
    ],
  ),
  'meta-llama': const LlmModelCatalog(
    providerId: 'meta-llama',
    providerName: 'Meta Llama',
    models: [
      LlmModelOption(
          id: 'llama-2-7b-chat',
          displayName: 'Llama 2',
          family: 'Llama',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'llama-3-8b-instruct',
          displayName: 'Llama 3 8B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'llama-3-70b-instruct',
          displayName: 'Llama 3 70B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'llama-3-1-8b-instruct',
          displayName: 'Llama 3.1 8B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 4,
          isLegacy: true),
      LlmModelOption(
          id: 'llama-3-1-70b-instruct',
          displayName: 'Llama 3.1 70B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 5,
          isLegacy: true),
      LlmModelOption(
          id: 'llama-3-1-405b-instruct',
          displayName: 'Llama 3.1 405B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 6,
          isLegacy: true),
      LlmModelOption(
          id: 'llama-3-2-1b-instruct',
          displayName: 'Llama 3.2 1B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 7),
      LlmModelOption(
          id: 'llama-3-2-3b-instruct',
          displayName: 'Llama 3.2 3B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 8),
      LlmModelOption(
          id: 'llama-3-2-11b-vision-instruct',
          displayName: 'Llama 3.2 11B Vision Instruct',
          family: 'Llama',
          approximateReleaseOrder: 9),
      LlmModelOption(
          id: 'llama-3-2-90b-vision-instruct',
          displayName: 'Llama 3.2 90B Vision Instruct',
          family: 'Llama',
          approximateReleaseOrder: 10),
      LlmModelOption(
          id: 'llama-3-3-8b-instruct',
          displayName: 'Llama 3.3 8B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 11),
      LlmModelOption(
          id: 'llama-3-3-70b-instruct',
          displayName: 'Llama 3.3 70B Instruct',
          family: 'Llama',
          approximateReleaseOrder: 12),
      LlmModelOption(
          id: 'Llama-4-Scout-17B-16E-Instruct-FP8',
          displayName: 'Llama 4 Scout',
          family: 'Llama',
          approximateReleaseOrder: 13),
      LlmModelOption(
          id: 'Llama-4-Maverick-17B-128E-Instruct-FP8',
          displayName: 'Llama 4 Maverick',
          family: 'Llama',
          approximateReleaseOrder: 14),
      LlmModelOption(
          id: 'llama-guard-4-12b',
          displayName: 'Llama Guard 4 12B',
          family: 'Llama',
          approximateReleaseOrder: 15),
    ],
  ),
  'zhipu-ai': const LlmModelCatalog(
    providerId: 'zhipu-ai',
    providerName: 'Zhipu AI',
    models: [
      LlmModelOption(
          id: 'glm-4.5-air',
          displayName: 'GLM-4.5-air',
          family: 'GLM',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'zhipu/glm-4.5',
          displayName: 'GLM-4.5',
          family: 'GLM',
          approximateReleaseOrder: 2),
      LlmModelOption(
          id: 'glm-4.6',
          displayName: 'GLM-4.6',
          family: 'GLM',
          approximateReleaseOrder: 3),
      LlmModelOption(
          id: 'zhipu/glm-4.7',
          displayName: 'GLM-4.7',
          family: 'GLM',
          approximateReleaseOrder: 4),
      LlmModelOption(
          id: 'zhipu/glm-5',
          displayName: 'GLM-5',
          family: 'GLM',
          approximateReleaseOrder: 5),
      LlmModelOption(
          id: 'glm-5.1',
          displayName: 'GLM-5.1',
          family: 'GLM',
          approximateReleaseOrder: 6),
    ],
  ),
  'baidu': const LlmModelCatalog(
    providerId: 'baidu',
    providerName: 'Baidu',
    models: [
      LlmModelOption(
          id: 'ernie-1.0-base-zh',
          displayName: 'ERNIE 1.0',
          family: 'ERNIE',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'ernie-2.0-base-en',
          displayName: 'ERNIE 2.0',
          family: 'ERNIE',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'ernie-3.0-base-zh',
          displayName: 'ERNIE 3.0',
          family: 'ERNIE',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'ernie-4.5-0.3b',
          displayName: 'ERNIE 4.5 0.3B',
          family: 'ERNIE',
          approximateReleaseOrder: 4),
      LlmModelOption(
          id: 'ernie-4.5-21b-a3b',
          displayName: 'ERNIE 4.5 21B A3B',
          family: 'ERNIE',
          approximateReleaseOrder: 5),
      LlmModelOption(
          id: 'ernie-4.5-300b-a47b',
          displayName: 'ERNIE 4.5 300B A47B',
          family: 'ERNIE',
          approximateReleaseOrder: 6),
      LlmModelOption(
          id: 'ernie-4.5-vl-28b-a3b',
          displayName: 'ERNIE 4.5 VL 28B A3B',
          family: 'ERNIE',
          approximateReleaseOrder: 7),
      LlmModelOption(
          id: 'ernie-4.5-vl-424b-a47b',
          displayName: 'ERNIE 4.5 VL 424B A47B',
          family: 'ERNIE',
          approximateReleaseOrder: 8),
      LlmModelOption(
          id: 'ernie-4.5-8k-preview',
          displayName: 'ERNIE 4.5 8K Preview',
          family: 'ERNIE',
          approximateReleaseOrder: 9,
          isPreview: true),
      LlmModelOption(
          id: 'ernie-4.5-turbo-128k',
          displayName: 'ERNIE 4.5 Turbo 128K',
          family: 'ERNIE',
          approximateReleaseOrder: 10),
      LlmModelOption(
          id: 'ernie-4.5-turbo-vl-32k',
          displayName: 'ERNIE 4.5 Turbo VL 32K',
          family: 'ERNIE',
          approximateReleaseOrder: 11),
      LlmModelOption(
          id: 'ernie-x1-turbo-32k',
          displayName: 'ERNIE X1 Turbo 32K',
          family: 'ERNIE',
          approximateReleaseOrder: 12),
      LlmModelOption(
          id: 'ernie-x1.1-preview',
          displayName: 'ERNIE X1.1 Preview',
          family: 'ERNIE',
          approximateReleaseOrder: 13,
          isPreview: true),
      LlmModelOption(
          id: 'ernie-5.0-thinking-preview',
          displayName: 'ERNIE 5.0 Thinking Preview',
          family: 'ERNIE',
          approximateReleaseOrder: 14,
          isPreview: true),
      LlmModelOption(
          id: 'ernie-5.0-thinking-latest',
          displayName: 'ERNIE 5.0 Thinking Latest',
          family: 'ERNIE',
          approximateReleaseOrder: 15),
    ],
  ),
  'microsoft': const LlmModelCatalog(
    providerId: 'microsoft',
    providerName: 'Microsoft',
    models: [
      LlmModelOption(
          id: 'phi-1',
          displayName: 'Phi-1',
          family: 'Phi',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'phi-1.5',
          displayName: 'Phi-1.5',
          family: 'Phi',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'phi-3',
          displayName: 'Phi-3',
          family: 'Phi',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'wizardlm-2-8x22b',
          displayName: 'WizardLM-2 8x22B',
          family: 'Wizard',
          approximateReleaseOrder: 4,
          isLegacy: true),
      LlmModelOption(
          id: 'phi-4',
          displayName: 'Phi-4',
          family: 'Phi',
          approximateReleaseOrder: 5),
      LlmModelOption(
          id: 'phi-4-mini-instruct',
          displayName: 'Phi-4-mini-instruct',
          family: 'Phi',
          approximateReleaseOrder: 6),
      LlmModelOption(
          id: 'phi-4-multimodal-instruct',
          displayName: 'Phi-4-multimodal-instruct',
          family: 'Phi',
          approximateReleaseOrder: 7),
      LlmModelOption(
          id: 'phi-4-reasoning',
          displayName: 'Phi-4-reasoning',
          family: 'Phi',
          approximateReleaseOrder: 8),
      LlmModelOption(
          id: 'phi-4-mini-reasoning',
          displayName: 'Phi-4-mini-reasoning',
          family: 'Phi',
          approximateReleaseOrder: 9),
    ],
  ),
  'cohere': const LlmModelCatalog(
    providerId: 'cohere',
    providerName: 'Cohere',
    models: [
      LlmModelOption(
          id: 'command-r-03-2024',
          displayName: 'command-r-03-2024',
          family: 'Command',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'command-r-08-2024',
          displayName: 'command-r-08-2024',
          family: 'Command',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'command-r-plus-08-2024',
          displayName: 'command-r-plus-08-2024',
          family: 'Command',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'command-r7b-12-2024',
          displayName: 'command-r7b-12-2024',
          family: 'Command',
          approximateReleaseOrder: 4),
      LlmModelOption(
          id: 'command-a-03-2025',
          displayName: 'command-a-03-2025',
          family: 'Command',
          approximateReleaseOrder: 5),
      LlmModelOption(
          id: 'command-a-plus-05-2026',
          displayName: 'command-a-plus-05-2026',
          family: 'Command',
          approximateReleaseOrder: 6),
      LlmModelOption(
          id: 'command-a-translate-08-2025',
          displayName: 'command-a-translate-08-2025',
          family: 'Command',
          approximateReleaseOrder: 7),
      LlmModelOption(
          id: 'command-a-reasoning-08-2025',
          displayName: 'command-a-reasoning-08-2025',
          family: 'Command',
          approximateReleaseOrder: 8),
      LlmModelOption(
          id: 'command-a-vision-07-2025',
          displayName: 'command-a-vision-07-2025',
          family: 'Command',
          approximateReleaseOrder: 9),
      LlmModelOption(
          id: 'aya-expanse',
          displayName: 'Aya Expanse',
          family: 'Aya',
          approximateReleaseOrder: 10),
      LlmModelOption(
          id: 'aya-vision',
          displayName: 'Aya Vision',
          family: 'Aya',
          approximateReleaseOrder: 11),
    ],
  ),
  'xai': const LlmModelCatalog(
    providerId: 'xai',
    providerName: 'xAI',
    models: [
      LlmModelOption(
          id: 'grok-beta',
          displayName: 'grok-beta',
          family: 'Grok',
          approximateReleaseOrder: 1,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-3-beta',
          displayName: 'grok-3-beta',
          family: 'Grok',
          approximateReleaseOrder: 2,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-3-mini-beta',
          displayName: 'grok-3-mini-beta',
          family: 'Grok',
          approximateReleaseOrder: 3,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-code-fast-1',
          displayName: 'grok-code-fast-1',
          family: 'Grok',
          approximateReleaseOrder: 4,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-4-fast-non-reasoning',
          displayName: 'grok-4-fast-non-reasoning',
          family: 'Grok',
          approximateReleaseOrder: 5,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-4-fast-reasoning',
          displayName: 'grok-4-fast-reasoning',
          family: 'Grok',
          approximateReleaseOrder: 6,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-4.1-fast-non-reasoning',
          displayName: 'grok-4.1-fast-non-reasoning',
          family: 'Grok',
          approximateReleaseOrder: 7,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-4.1-fast-reasoning',
          displayName: 'grok-4.1-fast-reasoning',
          family: 'Grok',
          approximateReleaseOrder: 8,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-4.20-non-reasoning',
          displayName: 'grok-4.20-non-reasoning',
          family: 'Grok',
          approximateReleaseOrder: 9,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-4.20-reasoning',
          displayName: 'grok-4.20-reasoning',
          family: 'Grok',
          approximateReleaseOrder: 10,
          isLegacy: true),
      LlmModelOption(
          id: 'grok-build-0.1',
          displayName: 'grok-build-0.1',
          family: 'Grok',
          approximateReleaseOrder: 11),
      LlmModelOption(
          id: 'grok-4.3',
          displayName: 'grok-4.3',
          family: 'Grok',
          approximateReleaseOrder: 12),
    ],
  ),
};
