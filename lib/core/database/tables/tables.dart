import 'package:drift/drift.dart';

class Prompts extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text()();
  TextColumn get purpose => text().nullable()();
  TextColumn get body => text()();
  TextColumn get promptType => text().nullable()();
  TextColumn get outputFormat => text().nullable()();
  TextColumn get targetNotes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptVersions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get promptId => text()(); // FK
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get tagsJson => text().nullable()();
  TextColumn get variableMetadataJson => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ContextPackVersions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get contextPackId => text()(); // FK
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get content => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptVariables extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get promptId => text()(); // FK
  TextColumn get name => text()();
  TextColumn get label => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get defaultValue => text().nullable()();
  TextColumn get exampleValue => text().nullable()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ContextPacks extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get content => text()();
  TextColumn get packType => text().nullable()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptContextPackLinks extends Table {
  TextColumn get promptId => text()();
  TextColumn get contextPackId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {promptId, contextPackId};
}

class Tags extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get colorHex => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptTags extends Table {
  TextColumn get promptId => text()();
  TextColumn get tagId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {promptId, tagId};
}

class Collections extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptCollectionLinks extends Table {
  TextColumn get promptId => text()();
  TextColumn get collectionId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {promptId, collectionId};
}

class InboxItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text().nullable()();
  TextColumn get rawText => text()();
  TextColumn get source => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get convertedPromptId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LLMProviders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get company => text().nullable()();
  TextColumn get accentColorHex => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LLMModels extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get name => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LLMOutputAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get outputId => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get localPath => text()();
  TextColumn get attachmentType => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptExamples extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().nullable()();
  TextColumn get promptId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get compiledPrompt => text()();
  TextColumn get contextPackId => text().nullable()();
  TextColumn get variableValuesJson => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get refinementNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class PromptExampleOutputs extends Table {
  TextColumn get id => text()();
  TextColumn get exampleId => text()();
  TextColumn get providerId => text().nullable()();
  TextColumn get modelId => text().nullable()();
  TextColumn get providerName => text()();
  TextColumn get modelName => text().nullable()();
  TextColumn get outputType => text().withDefault(const Constant('text'))();
  TextColumn get outputText => text()();
  IntColumn get score => integer().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isBest => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
