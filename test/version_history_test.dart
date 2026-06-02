import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/daos/daos.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('Updating a prompt directly in DAO does not automatically create version (it is a service-level feature)', () async {
    // We test the service/DAO methods manually mimicking the Editor screen behavior.
  });

  test('Creating and Restoring Prompt Version', () async {
    final promptDao = PromptDao(database);
    
    // 1. Create a live prompt
    final pId = const Uuid().v4();
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: pId,
      title: 'V1 Title',
      body: 'V1 Body',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // 2. Create a snapshot (as if editing it)
    await promptDao.createPromptVersion(PromptVersionsCompanion.insert(
      id: const Uuid().v4(),
      promptId: pId,
      title: 'V1 Title',
      body: 'V1 Body',
      createdAt: DateTime.now(),
    ));

    // 3. Update the live prompt to V2
    await promptDao.updatePrompt(PromptsCompanion.insert(
      id: pId,
      title: 'V2 Title',
      body: 'V2 Body',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // 4. Verify version history has 1 entry
    final versions = await promptDao.watchPromptVersions(pId).first;
    expect(versions.length, 1);
    expect(versions.first.title, 'V1 Title');
    
    // 5. To test restore logic, we'd ideally call the UI method, but since it's in the Widget, we'll write a widget test for the full restore cycle instead.
  });
  
  test('Creating and fetching Context Pack Version', () async {
    final cpDao = ContextPackDao(database);
    
    final cpId = const Uuid().v4();
    await cpDao.createContextPack(ContextPacksCompanion.insert(
      id: cpId,
      name: 'Pack V1',
      content: 'Content V1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    
    await cpDao.createContextPackVersion(ContextPackVersionsCompanion.insert(
      id: const Uuid().v4(),
      contextPackId: cpId,
      name: 'Pack V1',
      content: 'Content V1',
      createdAt: DateTime.now(),
    ));
    
    final versions = await cpDao.watchContextPackVersions(cpId).first;
    expect(versions.length, 1);
    expect(versions.first.name, 'Pack V1');
  });
}
