import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/features/projects/domain/prompt_run_converter_service.dart';

void main() {
  late AppDatabase db;
  late PromptRunConverterService service;

  setUp(() {
    db = AppDatabase(e: NativeDatabase.memory());
    service = PromptRunConverterService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('converts Prompt Run to Prompt Card and links them', () async {
    // 1. Setup mock data
    const projectId = 'proj-1';
    const runId = 'run-1';
    
    await db.projectDao.createProject(ProjectsCompanion.insert(
      id: projectId,
      name: 'Test Project',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    await db.promptExampleDao.createExample(PromptExamplesCompanion.insert(
      id: runId,
      projectId: const drift.Value(projectId),
      title: 'Amazing Run',
      compiledPrompt: 'This is the run input body',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    await db.promptExampleOutputDao.addOutput(PromptExampleOutputsCompanion.insert(
      id: 'out-1',
      exampleId: runId,
      providerName: 'Claude',
      modelName: const drift.Value('Claude 3.5 Sonnet'),
      outputType: const drift.Value('text'),
      outputText: 'Response 1',
      isBest: const drift.Value(true),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // 2. Perform conversion
    final newPromptId = await service.convertRunToPromptCard(
      runId: runId,
      title: 'My Reusable Card',
      purpose: 'Testing conversion',
      targetNotes: 'Originally tested with Claude (Claude 3.5 Sonnet)',
    );

    // 3. Verify Prompt Card was created
    final prompt = await db.promptDao.getPromptById(newPromptId);
    expect(prompt, isNotNull);
    expect(prompt.title, 'My Reusable Card');
    expect(prompt.purpose, 'Testing conversion');
    expect(prompt.body, 'This is the run input body'); // Uses run input
    expect(prompt.targetNotes, 'Originally tested with Claude (Claude 3.5 Sonnet)');
    expect(prompt.outputFormat, 'text'); // Inferred from best output

    // 4. Verify original run is updated with promptId link
    final updatedRun = await db.promptExampleDao.getExampleById(runId);
    expect(updatedRun.promptId, newPromptId); // Successfully linked!
    
    // 5. Verify snapshot was created
    final versions = await db.promptDao.getPromptVersions(newPromptId);
    expect(versions.length, 1);
    expect(versions.first.title, 'My Reusable Card');
    expect(versions.first.body, 'This is the run input body');
  });
}
