import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

final contextPacksProvider = StreamProvider<List<ContextPack>>((ref) {
  final contextPackDao = ref.watch(contextPackDaoProvider);
  return contextPackDao.watchAllContextPacks();
});
