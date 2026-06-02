import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/database/seed_data.dart';
import 'package:promptforge/core/database/daos/daos.dart';

void main() {
  test('SeedData.seedIfEmpty is idempotent', () async {
    final db = AppDatabase(e: NativeDatabase.memory());
    final providerDao = LLMProviderDao(db);
    final modelDao = LLMModelDao(db);

    // Initial check
    var providers = await providerDao.getAllProviders();
    expect(providers, isEmpty);

    // First seed
    await SeedData.seedIfEmpty(db);
    
    providers = await providerDao.getAllProviders();
    expect(providers, isNotEmpty);
    final initialCount = providers.length;
    
    final models = await modelDao.getModelsForProvider('openai');
    expect(models, isNotEmpty);
    final initialModelCount = models.length;

    // Second seed
    await SeedData.seedIfEmpty(db);
    
    // Check that counts remain the same
    providers = await providerDao.getAllProviders();
    expect(providers.length, initialCount);
    
    final modelsAfter = await modelDao.getModelsForProvider('openai');
    expect(modelsAfter.length, initialModelCount);

    await db.close();
  });
}
