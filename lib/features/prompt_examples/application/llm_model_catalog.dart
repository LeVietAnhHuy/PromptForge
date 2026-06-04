class LlmModelOption {
  final String id;
  final String displayName;
  final String family;
  final int approximateReleaseOrder;
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

final Map<String, LlmModelCatalog> defaultModelCatalog = {
  'openai': const LlmModelCatalog(
    providerId: 'openai',
    providerName: 'OpenAI',
    models: [
      LlmModelOption(id: 'gpt-3.5-turbo', displayName: 'GPT-3.5 Turbo', family: 'GPT-3.5', approximateReleaseOrder: 10),
      LlmModelOption(id: 'gpt-4', displayName: 'GPT-4', family: 'GPT-4', approximateReleaseOrder: 20),
      LlmModelOption(id: 'gpt-4-turbo', displayName: 'GPT-4 Turbo', family: 'GPT-4', approximateReleaseOrder: 30),
      LlmModelOption(id: 'gpt-4o-mini', displayName: 'GPT-4o Mini', family: 'GPT-4o', approximateReleaseOrder: 40, supportsImageInput: true),
      LlmModelOption(id: 'gpt-4o', displayName: 'GPT-4o', family: 'GPT-4o', approximateReleaseOrder: 50, supportsImageInput: true),
      LlmModelOption(id: 'o1-mini', displayName: 'o1 Mini', family: 'o-series', approximateReleaseOrder: 60),
      LlmModelOption(id: 'o1-preview', displayName: 'o1 Preview', family: 'o-series', approximateReleaseOrder: 70),
    ],
  ),
  'anthropic': const LlmModelCatalog(
    providerId: 'anthropic',
    providerName: 'Anthropic',
    models: [
      LlmModelOption(id: 'claude-2', displayName: 'Claude 2', family: 'Claude 2', approximateReleaseOrder: 10, isDeprecated: true),
      LlmModelOption(id: 'claude-2.1', displayName: 'Claude 2.1', family: 'Claude 2', approximateReleaseOrder: 20, isDeprecated: true),
      LlmModelOption(id: 'claude-3-haiku', displayName: 'Claude 3 Haiku', family: 'Claude 3', approximateReleaseOrder: 30, supportsImageInput: true),
      LlmModelOption(id: 'claude-3-sonnet', displayName: 'Claude 3 Sonnet', family: 'Claude 3', approximateReleaseOrder: 40, supportsImageInput: true),
      LlmModelOption(id: 'claude-3-opus', displayName: 'Claude 3 Opus', family: 'Claude 3', approximateReleaseOrder: 50, supportsImageInput: true),
      LlmModelOption(id: 'claude-3-5-sonnet', displayName: 'Claude 3.5 Sonnet', family: 'Claude 3.5', approximateReleaseOrder: 60, supportsImageInput: true),
      LlmModelOption(id: 'claude-3-5-haiku', displayName: 'Claude 3.5 Haiku', family: 'Claude 3.5', approximateReleaseOrder: 70, supportsImageInput: true),
    ],
  ),
  'google': const LlmModelCatalog(
    providerId: 'google',
    providerName: 'Google',
    models: [
      LlmModelOption(id: 'gemini-1.0-pro', displayName: 'Gemini 1.0 Pro', family: 'Gemini 1.0', approximateReleaseOrder: 10),
      LlmModelOption(id: 'gemini-1.5-flash', displayName: 'Gemini 1.5 Flash', family: 'Gemini 1.5', approximateReleaseOrder: 20, supportsImageInput: true, supportsVideo: true, supportsFileInput: true),
      LlmModelOption(id: 'gemini-1.5-pro', displayName: 'Gemini 1.5 Pro', family: 'Gemini 1.5', approximateReleaseOrder: 30, supportsImageInput: true, supportsVideo: true, supportsFileInput: true),
      LlmModelOption(id: 'gemini-2.0-flash', displayName: 'Gemini 2.0 Flash', family: 'Gemini 2.x', approximateReleaseOrder: 40, supportsImageInput: true, supportsVideo: true, supportsFileInput: true),
    ],
  ),
  'deepseek': const LlmModelCatalog(
    providerId: 'deepseek',
    providerName: 'DeepSeek',
    models: [
      LlmModelOption(id: 'deepseek-chat', displayName: 'DeepSeek Chat', family: 'DeepSeek', approximateReleaseOrder: 10),
      LlmModelOption(id: 'deepseek-coder', displayName: 'DeepSeek Coder', family: 'DeepSeek', approximateReleaseOrder: 20),
      LlmModelOption(id: 'deepseek-reasoner', displayName: 'DeepSeek Reasoner (R1)', family: 'R-series', approximateReleaseOrder: 30),
    ],
  ),
  'alibaba': const LlmModelCatalog(
    providerId: 'alibaba',
    providerName: 'Alibaba Cloud',
    models: [
      LlmModelOption(id: 'qwen-1.5', displayName: 'Qwen 1.5', family: 'Qwen', approximateReleaseOrder: 10),
      LlmModelOption(id: 'qwen-2', displayName: 'Qwen 2', family: 'Qwen 2', approximateReleaseOrder: 20),
      LlmModelOption(id: 'qwen-2.5', displayName: 'Qwen 2.5', family: 'Qwen 2.5', approximateReleaseOrder: 30),
    ],
  ),
  'meta': const LlmModelCatalog(
    providerId: 'meta',
    providerName: 'Meta',
    models: [
      LlmModelOption(id: 'llama-2', displayName: 'Llama 2', family: 'Llama 2', approximateReleaseOrder: 10),
      LlmModelOption(id: 'llama-3', displayName: 'Llama 3', family: 'Llama 3', approximateReleaseOrder: 20),
      LlmModelOption(id: 'llama-3.1', displayName: 'Llama 3.1', family: 'Llama 3.1', approximateReleaseOrder: 30),
      LlmModelOption(id: 'llama-3.2', displayName: 'Llama 3.2', family: 'Llama 3.2', approximateReleaseOrder: 40, supportsImageInput: true),
    ],
  ),
  'mistral': const LlmModelCatalog(
    providerId: 'mistral',
    providerName: 'Mistral AI',
    models: [
      LlmModelOption(id: 'mistral-7b', displayName: 'Mistral 7B', family: 'Mistral', approximateReleaseOrder: 10),
      LlmModelOption(id: 'mixtral', displayName: 'Mixtral 8x7B', family: 'Mixtral', approximateReleaseOrder: 20),
      LlmModelOption(id: 'mistral-large', displayName: 'Mistral Large', family: 'Mistral Large', approximateReleaseOrder: 30),
      LlmModelOption(id: 'codestral', displayName: 'Codestral', family: 'Codestral', approximateReleaseOrder: 40),
    ],
  ),
  'xai': const LlmModelCatalog(
    providerId: 'xai',
    providerName: 'xAI',
    models: [
      LlmModelOption(id: 'grok-1', displayName: 'Grok 1', family: 'Grok', approximateReleaseOrder: 10),
      LlmModelOption(id: 'grok-1.5', displayName: 'Grok 1.5', family: 'Grok', approximateReleaseOrder: 20),
      LlmModelOption(id: 'grok-2', displayName: 'Grok 2', family: 'Grok', approximateReleaseOrder: 30),
    ],
  ),
  'cursor': const LlmModelCatalog(
    providerId: 'cursor',
    providerName: 'Cursor',
    models: [
      LlmModelOption(id: 'cursor-agent', displayName: 'Cursor Agent', family: 'Cursor', approximateReleaseOrder: 10),
    ],
  ),
  'notebooklm': const LlmModelCatalog(
    providerId: 'notebooklm',
    providerName: 'Google',
    models: [
      LlmModelOption(id: 'notebooklm', displayName: 'NotebookLM', family: 'NotebookLM', approximateReleaseOrder: 10),
    ],
  ),
  'flow': const LlmModelCatalog(
    providerId: 'flow',
    providerName: 'Flow',
    models: [
      LlmModelOption(id: 'flow-image', displayName: 'Flow Image', family: 'Flow', approximateReleaseOrder: 10),
      LlmModelOption(id: 'flow-video', displayName: 'Flow Video', family: 'Flow', approximateReleaseOrder: 20),
    ],
  ),
  'local': const LlmModelCatalog(
    providerId: 'local',
    providerName: 'Various',
    models: [
      LlmModelOption(id: 'ollama', displayName: 'Ollama Model', family: 'Local', approximateReleaseOrder: 10),
      LlmModelOption(id: 'lmstudio', displayName: 'LM Studio Model', family: 'Local', approximateReleaseOrder: 20),
    ],
  ),
};
