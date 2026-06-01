import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'daos/daos.dart';
import 'seed_data.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // Seed the database if it's empty
  SeedData.seedIfEmpty(db);
  
  ref.onDispose(db.close);
  return db;
});

final promptDaoProvider = Provider<PromptDao>((ref) {
  return PromptDao(ref.watch(databaseProvider));
});

final contextPackDaoProvider = Provider<ContextPackDao>((ref) {
  return ContextPackDao(ref.watch(databaseProvider));
});

final inboxItemDaoProvider = Provider<InboxItemDao>((ref) {
  return InboxItemDao(ref.watch(databaseProvider));
});

final tagDaoProvider = Provider<TagDao>((ref) {
  return TagDao(ref.watch(databaseProvider));
});

final collectionDaoProvider = Provider<CollectionDao>((ref) {
  return CollectionDao(ref.watch(databaseProvider));
});

final userSettingsDaoProvider = Provider<UserSettingsDao>((ref) {
  return UserSettingsDao(ref.watch(databaseProvider));
});
