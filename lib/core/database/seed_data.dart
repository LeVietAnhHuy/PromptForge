import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';
import 'daos/daos.dart';

const uuid = Uuid();

class SeedData {
  static Future<void> seedIfEmpty(AppDatabase db) async {
    final promptDao = PromptDao(db);
    final contextPackDao = ContextPackDao(db);
    final settingsDao = UserSettingsDao(db);

    final isSeeded = await settingsDao.getSetting('is_seeded');
    if (isSeeded != null && isSeeded.value == 'true') {
      return;
    }

    final now = DateTime.now();

    // Sample Context Packs
    final claudeCodePackId = uuid.v4();
    final codexPackId = uuid.v4();
    final paperPackId = uuid.v4();
    final latexPackId = uuid.v4();
    final oranPackId = uuid.v4();
    final flowImagePackId = uuid.v4();
    final flowVideoPackId = uuid.v4();
    final notebookLmPackId = uuid.v4();

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: claudeCodePackId,
      name: 'Claude Code Implementation Pack',
      content: 'You are an expert Flutter engineer. Do not remove existing comments. Implement surgical changes only.',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: codexPackId,
      name: 'Codex Implementation Pack',
      content: 'Output strictly in Markdown code blocks. Do not explain the code.',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: paperPackId,
      name: 'Paper Reading Pack',
      content: 'Analyze the methodology, limitations, and future work. Structure as a bulleted summary.',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: latexPackId,
      name: 'LaTeX Slide Builder Pack',
      content: 'Use Beamer class. Ensure all equations are wrapped in proper math modes. Include presenter notes.',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: oranPackId,
      name: 'O-RAN Expert Reviewer Pack',
      content: 'Evaluate against 3GPP Rel-17 specifications. Check for Fronthaul interface compliance.',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: flowImagePackId,
      name: 'Flow Image Prompt Pack',
      content: '--v 6.0 --style raw --ar 16:9',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: flowVideoPackId,
      name: 'Flow Video Prompt Pack',
      content: 'Smooth panning, cinematic lighting, 4k resolution, hyper-realistic.',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    await contextPackDao.createContextPack(ContextPacksCompanion.insert(
      id: notebookLmPackId,
      name: 'NotebookLM Paper Analysis Pack',
      content: 'Extract key claims and match them against the citations provided.',
      isBuiltin: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    // Sample Prompts
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: uuid.v4(),
      title: 'Claude Code Implementation Prompt',
      body: 'Implement the following feature: {feature_description} in the file {file_path}.',
      createdAt: now,
      updatedAt: now,
    ));

    await promptDao.createPrompt(PromptsCompanion.insert(
      id: uuid.v4(),
      title: 'Codex Implementation Prompt',
      body: 'Write a Dart function to {function_goal}. Use parameters {parameters}.',
      createdAt: now,
      updatedAt: now,
    ));

    await promptDao.createPrompt(PromptsCompanion.insert(
      id: uuid.v4(),
      title: 'Paper to LaTeX Slide Prompt',
      body: 'Convert the following paper section into a slide: {paper_section}',
      createdAt: now,
      updatedAt: now,
    ));

    await promptDao.createPrompt(PromptsCompanion.insert(
      id: uuid.v4(),
      title: 'NotebookLM Paper Analysis Prompt',
      body: 'Summarize the contributions of this paper: {paper_text}',
      createdAt: now,
      updatedAt: now,
    ));

    await promptDao.createPrompt(PromptsCompanion.insert(
      id: uuid.v4(),
      title: 'Flow Image Prompt',
      body: 'A portrait of a {subject}, {lighting_style}, shot on {camera}.',
      createdAt: now,
      updatedAt: now,
    ));

    await promptDao.createPrompt(PromptsCompanion.insert(
      id: uuid.v4(),
      title: 'Flow Video Prompt',
      body: 'A drone fly-through of a {landscape_description}.',
      createdAt: now,
      updatedAt: now,
    ));

    await promptDao.createPrompt(PromptsCompanion.insert(
      id: uuid.v4(),
      title: 'O-RAN Expert Reviewer Prompt',
      body: 'Review this architecture diagram description for compliance: {architecture_description}',
      createdAt: now,
      updatedAt: now,
    ));

    // Seed LLM Providers
    final providerDao = LLMProviderDao(db);
    final modelDao = LLMModelDao(db);

    final providers = [
      {'id': 'openai', 'name': 'OpenAI', 'company': 'OpenAI', 'color': '#10a37f'},
      {'id': 'anthropic', 'name': 'Anthropic', 'company': 'Anthropic', 'color': '#d97757'},
      {'id': 'google', 'name': 'Google', 'company': 'Google', 'color': '#1a73e8'},
      {'id': 'alibaba', 'name': 'Alibaba / Qwen', 'company': 'Alibaba Cloud', 'color': '#6e32c9'},
      {'id': 'deepseek', 'name': 'DeepSeek', 'company': 'DeepSeek', 'color': '#4a90e2'},
      {'id': 'meta', 'name': 'Meta', 'company': 'Meta', 'color': '#0668E1'},
      {'id': 'mistral', 'name': 'Mistral', 'company': 'Mistral AI', 'color': '#f2a900'},
      {'id': 'xai', 'name': 'xAI', 'company': 'xAI', 'color': '#000000'},
      {'id': 'cursor', 'name': 'Cursor', 'company': 'Cursor', 'color': '#000000'},
      {'id': 'notebooklm', 'name': 'NotebookLM', 'company': 'Google', 'color': '#1a73e8'},
      {'id': 'flow', 'name': 'Flow', 'company': 'Flow', 'color': '#000000'},
      {'id': 'local', 'name': 'Local', 'company': 'Various', 'color': '#555555'},
      {'id': 'other', 'name': 'Other', 'company': 'Other', 'color': '#888888'},
    ];

    for (final p in providers) {
      await providerDao.createProvider(LLMProvidersCompanion.insert(
        id: p['id']!,
        name: p['name']!,
        company: Value(p['company']),
        accentColorHex: Value(p['color']),
        createdAt: now,
      ));
    }

    // Seed some basic models
    final models = [
      {'id': 'gpt-4o', 'providerId': 'openai', 'name': 'GPT-4o'},
      {'id': 'gpt-4-turbo', 'providerId': 'openai', 'name': 'GPT-4 Turbo'},
      {'id': 'claude-3-5-sonnet', 'providerId': 'anthropic', 'name': 'Claude 3.5 Sonnet'},
      {'id': 'claude-3-opus', 'providerId': 'anthropic', 'name': 'Claude 3 Opus'},
      {'id': 'gemini-1-5-pro', 'providerId': 'google', 'name': 'Gemini 1.5 Pro'},
      {'id': 'qwen-max', 'providerId': 'alibaba', 'name': 'Qwen Max'},
      {'id': 'deepseek-coder', 'providerId': 'deepseek', 'name': 'DeepSeek Coder V2'},
      {'id': 'llama-3-70b', 'providerId': 'meta', 'name': 'Llama 3 70B'},
      {'id': 'mistral-large', 'providerId': 'mistral', 'name': 'Mistral Large'},
    ];

    for (final m in models) {
      await modelDao.createModel(LLMModelsCompanion.insert(
        id: m['id']!,
        providerId: m['providerId']!,
        name: m['name']!,
        createdAt: now,
      ));
    }

    await settingsDao.setSetting(UserSettingsCompanion.insert(
      key: 'is_seeded',
      value: 'true',
      updatedAt: now,
    ));
  }
}
