import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

final promptRunConverterServiceProvider = Provider<PromptRunConverterService>((ref) {
  final db = ref.watch(databaseProvider);
  return PromptRunConverterService(db);
});

class PromptRunConverterService {
  final AppDatabase _db;

  PromptRunConverterService(this._db);

  /// Converts a Workspace Prompt Run (PromptExample) into a reusable Prompt Card (Prompt).
  ///
  /// The [title], [purpose], and [targetNotes] can be customized via the UI before calling this.
  Future<String> convertRunToPromptCard({
    required String runId,
    required String title,
    required String purpose,
    String? targetNotes,
  }) async {
    return await _db.transaction(() async {
      // 1. Load the run
      final run = await _db.promptExampleDao.getExampleById(runId);
      
      // 2. Extract best/first output for outputType if not provided
      final outputs = await _db.promptExampleOutputDao.getOutputsForExample(runId);
      String? outputFormat;
      if (outputs.isNotEmpty) {
        final bestOutput = outputs.firstWhere((o) => o.isBest, orElse: () => outputs.first);
        outputFormat = bestOutput.outputType;
      }

      final now = DateTime.now();
      final newPromptId = const Uuid().v4();

      // 3. Create the Prompt Card
      await _db.promptDao.createPrompt(PromptsCompanion.insert(
        id: newPromptId,
        title: title,
        body: run.compiledPrompt,
        purpose: drift.Value(purpose),
        outputFormat: drift.Value(outputFormat),
        targetNotes: drift.Value(targetNotes),
        createdAt: now,
        updatedAt: now,
      ));

      // 4. Create initial Prompt Version snapshot
      await _db.promptDao.createPromptVersion(PromptVersionsCompanion.insert(
        id: const Uuid().v4(),
        promptId: newPromptId,
        title: title,
        body: run.compiledPrompt,
        createdAt: now,
      ));

      // 5. Link the original run to this new prompt card
      await _db.promptExampleDao.updateExample(run.toCompanion(true).copyWith(
        promptId: drift.Value(newPromptId),
        updatedAt: drift.Value(now),
      ));

      return newPromptId;
    });
  }
}
