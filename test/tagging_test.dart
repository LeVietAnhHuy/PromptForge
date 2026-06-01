import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/daos/daos.dart';

void main() {
  late AppDatabase database;
  late TagDao tagDao;
  late PromptDao promptDao;

  setUp(() {
    database = AppDatabase(e: NativeDatabase.memory());
    tagDao = TagDao(database);
    promptDao = PromptDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Tag normalization and replacement', () async {
    final promptId = const Uuid().v4();
    await promptDao.createPrompt(PromptsCompanion.insert(
      id: promptId,
      title: 'Test Prompt',
      body: 'Body',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Input with spaces, uppercase, duplicates, and empty strings
    final rawTags = [
      ' Coding ',
      'article',
      'CODING',
      '',
      '  ',
      'translation',
      'Translation '
    ];

    await tagDao.replaceTagsForPrompt(promptId, rawTags);

    final tagsForPrompt = await tagDao.getTagsForPrompt(promptId);
    
    expect(tagsForPrompt.length, 3);
    final tagNames = tagsForPrompt.map((t) => t.name).toSet();
    expect(tagNames.contains('coding'), isTrue);
    expect(tagNames.contains('article'), isTrue);
    expect(tagNames.contains('translation'), isTrue);

    // Replace with fewer tags
    await tagDao.replaceTagsForPrompt(promptId, ['coding', 'new-tag']);
    final updatedTags = await tagDao.getTagsForPrompt(promptId);
    
    expect(updatedTags.length, 2);
    final updatedNames = updatedTags.map((t) => t.name).toSet();
    expect(updatedNames.contains('coding'), isTrue);
    expect(updatedNames.contains('new-tag'), isTrue);
    expect(updatedNames.contains('article'), isFalse);
  });
}
