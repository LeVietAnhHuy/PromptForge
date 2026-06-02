// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PromptsTable extends Prompts with TableInfo<$PromptsTable, Prompt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptTypeMeta =
      const VerificationMeta('promptType');
  @override
  late final GeneratedColumn<String> promptType = GeneratedColumn<String>(
      'prompt_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outputFormatMeta =
      const VerificationMeta('outputFormat');
  @override
  late final GeneratedColumn<String> outputFormat = GeneratedColumn<String>(
      'output_format', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetNotesMeta =
      const VerificationMeta('targetNotes');
  @override
  late final GeneratedColumn<String> targetNotes = GeneratedColumn<String>(
      'target_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
      'last_used_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        purpose,
        body,
        promptType,
        outputFormat,
        targetNotes,
        isArchived,
        isFavorite,
        usageCount,
        lastUsedAt,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompts';
  @override
  VerificationContext validateIntegrity(Insertable<Prompt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('prompt_type')) {
      context.handle(
          _promptTypeMeta,
          promptType.isAcceptableOrUnknown(
              data['prompt_type']!, _promptTypeMeta));
    }
    if (data.containsKey('output_format')) {
      context.handle(
          _outputFormatMeta,
          outputFormat.isAcceptableOrUnknown(
              data['output_format']!, _outputFormatMeta));
    }
    if (data.containsKey('target_notes')) {
      context.handle(
          _targetNotesMeta,
          targetNotes.isAcceptableOrUnknown(
              data['target_notes']!, _targetNotesMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prompt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prompt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose']),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      promptType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_type']),
      outputFormat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}output_format']),
      targetNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_notes']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PromptsTable createAlias(String alias) {
    return $PromptsTable(attachedDatabase, alias);
  }
}

class Prompt extends DataClass implements Insertable<Prompt> {
  final String id;
  final String title;
  final String? purpose;
  final String body;
  final String? promptType;
  final String? outputFormat;
  final String? targetNotes;
  final bool isArchived;
  final bool isFavorite;
  final int usageCount;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Prompt(
      {required this.id,
      required this.title,
      this.purpose,
      required this.body,
      this.promptType,
      this.outputFormat,
      this.targetNotes,
      required this.isArchived,
      required this.isFavorite,
      required this.usageCount,
      this.lastUsedAt,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || promptType != null) {
      map['prompt_type'] = Variable<String>(promptType);
    }
    if (!nullToAbsent || outputFormat != null) {
      map['output_format'] = Variable<String>(outputFormat);
    }
    if (!nullToAbsent || targetNotes != null) {
      map['target_notes'] = Variable<String>(targetNotes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PromptsCompanion toCompanion(bool nullToAbsent) {
    return PromptsCompanion(
      id: Value(id),
      title: Value(title),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      body: Value(body),
      promptType: promptType == null && nullToAbsent
          ? const Value.absent()
          : Value(promptType),
      outputFormat: outputFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(outputFormat),
      targetNotes: targetNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(targetNotes),
      isArchived: Value(isArchived),
      isFavorite: Value(isFavorite),
      usageCount: Value(usageCount),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Prompt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prompt(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      body: serializer.fromJson<String>(json['body']),
      promptType: serializer.fromJson<String?>(json['promptType']),
      outputFormat: serializer.fromJson<String?>(json['outputFormat']),
      targetNotes: serializer.fromJson<String?>(json['targetNotes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'purpose': serializer.toJson<String?>(purpose),
      'body': serializer.toJson<String>(body),
      'promptType': serializer.toJson<String?>(promptType),
      'outputFormat': serializer.toJson<String?>(outputFormat),
      'targetNotes': serializer.toJson<String?>(targetNotes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Prompt copyWith(
          {String? id,
          String? title,
          Value<String?> purpose = const Value.absent(),
          String? body,
          Value<String?> promptType = const Value.absent(),
          Value<String?> outputFormat = const Value.absent(),
          Value<String?> targetNotes = const Value.absent(),
          bool? isArchived,
          bool? isFavorite,
          int? usageCount,
          Value<DateTime?> lastUsedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Prompt(
        id: id ?? this.id,
        title: title ?? this.title,
        purpose: purpose.present ? purpose.value : this.purpose,
        body: body ?? this.body,
        promptType: promptType.present ? promptType.value : this.promptType,
        outputFormat:
            outputFormat.present ? outputFormat.value : this.outputFormat,
        targetNotes: targetNotes.present ? targetNotes.value : this.targetNotes,
        isArchived: isArchived ?? this.isArchived,
        isFavorite: isFavorite ?? this.isFavorite,
        usageCount: usageCount ?? this.usageCount,
        lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Prompt copyWithCompanion(PromptsCompanion data) {
    return Prompt(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      body: data.body.present ? data.body.value : this.body,
      promptType:
          data.promptType.present ? data.promptType.value : this.promptType,
      outputFormat: data.outputFormat.present
          ? data.outputFormat.value
          : this.outputFormat,
      targetNotes:
          data.targetNotes.present ? data.targetNotes.value : this.targetNotes,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prompt(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('purpose: $purpose, ')
          ..write('body: $body, ')
          ..write('promptType: $promptType, ')
          ..write('outputFormat: $outputFormat, ')
          ..write('targetNotes: $targetNotes, ')
          ..write('isArchived: $isArchived, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      purpose,
      body,
      promptType,
      outputFormat,
      targetNotes,
      isArchived,
      isFavorite,
      usageCount,
      lastUsedAt,
      createdAt,
      updatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prompt &&
          other.id == this.id &&
          other.title == this.title &&
          other.purpose == this.purpose &&
          other.body == this.body &&
          other.promptType == this.promptType &&
          other.outputFormat == this.outputFormat &&
          other.targetNotes == this.targetNotes &&
          other.isArchived == this.isArchived &&
          other.isFavorite == this.isFavorite &&
          other.usageCount == this.usageCount &&
          other.lastUsedAt == this.lastUsedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PromptsCompanion extends UpdateCompanion<Prompt> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> purpose;
  final Value<String> body;
  final Value<String?> promptType;
  final Value<String?> outputFormat;
  final Value<String?> targetNotes;
  final Value<bool> isArchived;
  final Value<bool> isFavorite;
  final Value<int> usageCount;
  final Value<DateTime?> lastUsedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PromptsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.purpose = const Value.absent(),
    this.body = const Value.absent(),
    this.promptType = const Value.absent(),
    this.outputFormat = const Value.absent(),
    this.targetNotes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptsCompanion.insert({
    required String id,
    required String title,
    this.purpose = const Value.absent(),
    required String body,
    this.promptType = const Value.absent(),
    this.outputFormat = const Value.absent(),
    this.targetNotes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        body = Value(body),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Prompt> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? purpose,
    Expression<String>? body,
    Expression<String>? promptType,
    Expression<String>? outputFormat,
    Expression<String>? targetNotes,
    Expression<bool>? isArchived,
    Expression<bool>? isFavorite,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (purpose != null) 'purpose': purpose,
      if (body != null) 'body': body,
      if (promptType != null) 'prompt_type': promptType,
      if (outputFormat != null) 'output_format': outputFormat,
      if (targetNotes != null) 'target_notes': targetNotes,
      if (isArchived != null) 'is_archived': isArchived,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? purpose,
      Value<String>? body,
      Value<String?>? promptType,
      Value<String?>? outputFormat,
      Value<String?>? targetNotes,
      Value<bool>? isArchived,
      Value<bool>? isFavorite,
      Value<int>? usageCount,
      Value<DateTime?>? lastUsedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return PromptsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      body: body ?? this.body,
      promptType: promptType ?? this.promptType,
      outputFormat: outputFormat ?? this.outputFormat,
      targetNotes: targetNotes ?? this.targetNotes,
      isArchived: isArchived ?? this.isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (promptType.present) {
      map['prompt_type'] = Variable<String>(promptType.value);
    }
    if (outputFormat.present) {
      map['output_format'] = Variable<String>(outputFormat.value);
    }
    if (targetNotes.present) {
      map['target_notes'] = Variable<String>(targetNotes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('purpose: $purpose, ')
          ..write('body: $body, ')
          ..write('promptType: $promptType, ')
          ..write('outputFormat: $outputFormat, ')
          ..write('targetNotes: $targetNotes, ')
          ..write('isArchived: $isArchived, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptVersionsTable extends PromptVersions
    with TableInfo<$PromptVersionsTable, PromptVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variableMetadataJsonMeta =
      const VerificationMeta('variableMetadataJson');
  @override
  late final GeneratedColumn<String> variableMetadataJson =
      GeneratedColumn<String>('variable_metadata_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        promptId,
        title,
        body,
        tagsJson,
        variableMetadataJson,
        note,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_versions';
  @override
  VerificationContext validateIntegrity(Insertable<PromptVersion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('variable_metadata_json')) {
      context.handle(
          _variableMetadataJsonMeta,
          variableMetadataJson.isAcceptableOrUnknown(
              data['variable_metadata_json']!, _variableMetadataJsonMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromptVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptVersion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json']),
      variableMetadataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}variable_metadata_json']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PromptVersionsTable createAlias(String alias) {
    return $PromptVersionsTable(attachedDatabase, alias);
  }
}

class PromptVersion extends DataClass implements Insertable<PromptVersion> {
  final String id;
  final String promptId;
  final String title;
  final String body;
  final String? tagsJson;
  final String? variableMetadataJson;
  final String? note;
  final DateTime createdAt;
  const PromptVersion(
      {required this.id,
      required this.promptId,
      required this.title,
      required this.body,
      this.tagsJson,
      this.variableMetadataJson,
      this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['prompt_id'] = Variable<String>(promptId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || tagsJson != null) {
      map['tags_json'] = Variable<String>(tagsJson);
    }
    if (!nullToAbsent || variableMetadataJson != null) {
      map['variable_metadata_json'] = Variable<String>(variableMetadataJson);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PromptVersionsCompanion toCompanion(bool nullToAbsent) {
    return PromptVersionsCompanion(
      id: Value(id),
      promptId: Value(promptId),
      title: Value(title),
      body: Value(body),
      tagsJson: tagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsJson),
      variableMetadataJson: variableMetadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(variableMetadataJson),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory PromptVersion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptVersion(
      id: serializer.fromJson<String>(json['id']),
      promptId: serializer.fromJson<String>(json['promptId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      tagsJson: serializer.fromJson<String?>(json['tagsJson']),
      variableMetadataJson:
          serializer.fromJson<String?>(json['variableMetadataJson']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'promptId': serializer.toJson<String>(promptId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'tagsJson': serializer.toJson<String?>(tagsJson),
      'variableMetadataJson': serializer.toJson<String?>(variableMetadataJson),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PromptVersion copyWith(
          {String? id,
          String? promptId,
          String? title,
          String? body,
          Value<String?> tagsJson = const Value.absent(),
          Value<String?> variableMetadataJson = const Value.absent(),
          Value<String?> note = const Value.absent(),
          DateTime? createdAt}) =>
      PromptVersion(
        id: id ?? this.id,
        promptId: promptId ?? this.promptId,
        title: title ?? this.title,
        body: body ?? this.body,
        tagsJson: tagsJson.present ? tagsJson.value : this.tagsJson,
        variableMetadataJson: variableMetadataJson.present
            ? variableMetadataJson.value
            : this.variableMetadataJson,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  PromptVersion copyWithCompanion(PromptVersionsCompanion data) {
    return PromptVersion(
      id: data.id.present ? data.id.value : this.id,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      variableMetadataJson: data.variableMetadataJson.present
          ? data.variableMetadataJson.value
          : this.variableMetadataJson,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptVersion(')
          ..write('id: $id, ')
          ..write('promptId: $promptId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('variableMetadataJson: $variableMetadataJson, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, promptId, title, body, tagsJson,
      variableMetadataJson, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptVersion &&
          other.id == this.id &&
          other.promptId == this.promptId &&
          other.title == this.title &&
          other.body == this.body &&
          other.tagsJson == this.tagsJson &&
          other.variableMetadataJson == this.variableMetadataJson &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class PromptVersionsCompanion extends UpdateCompanion<PromptVersion> {
  final Value<String> id;
  final Value<String> promptId;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> tagsJson;
  final Value<String?> variableMetadataJson;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PromptVersionsCompanion({
    this.id = const Value.absent(),
    this.promptId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.variableMetadataJson = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptVersionsCompanion.insert({
    required String id,
    required String promptId,
    required String title,
    required String body,
    this.tagsJson = const Value.absent(),
    this.variableMetadataJson = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        promptId = Value(promptId),
        title = Value(title),
        body = Value(body),
        createdAt = Value(createdAt);
  static Insertable<PromptVersion> custom({
    Expression<String>? id,
    Expression<String>? promptId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? tagsJson,
    Expression<String>? variableMetadataJson,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (promptId != null) 'prompt_id': promptId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (variableMetadataJson != null)
        'variable_metadata_json': variableMetadataJson,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptVersionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? promptId,
      Value<String>? title,
      Value<String>? body,
      Value<String?>? tagsJson,
      Value<String?>? variableMetadataJson,
      Value<String?>? note,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PromptVersionsCompanion(
      id: id ?? this.id,
      promptId: promptId ?? this.promptId,
      title: title ?? this.title,
      body: body ?? this.body,
      tagsJson: tagsJson ?? this.tagsJson,
      variableMetadataJson: variableMetadataJson ?? this.variableMetadataJson,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (variableMetadataJson.present) {
      map['variable_metadata_json'] =
          Variable<String>(variableMetadataJson.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptVersionsCompanion(')
          ..write('id: $id, ')
          ..write('promptId: $promptId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('variableMetadataJson: $variableMetadataJson, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptVariablesTable extends PromptVariables
    with TableInfo<$PromptVariablesTable, PromptVariable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptVariablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultValueMeta =
      const VerificationMeta('defaultValue');
  @override
  late final GeneratedColumn<String> defaultValue = GeneratedColumn<String>(
      'default_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exampleValueMeta =
      const VerificationMeta('exampleValue');
  @override
  late final GeneratedColumn<String> exampleValue = GeneratedColumn<String>(
      'example_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRequiredMeta =
      const VerificationMeta('isRequired');
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
      'is_required', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_required" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        promptId,
        name,
        label,
        description,
        defaultValue,
        exampleValue,
        isRequired,
        sortOrder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_variables';
  @override
  VerificationContext validateIntegrity(Insertable<PromptVariable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('default_value')) {
      context.handle(
          _defaultValueMeta,
          defaultValue.isAcceptableOrUnknown(
              data['default_value']!, _defaultValueMeta));
    }
    if (data.containsKey('example_value')) {
      context.handle(
          _exampleValueMeta,
          exampleValue.isAcceptableOrUnknown(
              data['example_value']!, _exampleValueMeta));
    }
    if (data.containsKey('is_required')) {
      context.handle(
          _isRequiredMeta,
          isRequired.isAcceptableOrUnknown(
              data['is_required']!, _isRequiredMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromptVariable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptVariable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      defaultValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_value']),
      exampleValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}example_value']),
      isRequired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_required'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PromptVariablesTable createAlias(String alias) {
    return $PromptVariablesTable(attachedDatabase, alias);
  }
}

class PromptVariable extends DataClass implements Insertable<PromptVariable> {
  final String id;
  final String promptId;
  final String name;
  final String? label;
  final String? description;
  final String? defaultValue;
  final String? exampleValue;
  final bool isRequired;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PromptVariable(
      {required this.id,
      required this.promptId,
      required this.name,
      this.label,
      this.description,
      this.defaultValue,
      this.exampleValue,
      required this.isRequired,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['prompt_id'] = Variable<String>(promptId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || defaultValue != null) {
      map['default_value'] = Variable<String>(defaultValue);
    }
    if (!nullToAbsent || exampleValue != null) {
      map['example_value'] = Variable<String>(exampleValue);
    }
    map['is_required'] = Variable<bool>(isRequired);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PromptVariablesCompanion toCompanion(bool nullToAbsent) {
    return PromptVariablesCompanion(
      id: Value(id),
      promptId: Value(promptId),
      name: Value(name),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      defaultValue: defaultValue == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultValue),
      exampleValue: exampleValue == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleValue),
      isRequired: Value(isRequired),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PromptVariable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptVariable(
      id: serializer.fromJson<String>(json['id']),
      promptId: serializer.fromJson<String>(json['promptId']),
      name: serializer.fromJson<String>(json['name']),
      label: serializer.fromJson<String?>(json['label']),
      description: serializer.fromJson<String?>(json['description']),
      defaultValue: serializer.fromJson<String?>(json['defaultValue']),
      exampleValue: serializer.fromJson<String?>(json['exampleValue']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'promptId': serializer.toJson<String>(promptId),
      'name': serializer.toJson<String>(name),
      'label': serializer.toJson<String?>(label),
      'description': serializer.toJson<String?>(description),
      'defaultValue': serializer.toJson<String?>(defaultValue),
      'exampleValue': serializer.toJson<String?>(exampleValue),
      'isRequired': serializer.toJson<bool>(isRequired),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PromptVariable copyWith(
          {String? id,
          String? promptId,
          String? name,
          Value<String?> label = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> defaultValue = const Value.absent(),
          Value<String?> exampleValue = const Value.absent(),
          bool? isRequired,
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PromptVariable(
        id: id ?? this.id,
        promptId: promptId ?? this.promptId,
        name: name ?? this.name,
        label: label.present ? label.value : this.label,
        description: description.present ? description.value : this.description,
        defaultValue:
            defaultValue.present ? defaultValue.value : this.defaultValue,
        exampleValue:
            exampleValue.present ? exampleValue.value : this.exampleValue,
        isRequired: isRequired ?? this.isRequired,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PromptVariable copyWithCompanion(PromptVariablesCompanion data) {
    return PromptVariable(
      id: data.id.present ? data.id.value : this.id,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      name: data.name.present ? data.name.value : this.name,
      label: data.label.present ? data.label.value : this.label,
      description:
          data.description.present ? data.description.value : this.description,
      defaultValue: data.defaultValue.present
          ? data.defaultValue.value
          : this.defaultValue,
      exampleValue: data.exampleValue.present
          ? data.exampleValue.value
          : this.exampleValue,
      isRequired:
          data.isRequired.present ? data.isRequired.value : this.isRequired,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptVariable(')
          ..write('id: $id, ')
          ..write('promptId: $promptId, ')
          ..write('name: $name, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('defaultValue: $defaultValue, ')
          ..write('exampleValue: $exampleValue, ')
          ..write('isRequired: $isRequired, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, promptId, name, label, description,
      defaultValue, exampleValue, isRequired, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptVariable &&
          other.id == this.id &&
          other.promptId == this.promptId &&
          other.name == this.name &&
          other.label == this.label &&
          other.description == this.description &&
          other.defaultValue == this.defaultValue &&
          other.exampleValue == this.exampleValue &&
          other.isRequired == this.isRequired &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PromptVariablesCompanion extends UpdateCompanion<PromptVariable> {
  final Value<String> id;
  final Value<String> promptId;
  final Value<String> name;
  final Value<String?> label;
  final Value<String?> description;
  final Value<String?> defaultValue;
  final Value<String?> exampleValue;
  final Value<bool> isRequired;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PromptVariablesCompanion({
    this.id = const Value.absent(),
    this.promptId = const Value.absent(),
    this.name = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.defaultValue = const Value.absent(),
    this.exampleValue = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptVariablesCompanion.insert({
    required String id,
    required String promptId,
    required String name,
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.defaultValue = const Value.absent(),
    this.exampleValue = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        promptId = Value(promptId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PromptVariable> custom({
    Expression<String>? id,
    Expression<String>? promptId,
    Expression<String>? name,
    Expression<String>? label,
    Expression<String>? description,
    Expression<String>? defaultValue,
    Expression<String>? exampleValue,
    Expression<bool>? isRequired,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (promptId != null) 'prompt_id': promptId,
      if (name != null) 'name': name,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (defaultValue != null) 'default_value': defaultValue,
      if (exampleValue != null) 'example_value': exampleValue,
      if (isRequired != null) 'is_required': isRequired,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptVariablesCompanion copyWith(
      {Value<String>? id,
      Value<String>? promptId,
      Value<String>? name,
      Value<String?>? label,
      Value<String?>? description,
      Value<String?>? defaultValue,
      Value<String?>? exampleValue,
      Value<bool>? isRequired,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PromptVariablesCompanion(
      id: id ?? this.id,
      promptId: promptId ?? this.promptId,
      name: name ?? this.name,
      label: label ?? this.label,
      description: description ?? this.description,
      defaultValue: defaultValue ?? this.defaultValue,
      exampleValue: exampleValue ?? this.exampleValue,
      isRequired: isRequired ?? this.isRequired,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (defaultValue.present) {
      map['default_value'] = Variable<String>(defaultValue.value);
    }
    if (exampleValue.present) {
      map['example_value'] = Variable<String>(exampleValue.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptVariablesCompanion(')
          ..write('id: $id, ')
          ..write('promptId: $promptId, ')
          ..write('name: $name, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('defaultValue: $defaultValue, ')
          ..write('exampleValue: $exampleValue, ')
          ..write('isRequired: $isRequired, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextPacksTable extends ContextPacks
    with TableInfo<$ContextPacksTable, ContextPack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextPacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packTypeMeta =
      const VerificationMeta('packType');
  @override
  late final GeneratedColumn<String> packType = GeneratedColumn<String>(
      'pack_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBuiltinMeta =
      const VerificationMeta('isBuiltin');
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
      'is_builtin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_builtin" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        content,
        packType,
        isBuiltin,
        sortOrder,
        isArchived,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'context_packs';
  @override
  VerificationContext validateIntegrity(Insertable<ContextPack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('pack_type')) {
      context.handle(_packTypeMeta,
          packType.isAcceptableOrUnknown(data['pack_type']!, _packTypeMeta));
    }
    if (data.containsKey('is_builtin')) {
      context.handle(_isBuiltinMeta,
          isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContextPack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextPack(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      packType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pack_type']),
      isBuiltin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_builtin'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ContextPacksTable createAlias(String alias) {
    return $ContextPacksTable(attachedDatabase, alias);
  }
}

class ContextPack extends DataClass implements Insertable<ContextPack> {
  final String id;
  final String name;
  final String? description;
  final String content;
  final String? packType;
  final bool isBuiltin;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ContextPack(
      {required this.id,
      required this.name,
      this.description,
      required this.content,
      this.packType,
      required this.isBuiltin,
      required this.sortOrder,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || packType != null) {
      map['pack_type'] = Variable<String>(packType);
    }
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ContextPacksCompanion toCompanion(bool nullToAbsent) {
    return ContextPacksCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      content: Value(content),
      packType: packType == null && nullToAbsent
          ? const Value.absent()
          : Value(packType),
      isBuiltin: Value(isBuiltin),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ContextPack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextPack(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      content: serializer.fromJson<String>(json['content']),
      packType: serializer.fromJson<String?>(json['packType']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'content': serializer.toJson<String>(content),
      'packType': serializer.toJson<String?>(packType),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ContextPack copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? content,
          Value<String?> packType = const Value.absent(),
          bool? isBuiltin,
          int? sortOrder,
          bool? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      ContextPack(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        content: content ?? this.content,
        packType: packType.present ? packType.value : this.packType,
        isBuiltin: isBuiltin ?? this.isBuiltin,
        sortOrder: sortOrder ?? this.sortOrder,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  ContextPack copyWithCompanion(ContextPacksCompanion data) {
    return ContextPack(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      content: data.content.present ? data.content.value : this.content,
      packType: data.packType.present ? data.packType.value : this.packType,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextPack(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('packType: $packType, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, content, packType,
      isBuiltin, sortOrder, isArchived, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextPack &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.content == this.content &&
          other.packType == this.packType &&
          other.isBuiltin == this.isBuiltin &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ContextPacksCompanion extends UpdateCompanion<ContextPack> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> content;
  final Value<String?> packType;
  final Value<bool> isBuiltin;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ContextPacksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.content = const Value.absent(),
    this.packType = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContextPacksCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String content,
    this.packType = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        content = Value(content),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ContextPack> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? content,
    Expression<String>? packType,
    Expression<bool>? isBuiltin,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (packType != null) 'pack_type': packType,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContextPacksCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? content,
      Value<String?>? packType,
      Value<bool>? isBuiltin,
      Value<int>? sortOrder,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return ContextPacksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      content: content ?? this.content,
      packType: packType ?? this.packType,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (packType.present) {
      map['pack_type'] = Variable<String>(packType.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextPacksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('packType: $packType, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptContextPackLinksTable extends PromptContextPackLinks
    with TableInfo<$PromptContextPackLinksTable, PromptContextPackLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptContextPackLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextPackIdMeta =
      const VerificationMeta('contextPackId');
  @override
  late final GeneratedColumn<String> contextPackId = GeneratedColumn<String>(
      'context_pack_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [promptId, contextPackId, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_context_pack_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<PromptContextPackLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('context_pack_id')) {
      context.handle(
          _contextPackIdMeta,
          contextPackId.isAcceptableOrUnknown(
              data['context_pack_id']!, _contextPackIdMeta));
    } else if (isInserting) {
      context.missing(_contextPackIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {promptId, contextPackId};
  @override
  PromptContextPackLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptContextPackLink(
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      contextPackId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}context_pack_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PromptContextPackLinksTable createAlias(String alias) {
    return $PromptContextPackLinksTable(attachedDatabase, alias);
  }
}

class PromptContextPackLink extends DataClass
    implements Insertable<PromptContextPackLink> {
  final String promptId;
  final String contextPackId;
  final int sortOrder;
  final DateTime createdAt;
  const PromptContextPackLink(
      {required this.promptId,
      required this.contextPackId,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prompt_id'] = Variable<String>(promptId);
    map['context_pack_id'] = Variable<String>(contextPackId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PromptContextPackLinksCompanion toCompanion(bool nullToAbsent) {
    return PromptContextPackLinksCompanion(
      promptId: Value(promptId),
      contextPackId: Value(contextPackId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory PromptContextPackLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptContextPackLink(
      promptId: serializer.fromJson<String>(json['promptId']),
      contextPackId: serializer.fromJson<String>(json['contextPackId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'promptId': serializer.toJson<String>(promptId),
      'contextPackId': serializer.toJson<String>(contextPackId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PromptContextPackLink copyWith(
          {String? promptId,
          String? contextPackId,
          int? sortOrder,
          DateTime? createdAt}) =>
      PromptContextPackLink(
        promptId: promptId ?? this.promptId,
        contextPackId: contextPackId ?? this.contextPackId,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  PromptContextPackLink copyWithCompanion(
      PromptContextPackLinksCompanion data) {
    return PromptContextPackLink(
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      contextPackId: data.contextPackId.present
          ? data.contextPackId.value
          : this.contextPackId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptContextPackLink(')
          ..write('promptId: $promptId, ')
          ..write('contextPackId: $contextPackId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(promptId, contextPackId, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptContextPackLink &&
          other.promptId == this.promptId &&
          other.contextPackId == this.contextPackId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class PromptContextPackLinksCompanion
    extends UpdateCompanion<PromptContextPackLink> {
  final Value<String> promptId;
  final Value<String> contextPackId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PromptContextPackLinksCompanion({
    this.promptId = const Value.absent(),
    this.contextPackId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptContextPackLinksCompanion.insert({
    required String promptId,
    required String contextPackId,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : promptId = Value(promptId),
        contextPackId = Value(contextPackId),
        createdAt = Value(createdAt);
  static Insertable<PromptContextPackLink> custom({
    Expression<String>? promptId,
    Expression<String>? contextPackId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (promptId != null) 'prompt_id': promptId,
      if (contextPackId != null) 'context_pack_id': contextPackId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptContextPackLinksCompanion copyWith(
      {Value<String>? promptId,
      Value<String>? contextPackId,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PromptContextPackLinksCompanion(
      promptId: promptId ?? this.promptId,
      contextPackId: contextPackId ?? this.contextPackId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (contextPackId.present) {
      map['context_pack_id'] = Variable<String>(contextPackId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptContextPackLinksCompanion(')
          ..write('promptId: $promptId, ')
          ..write('contextPackId: $contextPackId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, colorHex, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String? colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag(
      {required this.id,
      required this.name,
      this.colorHex,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String?>(colorHex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith(
          {String? id,
          String? name,
          Value<String?> colorHex = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        colorHex: colorHex.present ? colorHex.value : this.colorHex,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> colorHex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.colorHex = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? colorHex,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptTagsTable extends PromptTags
    with TableInfo<$PromptTagsTable, PromptTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [promptId, tagId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_tags';
  @override
  VerificationContext validateIntegrity(Insertable<PromptTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {promptId, tagId};
  @override
  PromptTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptTag(
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PromptTagsTable createAlias(String alias) {
    return $PromptTagsTable(attachedDatabase, alias);
  }
}

class PromptTag extends DataClass implements Insertable<PromptTag> {
  final String promptId;
  final String tagId;
  final DateTime createdAt;
  const PromptTag(
      {required this.promptId, required this.tagId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prompt_id'] = Variable<String>(promptId);
    map['tag_id'] = Variable<String>(tagId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PromptTagsCompanion toCompanion(bool nullToAbsent) {
    return PromptTagsCompanion(
      promptId: Value(promptId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
    );
  }

  factory PromptTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptTag(
      promptId: serializer.fromJson<String>(json['promptId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'promptId': serializer.toJson<String>(promptId),
      'tagId': serializer.toJson<String>(tagId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PromptTag copyWith({String? promptId, String? tagId, DateTime? createdAt}) =>
      PromptTag(
        promptId: promptId ?? this.promptId,
        tagId: tagId ?? this.tagId,
        createdAt: createdAt ?? this.createdAt,
      );
  PromptTag copyWithCompanion(PromptTagsCompanion data) {
    return PromptTag(
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptTag(')
          ..write('promptId: $promptId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(promptId, tagId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptTag &&
          other.promptId == this.promptId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt);
}

class PromptTagsCompanion extends UpdateCompanion<PromptTag> {
  final Value<String> promptId;
  final Value<String> tagId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PromptTagsCompanion({
    this.promptId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptTagsCompanion.insert({
    required String promptId,
    required String tagId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : promptId = Value(promptId),
        tagId = Value(tagId),
        createdAt = Value(createdAt);
  static Insertable<PromptTag> custom({
    Expression<String>? promptId,
    Expression<String>? tagId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (promptId != null) 'prompt_id': promptId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptTagsCompanion copyWith(
      {Value<String>? promptId,
      Value<String>? tagId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PromptTagsCompanion(
      promptId: promptId ?? this.promptId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptTagsCompanion(')
          ..write('promptId: $promptId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, sortOrder, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(Insertable<Collection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Collection(
      {required this.id,
      required this.name,
      this.description,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Collection copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Collection(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, description, sortOrder, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptCollectionLinksTable extends PromptCollectionLinks
    with TableInfo<$PromptCollectionLinksTable, PromptCollectionLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptCollectionLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
      'collection_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [promptId, collectionId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_collection_links';
  @override
  VerificationContext validateIntegrity(
      Insertable<PromptCollectionLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {promptId, collectionId};
  @override
  PromptCollectionLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptCollectionLink(
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PromptCollectionLinksTable createAlias(String alias) {
    return $PromptCollectionLinksTable(attachedDatabase, alias);
  }
}

class PromptCollectionLink extends DataClass
    implements Insertable<PromptCollectionLink> {
  final String promptId;
  final String collectionId;
  final DateTime createdAt;
  const PromptCollectionLink(
      {required this.promptId,
      required this.collectionId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prompt_id'] = Variable<String>(promptId);
    map['collection_id'] = Variable<String>(collectionId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PromptCollectionLinksCompanion toCompanion(bool nullToAbsent) {
    return PromptCollectionLinksCompanion(
      promptId: Value(promptId),
      collectionId: Value(collectionId),
      createdAt: Value(createdAt),
    );
  }

  factory PromptCollectionLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptCollectionLink(
      promptId: serializer.fromJson<String>(json['promptId']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'promptId': serializer.toJson<String>(promptId),
      'collectionId': serializer.toJson<String>(collectionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PromptCollectionLink copyWith(
          {String? promptId, String? collectionId, DateTime? createdAt}) =>
      PromptCollectionLink(
        promptId: promptId ?? this.promptId,
        collectionId: collectionId ?? this.collectionId,
        createdAt: createdAt ?? this.createdAt,
      );
  PromptCollectionLink copyWithCompanion(PromptCollectionLinksCompanion data) {
    return PromptCollectionLink(
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptCollectionLink(')
          ..write('promptId: $promptId, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(promptId, collectionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptCollectionLink &&
          other.promptId == this.promptId &&
          other.collectionId == this.collectionId &&
          other.createdAt == this.createdAt);
}

class PromptCollectionLinksCompanion
    extends UpdateCompanion<PromptCollectionLink> {
  final Value<String> promptId;
  final Value<String> collectionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PromptCollectionLinksCompanion({
    this.promptId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptCollectionLinksCompanion.insert({
    required String promptId,
    required String collectionId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : promptId = Value(promptId),
        collectionId = Value(collectionId),
        createdAt = Value(createdAt);
  static Insertable<PromptCollectionLink> custom({
    Expression<String>? promptId,
    Expression<String>? collectionId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (promptId != null) 'prompt_id': promptId,
      if (collectionId != null) 'collection_id': collectionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptCollectionLinksCompanion copyWith(
      {Value<String>? promptId,
      Value<String>? collectionId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PromptCollectionLinksCompanion(
      promptId: promptId ?? this.promptId,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptCollectionLinksCompanion(')
          ..write('promptId: $promptId, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxItemsTable extends InboxItems
    with TableInfo<$InboxItemsTable, InboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  static const VerificationMeta _convertedPromptIdMeta =
      const VerificationMeta('convertedPromptId');
  @override
  late final GeneratedColumn<String> convertedPromptId =
      GeneratedColumn<String>('converted_prompt_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        rawText,
        source,
        status,
        convertedPromptId,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_items';
  @override
  VerificationContext validateIntegrity(Insertable<InboxItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('converted_prompt_id')) {
      context.handle(
          _convertedPromptIdMeta,
          convertedPromptId.isAcceptableOrUnknown(
              data['converted_prompt_id']!, _convertedPromptIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      convertedPromptId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}converted_prompt_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $InboxItemsTable createAlias(String alias) {
    return $InboxItemsTable(attachedDatabase, alias);
  }
}

class InboxItem extends DataClass implements Insertable<InboxItem> {
  final String id;
  final String? title;
  final String rawText;
  final String? source;
  final String status;
  final String? convertedPromptId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const InboxItem(
      {required this.id,
      this.title,
      required this.rawText,
      this.source,
      required this.status,
      this.convertedPromptId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['raw_text'] = Variable<String>(rawText);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || convertedPromptId != null) {
      map['converted_prompt_id'] = Variable<String>(convertedPromptId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InboxItemsCompanion toCompanion(bool nullToAbsent) {
    return InboxItemsCompanion(
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      rawText: Value(rawText),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      status: Value(status),
      convertedPromptId: convertedPromptId == null && nullToAbsent
          ? const Value.absent()
          : Value(convertedPromptId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InboxItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxItem(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      rawText: serializer.fromJson<String>(json['rawText']),
      source: serializer.fromJson<String?>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      convertedPromptId:
          serializer.fromJson<String?>(json['convertedPromptId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'rawText': serializer.toJson<String>(rawText),
      'source': serializer.toJson<String?>(source),
      'status': serializer.toJson<String>(status),
      'convertedPromptId': serializer.toJson<String?>(convertedPromptId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InboxItem copyWith(
          {String? id,
          Value<String?> title = const Value.absent(),
          String? rawText,
          Value<String?> source = const Value.absent(),
          String? status,
          Value<String?> convertedPromptId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      InboxItem(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        rawText: rawText ?? this.rawText,
        source: source.present ? source.value : this.source,
        status: status ?? this.status,
        convertedPromptId: convertedPromptId.present
            ? convertedPromptId.value
            : this.convertedPromptId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  InboxItem copyWithCompanion(InboxItemsCompanion data) {
    return InboxItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      convertedPromptId: data.convertedPromptId.present
          ? data.convertedPromptId.value
          : this.convertedPromptId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('rawText: $rawText, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('convertedPromptId: $convertedPromptId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, rawText, source, status,
      convertedPromptId, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.rawText == this.rawText &&
          other.source == this.source &&
          other.status == this.status &&
          other.convertedPromptId == this.convertedPromptId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InboxItemsCompanion extends UpdateCompanion<InboxItem> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String> rawText;
  final Value<String?> source;
  final Value<String> status;
  final Value<String?> convertedPromptId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InboxItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.rawText = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.convertedPromptId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InboxItemsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required String rawText,
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.convertedPromptId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rawText = Value(rawText),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<InboxItem> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? rawText,
    Expression<String>? source,
    Expression<String>? status,
    Expression<String>? convertedPromptId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (rawText != null) 'raw_text': rawText,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (convertedPromptId != null) 'converted_prompt_id': convertedPromptId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InboxItemsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? title,
      Value<String>? rawText,
      Value<String?>? source,
      Value<String>? status,
      Value<String?>? convertedPromptId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return InboxItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      rawText: rawText ?? this.rawText,
      source: source ?? this.source,
      status: status ?? this.status,
      convertedPromptId: convertedPromptId ?? this.convertedPromptId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (convertedPromptId.present) {
      map['converted_prompt_id'] = Variable<String>(convertedPromptId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('rawText: $rawText, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('convertedPromptId: $convertedPromptId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const UserSetting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      UserSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<UserSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptExamplesTable extends PromptExamples
    with TableInfo<$PromptExamplesTable, PromptExample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptExamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _compiledPromptMeta =
      const VerificationMeta('compiledPrompt');
  @override
  late final GeneratedColumn<String> compiledPrompt = GeneratedColumn<String>(
      'compiled_prompt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextPackIdMeta =
      const VerificationMeta('contextPackId');
  @override
  late final GeneratedColumn<String> contextPackId = GeneratedColumn<String>(
      'context_pack_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variableValuesJsonMeta =
      const VerificationMeta('variableValuesJson');
  @override
  late final GeneratedColumn<String> variableValuesJson =
      GeneratedColumn<String>('variable_values_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        promptId,
        title,
        compiledPrompt,
        contextPackId,
        variableValuesJson,
        notes,
        createdAt,
        updatedAt,
        isArchived
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_examples';
  @override
  VerificationContext validateIntegrity(Insertable<PromptExample> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('compiled_prompt')) {
      context.handle(
          _compiledPromptMeta,
          compiledPrompt.isAcceptableOrUnknown(
              data['compiled_prompt']!, _compiledPromptMeta));
    } else if (isInserting) {
      context.missing(_compiledPromptMeta);
    }
    if (data.containsKey('context_pack_id')) {
      context.handle(
          _contextPackIdMeta,
          contextPackId.isAcceptableOrUnknown(
              data['context_pack_id']!, _contextPackIdMeta));
    }
    if (data.containsKey('variable_values_json')) {
      context.handle(
          _variableValuesJsonMeta,
          variableValuesJson.isAcceptableOrUnknown(
              data['variable_values_json']!, _variableValuesJsonMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromptExample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptExample(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      compiledPrompt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}compiled_prompt'])!,
      contextPackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_pack_id']),
      variableValuesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}variable_values_json']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $PromptExamplesTable createAlias(String alias) {
    return $PromptExamplesTable(attachedDatabase, alias);
  }
}

class PromptExample extends DataClass implements Insertable<PromptExample> {
  final String id;
  final String promptId;
  final String title;
  final String compiledPrompt;
  final String? contextPackId;
  final String? variableValuesJson;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  const PromptExample(
      {required this.id,
      required this.promptId,
      required this.title,
      required this.compiledPrompt,
      this.contextPackId,
      this.variableValuesJson,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['prompt_id'] = Variable<String>(promptId);
    map['title'] = Variable<String>(title);
    map['compiled_prompt'] = Variable<String>(compiledPrompt);
    if (!nullToAbsent || contextPackId != null) {
      map['context_pack_id'] = Variable<String>(contextPackId);
    }
    if (!nullToAbsent || variableValuesJson != null) {
      map['variable_values_json'] = Variable<String>(variableValuesJson);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  PromptExamplesCompanion toCompanion(bool nullToAbsent) {
    return PromptExamplesCompanion(
      id: Value(id),
      promptId: Value(promptId),
      title: Value(title),
      compiledPrompt: Value(compiledPrompt),
      contextPackId: contextPackId == null && nullToAbsent
          ? const Value.absent()
          : Value(contextPackId),
      variableValuesJson: variableValuesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(variableValuesJson),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isArchived: Value(isArchived),
    );
  }

  factory PromptExample.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptExample(
      id: serializer.fromJson<String>(json['id']),
      promptId: serializer.fromJson<String>(json['promptId']),
      title: serializer.fromJson<String>(json['title']),
      compiledPrompt: serializer.fromJson<String>(json['compiledPrompt']),
      contextPackId: serializer.fromJson<String?>(json['contextPackId']),
      variableValuesJson:
          serializer.fromJson<String?>(json['variableValuesJson']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'promptId': serializer.toJson<String>(promptId),
      'title': serializer.toJson<String>(title),
      'compiledPrompt': serializer.toJson<String>(compiledPrompt),
      'contextPackId': serializer.toJson<String?>(contextPackId),
      'variableValuesJson': serializer.toJson<String?>(variableValuesJson),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  PromptExample copyWith(
          {String? id,
          String? promptId,
          String? title,
          String? compiledPrompt,
          Value<String?> contextPackId = const Value.absent(),
          Value<String?> variableValuesJson = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isArchived}) =>
      PromptExample(
        id: id ?? this.id,
        promptId: promptId ?? this.promptId,
        title: title ?? this.title,
        compiledPrompt: compiledPrompt ?? this.compiledPrompt,
        contextPackId:
            contextPackId.present ? contextPackId.value : this.contextPackId,
        variableValuesJson: variableValuesJson.present
            ? variableValuesJson.value
            : this.variableValuesJson,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isArchived: isArchived ?? this.isArchived,
      );
  PromptExample copyWithCompanion(PromptExamplesCompanion data) {
    return PromptExample(
      id: data.id.present ? data.id.value : this.id,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      title: data.title.present ? data.title.value : this.title,
      compiledPrompt: data.compiledPrompt.present
          ? data.compiledPrompt.value
          : this.compiledPrompt,
      contextPackId: data.contextPackId.present
          ? data.contextPackId.value
          : this.contextPackId,
      variableValuesJson: data.variableValuesJson.present
          ? data.variableValuesJson.value
          : this.variableValuesJson,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptExample(')
          ..write('id: $id, ')
          ..write('promptId: $promptId, ')
          ..write('title: $title, ')
          ..write('compiledPrompt: $compiledPrompt, ')
          ..write('contextPackId: $contextPackId, ')
          ..write('variableValuesJson: $variableValuesJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      promptId,
      title,
      compiledPrompt,
      contextPackId,
      variableValuesJson,
      notes,
      createdAt,
      updatedAt,
      isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptExample &&
          other.id == this.id &&
          other.promptId == this.promptId &&
          other.title == this.title &&
          other.compiledPrompt == this.compiledPrompt &&
          other.contextPackId == this.contextPackId &&
          other.variableValuesJson == this.variableValuesJson &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived);
}

class PromptExamplesCompanion extends UpdateCompanion<PromptExample> {
  final Value<String> id;
  final Value<String> promptId;
  final Value<String> title;
  final Value<String> compiledPrompt;
  final Value<String?> contextPackId;
  final Value<String?> variableValuesJson;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const PromptExamplesCompanion({
    this.id = const Value.absent(),
    this.promptId = const Value.absent(),
    this.title = const Value.absent(),
    this.compiledPrompt = const Value.absent(),
    this.contextPackId = const Value.absent(),
    this.variableValuesJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptExamplesCompanion.insert({
    required String id,
    required String promptId,
    required String title,
    required String compiledPrompt,
    this.contextPackId = const Value.absent(),
    this.variableValuesJson = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        promptId = Value(promptId),
        title = Value(title),
        compiledPrompt = Value(compiledPrompt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PromptExample> custom({
    Expression<String>? id,
    Expression<String>? promptId,
    Expression<String>? title,
    Expression<String>? compiledPrompt,
    Expression<String>? contextPackId,
    Expression<String>? variableValuesJson,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (promptId != null) 'prompt_id': promptId,
      if (title != null) 'title': title,
      if (compiledPrompt != null) 'compiled_prompt': compiledPrompt,
      if (contextPackId != null) 'context_pack_id': contextPackId,
      if (variableValuesJson != null)
        'variable_values_json': variableValuesJson,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptExamplesCompanion copyWith(
      {Value<String>? id,
      Value<String>? promptId,
      Value<String>? title,
      Value<String>? compiledPrompt,
      Value<String?>? contextPackId,
      Value<String?>? variableValuesJson,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isArchived,
      Value<int>? rowid}) {
    return PromptExamplesCompanion(
      id: id ?? this.id,
      promptId: promptId ?? this.promptId,
      title: title ?? this.title,
      compiledPrompt: compiledPrompt ?? this.compiledPrompt,
      contextPackId: contextPackId ?? this.contextPackId,
      variableValuesJson: variableValuesJson ?? this.variableValuesJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (compiledPrompt.present) {
      map['compiled_prompt'] = Variable<String>(compiledPrompt.value);
    }
    if (contextPackId.present) {
      map['context_pack_id'] = Variable<String>(contextPackId.value);
    }
    if (variableValuesJson.present) {
      map['variable_values_json'] = Variable<String>(variableValuesJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptExamplesCompanion(')
          ..write('id: $id, ')
          ..write('promptId: $promptId, ')
          ..write('title: $title, ')
          ..write('compiledPrompt: $compiledPrompt, ')
          ..write('contextPackId: $contextPackId, ')
          ..write('variableValuesJson: $variableValuesJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromptExampleOutputsTable extends PromptExampleOutputs
    with TableInfo<$PromptExampleOutputsTable, PromptExampleOutput> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromptExampleOutputsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exampleIdMeta =
      const VerificationMeta('exampleId');
  @override
  late final GeneratedColumn<String> exampleId = GeneratedColumn<String>(
      'example_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerNameMeta =
      const VerificationMeta('providerName');
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
      'provider_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outputTextMeta =
      const VerificationMeta('outputText');
  @override
  late final GeneratedColumn<String> outputText = GeneratedColumn<String>(
      'output_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBestMeta = const VerificationMeta('isBest');
  @override
  late final GeneratedColumn<bool> isBest = GeneratedColumn<bool>(
      'is_best', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_best" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        exampleId,
        providerName,
        modelName,
        outputText,
        score,
        notes,
        isBest,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prompt_example_outputs';
  @override
  VerificationContext validateIntegrity(
      Insertable<PromptExampleOutput> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('example_id')) {
      context.handle(_exampleIdMeta,
          exampleId.isAcceptableOrUnknown(data['example_id']!, _exampleIdMeta));
    } else if (isInserting) {
      context.missing(_exampleIdMeta);
    }
    if (data.containsKey('provider_name')) {
      context.handle(
          _providerNameMeta,
          providerName.isAcceptableOrUnknown(
              data['provider_name']!, _providerNameMeta));
    } else if (isInserting) {
      context.missing(_providerNameMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    }
    if (data.containsKey('output_text')) {
      context.handle(
          _outputTextMeta,
          outputText.isAcceptableOrUnknown(
              data['output_text']!, _outputTextMeta));
    } else if (isInserting) {
      context.missing(_outputTextMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_best')) {
      context.handle(_isBestMeta,
          isBest.isAcceptableOrUnknown(data['is_best']!, _isBestMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromptExampleOutput map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromptExampleOutput(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      exampleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}example_id'])!,
      providerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_name'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name']),
      outputText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}output_text'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isBest: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_best'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PromptExampleOutputsTable createAlias(String alias) {
    return $PromptExampleOutputsTable(attachedDatabase, alias);
  }
}

class PromptExampleOutput extends DataClass
    implements Insertable<PromptExampleOutput> {
  final String id;
  final String exampleId;
  final String providerName;
  final String? modelName;
  final String outputText;
  final int? score;
  final String? notes;
  final bool isBest;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PromptExampleOutput(
      {required this.id,
      required this.exampleId,
      required this.providerName,
      this.modelName,
      required this.outputText,
      this.score,
      this.notes,
      required this.isBest,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['example_id'] = Variable<String>(exampleId);
    map['provider_name'] = Variable<String>(providerName);
    if (!nullToAbsent || modelName != null) {
      map['model_name'] = Variable<String>(modelName);
    }
    map['output_text'] = Variable<String>(outputText);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_best'] = Variable<bool>(isBest);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PromptExampleOutputsCompanion toCompanion(bool nullToAbsent) {
    return PromptExampleOutputsCompanion(
      id: Value(id),
      exampleId: Value(exampleId),
      providerName: Value(providerName),
      modelName: modelName == null && nullToAbsent
          ? const Value.absent()
          : Value(modelName),
      outputText: Value(outputText),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isBest: Value(isBest),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PromptExampleOutput.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromptExampleOutput(
      id: serializer.fromJson<String>(json['id']),
      exampleId: serializer.fromJson<String>(json['exampleId']),
      providerName: serializer.fromJson<String>(json['providerName']),
      modelName: serializer.fromJson<String?>(json['modelName']),
      outputText: serializer.fromJson<String>(json['outputText']),
      score: serializer.fromJson<int?>(json['score']),
      notes: serializer.fromJson<String?>(json['notes']),
      isBest: serializer.fromJson<bool>(json['isBest']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exampleId': serializer.toJson<String>(exampleId),
      'providerName': serializer.toJson<String>(providerName),
      'modelName': serializer.toJson<String?>(modelName),
      'outputText': serializer.toJson<String>(outputText),
      'score': serializer.toJson<int?>(score),
      'notes': serializer.toJson<String?>(notes),
      'isBest': serializer.toJson<bool>(isBest),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PromptExampleOutput copyWith(
          {String? id,
          String? exampleId,
          String? providerName,
          Value<String?> modelName = const Value.absent(),
          String? outputText,
          Value<int?> score = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isBest,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PromptExampleOutput(
        id: id ?? this.id,
        exampleId: exampleId ?? this.exampleId,
        providerName: providerName ?? this.providerName,
        modelName: modelName.present ? modelName.value : this.modelName,
        outputText: outputText ?? this.outputText,
        score: score.present ? score.value : this.score,
        notes: notes.present ? notes.value : this.notes,
        isBest: isBest ?? this.isBest,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PromptExampleOutput copyWithCompanion(PromptExampleOutputsCompanion data) {
    return PromptExampleOutput(
      id: data.id.present ? data.id.value : this.id,
      exampleId: data.exampleId.present ? data.exampleId.value : this.exampleId,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      outputText:
          data.outputText.present ? data.outputText.value : this.outputText,
      score: data.score.present ? data.score.value : this.score,
      notes: data.notes.present ? data.notes.value : this.notes,
      isBest: data.isBest.present ? data.isBest.value : this.isBest,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromptExampleOutput(')
          ..write('id: $id, ')
          ..write('exampleId: $exampleId, ')
          ..write('providerName: $providerName, ')
          ..write('modelName: $modelName, ')
          ..write('outputText: $outputText, ')
          ..write('score: $score, ')
          ..write('notes: $notes, ')
          ..write('isBest: $isBest, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exampleId, providerName, modelName,
      outputText, score, notes, isBest, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromptExampleOutput &&
          other.id == this.id &&
          other.exampleId == this.exampleId &&
          other.providerName == this.providerName &&
          other.modelName == this.modelName &&
          other.outputText == this.outputText &&
          other.score == this.score &&
          other.notes == this.notes &&
          other.isBest == this.isBest &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PromptExampleOutputsCompanion
    extends UpdateCompanion<PromptExampleOutput> {
  final Value<String> id;
  final Value<String> exampleId;
  final Value<String> providerName;
  final Value<String?> modelName;
  final Value<String> outputText;
  final Value<int?> score;
  final Value<String?> notes;
  final Value<bool> isBest;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PromptExampleOutputsCompanion({
    this.id = const Value.absent(),
    this.exampleId = const Value.absent(),
    this.providerName = const Value.absent(),
    this.modelName = const Value.absent(),
    this.outputText = const Value.absent(),
    this.score = const Value.absent(),
    this.notes = const Value.absent(),
    this.isBest = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromptExampleOutputsCompanion.insert({
    required String id,
    required String exampleId,
    required String providerName,
    this.modelName = const Value.absent(),
    required String outputText,
    this.score = const Value.absent(),
    this.notes = const Value.absent(),
    this.isBest = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        exampleId = Value(exampleId),
        providerName = Value(providerName),
        outputText = Value(outputText),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PromptExampleOutput> custom({
    Expression<String>? id,
    Expression<String>? exampleId,
    Expression<String>? providerName,
    Expression<String>? modelName,
    Expression<String>? outputText,
    Expression<int>? score,
    Expression<String>? notes,
    Expression<bool>? isBest,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exampleId != null) 'example_id': exampleId,
      if (providerName != null) 'provider_name': providerName,
      if (modelName != null) 'model_name': modelName,
      if (outputText != null) 'output_text': outputText,
      if (score != null) 'score': score,
      if (notes != null) 'notes': notes,
      if (isBest != null) 'is_best': isBest,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromptExampleOutputsCompanion copyWith(
      {Value<String>? id,
      Value<String>? exampleId,
      Value<String>? providerName,
      Value<String?>? modelName,
      Value<String>? outputText,
      Value<int?>? score,
      Value<String?>? notes,
      Value<bool>? isBest,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PromptExampleOutputsCompanion(
      id: id ?? this.id,
      exampleId: exampleId ?? this.exampleId,
      providerName: providerName ?? this.providerName,
      modelName: modelName ?? this.modelName,
      outputText: outputText ?? this.outputText,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      isBest: isBest ?? this.isBest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exampleId.present) {
      map['example_id'] = Variable<String>(exampleId.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (outputText.present) {
      map['output_text'] = Variable<String>(outputText.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isBest.present) {
      map['is_best'] = Variable<bool>(isBest.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromptExampleOutputsCompanion(')
          ..write('id: $id, ')
          ..write('exampleId: $exampleId, ')
          ..write('providerName: $providerName, ')
          ..write('modelName: $modelName, ')
          ..write('outputText: $outputText, ')
          ..write('score: $score, ')
          ..write('notes: $notes, ')
          ..write('isBest: $isBest, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextPackVersionsTable extends ContextPackVersions
    with TableInfo<$ContextPackVersionsTable, ContextPackVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextPackVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextPackIdMeta =
      const VerificationMeta('contextPackId');
  @override
  late final GeneratedColumn<String> contextPackId = GeneratedColumn<String>(
      'context_pack_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, contextPackId, name, description, content, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'context_pack_versions';
  @override
  VerificationContext validateIntegrity(Insertable<ContextPackVersion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('context_pack_id')) {
      context.handle(
          _contextPackIdMeta,
          contextPackId.isAcceptableOrUnknown(
              data['context_pack_id']!, _contextPackIdMeta));
    } else if (isInserting) {
      context.missing(_contextPackIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContextPackVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextPackVersion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      contextPackId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}context_pack_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ContextPackVersionsTable createAlias(String alias) {
    return $ContextPackVersionsTable(attachedDatabase, alias);
  }
}

class ContextPackVersion extends DataClass
    implements Insertable<ContextPackVersion> {
  final String id;
  final String contextPackId;
  final String name;
  final String? description;
  final String content;
  final String? note;
  final DateTime createdAt;
  const ContextPackVersion(
      {required this.id,
      required this.contextPackId,
      required this.name,
      this.description,
      required this.content,
      this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['context_pack_id'] = Variable<String>(contextPackId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ContextPackVersionsCompanion toCompanion(bool nullToAbsent) {
    return ContextPackVersionsCompanion(
      id: Value(id),
      contextPackId: Value(contextPackId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      content: Value(content),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory ContextPackVersion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextPackVersion(
      id: serializer.fromJson<String>(json['id']),
      contextPackId: serializer.fromJson<String>(json['contextPackId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      content: serializer.fromJson<String>(json['content']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contextPackId': serializer.toJson<String>(contextPackId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'content': serializer.toJson<String>(content),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ContextPackVersion copyWith(
          {String? id,
          String? contextPackId,
          String? name,
          Value<String?> description = const Value.absent(),
          String? content,
          Value<String?> note = const Value.absent(),
          DateTime? createdAt}) =>
      ContextPackVersion(
        id: id ?? this.id,
        contextPackId: contextPackId ?? this.contextPackId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        content: content ?? this.content,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  ContextPackVersion copyWithCompanion(ContextPackVersionsCompanion data) {
    return ContextPackVersion(
      id: data.id.present ? data.id.value : this.id,
      contextPackId: data.contextPackId.present
          ? data.contextPackId.value
          : this.contextPackId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      content: data.content.present ? data.content.value : this.content,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextPackVersion(')
          ..write('id: $id, ')
          ..write('contextPackId: $contextPackId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, contextPackId, name, description, content, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextPackVersion &&
          other.id == this.id &&
          other.contextPackId == this.contextPackId &&
          other.name == this.name &&
          other.description == this.description &&
          other.content == this.content &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class ContextPackVersionsCompanion extends UpdateCompanion<ContextPackVersion> {
  final Value<String> id;
  final Value<String> contextPackId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> content;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ContextPackVersionsCompanion({
    this.id = const Value.absent(),
    this.contextPackId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.content = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContextPackVersionsCompanion.insert({
    required String id,
    required String contextPackId,
    required String name,
    this.description = const Value.absent(),
    required String content,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        contextPackId = Value(contextPackId),
        name = Value(name),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<ContextPackVersion> custom({
    Expression<String>? id,
    Expression<String>? contextPackId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? content,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contextPackId != null) 'context_pack_id': contextPackId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContextPackVersionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? contextPackId,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? content,
      Value<String?>? note,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ContextPackVersionsCompanion(
      id: id ?? this.id,
      contextPackId: contextPackId ?? this.contextPackId,
      name: name ?? this.name,
      description: description ?? this.description,
      content: content ?? this.content,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contextPackId.present) {
      map['context_pack_id'] = Variable<String>(contextPackId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextPackVersionsCompanion(')
          ..write('id: $id, ')
          ..write('contextPackId: $contextPackId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PromptsTable prompts = $PromptsTable(this);
  late final $PromptVersionsTable promptVersions = $PromptVersionsTable(this);
  late final $PromptVariablesTable promptVariables =
      $PromptVariablesTable(this);
  late final $ContextPacksTable contextPacks = $ContextPacksTable(this);
  late final $PromptContextPackLinksTable promptContextPackLinks =
      $PromptContextPackLinksTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $PromptTagsTable promptTags = $PromptTagsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $PromptCollectionLinksTable promptCollectionLinks =
      $PromptCollectionLinksTable(this);
  late final $InboxItemsTable inboxItems = $InboxItemsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $PromptExamplesTable promptExamples = $PromptExamplesTable(this);
  late final $PromptExampleOutputsTable promptExampleOutputs =
      $PromptExampleOutputsTable(this);
  late final $ContextPackVersionsTable contextPackVersions =
      $ContextPackVersionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        prompts,
        promptVersions,
        promptVariables,
        contextPacks,
        promptContextPackLinks,
        tags,
        promptTags,
        collections,
        promptCollectionLinks,
        inboxItems,
        userSettings,
        promptExamples,
        promptExampleOutputs,
        contextPackVersions
      ];
}

typedef $$PromptsTableCreateCompanionBuilder = PromptsCompanion Function({
  required String id,
  required String title,
  Value<String?> purpose,
  required String body,
  Value<String?> promptType,
  Value<String?> outputFormat,
  Value<String?> targetNotes,
  Value<bool> isArchived,
  Value<bool> isFavorite,
  Value<int> usageCount,
  Value<DateTime?> lastUsedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$PromptsTableUpdateCompanionBuilder = PromptsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> purpose,
  Value<String> body,
  Value<String?> promptType,
  Value<String?> outputFormat,
  Value<String?> targetNotes,
  Value<bool> isArchived,
  Value<bool> isFavorite,
  Value<int> usageCount,
  Value<DateTime?> lastUsedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$PromptsTableFilterComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptType => $composableBuilder(
      column: $table.promptType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outputFormat => $composableBuilder(
      column: $table.outputFormat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetNotes => $composableBuilder(
      column: $table.targetNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptType => $composableBuilder(
      column: $table.promptType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outputFormat => $composableBuilder(
      column: $table.outputFormat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetNotes => $composableBuilder(
      column: $table.targetNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptsTable> {
  $$PromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get promptType => $composableBuilder(
      column: $table.promptType, builder: (column) => column);

  GeneratedColumn<String> get outputFormat => $composableBuilder(
      column: $table.outputFormat, builder: (column) => column);

  GeneratedColumn<String> get targetNotes => $composableBuilder(
      column: $table.targetNotes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PromptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptsTable,
    Prompt,
    $$PromptsTableFilterComposer,
    $$PromptsTableOrderingComposer,
    $$PromptsTableAnnotationComposer,
    $$PromptsTableCreateCompanionBuilder,
    $$PromptsTableUpdateCompanionBuilder,
    (Prompt, BaseReferences<_$AppDatabase, $PromptsTable, Prompt>),
    Prompt,
    PrefetchHooks Function()> {
  $$PromptsTableTableManager(_$AppDatabase db, $PromptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String?> promptType = const Value.absent(),
            Value<String?> outputFormat = const Value.absent(),
            Value<String?> targetNotes = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime?> lastUsedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptsCompanion(
            id: id,
            title: title,
            purpose: purpose,
            body: body,
            promptType: promptType,
            outputFormat: outputFormat,
            targetNotes: targetNotes,
            isArchived: isArchived,
            isFavorite: isFavorite,
            usageCount: usageCount,
            lastUsedAt: lastUsedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> purpose = const Value.absent(),
            required String body,
            Value<String?> promptType = const Value.absent(),
            Value<String?> outputFormat = const Value.absent(),
            Value<String?> targetNotes = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<DateTime?> lastUsedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptsCompanion.insert(
            id: id,
            title: title,
            purpose: purpose,
            body: body,
            promptType: promptType,
            outputFormat: outputFormat,
            targetNotes: targetNotes,
            isArchived: isArchived,
            isFavorite: isFavorite,
            usageCount: usageCount,
            lastUsedAt: lastUsedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PromptsTable,
    Prompt,
    $$PromptsTableFilterComposer,
    $$PromptsTableOrderingComposer,
    $$PromptsTableAnnotationComposer,
    $$PromptsTableCreateCompanionBuilder,
    $$PromptsTableUpdateCompanionBuilder,
    (Prompt, BaseReferences<_$AppDatabase, $PromptsTable, Prompt>),
    Prompt,
    PrefetchHooks Function()>;
typedef $$PromptVersionsTableCreateCompanionBuilder = PromptVersionsCompanion
    Function({
  required String id,
  required String promptId,
  required String title,
  required String body,
  Value<String?> tagsJson,
  Value<String?> variableMetadataJson,
  Value<String?> note,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PromptVersionsTableUpdateCompanionBuilder = PromptVersionsCompanion
    Function({
  Value<String> id,
  Value<String> promptId,
  Value<String> title,
  Value<String> body,
  Value<String?> tagsJson,
  Value<String?> variableMetadataJson,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PromptVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $PromptVersionsTable> {
  $$PromptVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variableMetadataJson => $composableBuilder(
      column: $table.variableMetadataJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PromptVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptVersionsTable> {
  $$PromptVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variableMetadataJson => $composableBuilder(
      column: $table.variableMetadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PromptVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptVersionsTable> {
  $$PromptVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get variableMetadataJson => $composableBuilder(
      column: $table.variableMetadataJson, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PromptVersionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptVersionsTable,
    PromptVersion,
    $$PromptVersionsTableFilterComposer,
    $$PromptVersionsTableOrderingComposer,
    $$PromptVersionsTableAnnotationComposer,
    $$PromptVersionsTableCreateCompanionBuilder,
    $$PromptVersionsTableUpdateCompanionBuilder,
    (
      PromptVersion,
      BaseReferences<_$AppDatabase, $PromptVersionsTable, PromptVersion>
    ),
    PromptVersion,
    PrefetchHooks Function()> {
  $$PromptVersionsTableTableManager(
      _$AppDatabase db, $PromptVersionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> promptId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String?> tagsJson = const Value.absent(),
            Value<String?> variableMetadataJson = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptVersionsCompanion(
            id: id,
            promptId: promptId,
            title: title,
            body: body,
            tagsJson: tagsJson,
            variableMetadataJson: variableMetadataJson,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String promptId,
            required String title,
            required String body,
            Value<String?> tagsJson = const Value.absent(),
            Value<String?> variableMetadataJson = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptVersionsCompanion.insert(
            id: id,
            promptId: promptId,
            title: title,
            body: body,
            tagsJson: tagsJson,
            variableMetadataJson: variableMetadataJson,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptVersionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PromptVersionsTable,
    PromptVersion,
    $$PromptVersionsTableFilterComposer,
    $$PromptVersionsTableOrderingComposer,
    $$PromptVersionsTableAnnotationComposer,
    $$PromptVersionsTableCreateCompanionBuilder,
    $$PromptVersionsTableUpdateCompanionBuilder,
    (
      PromptVersion,
      BaseReferences<_$AppDatabase, $PromptVersionsTable, PromptVersion>
    ),
    PromptVersion,
    PrefetchHooks Function()>;
typedef $$PromptVariablesTableCreateCompanionBuilder = PromptVariablesCompanion
    Function({
  required String id,
  required String promptId,
  required String name,
  Value<String?> label,
  Value<String?> description,
  Value<String?> defaultValue,
  Value<String?> exampleValue,
  Value<bool> isRequired,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PromptVariablesTableUpdateCompanionBuilder = PromptVariablesCompanion
    Function({
  Value<String> id,
  Value<String> promptId,
  Value<String> name,
  Value<String?> label,
  Value<String?> description,
  Value<String?> defaultValue,
  Value<String?> exampleValue,
  Value<bool> isRequired,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PromptVariablesTableFilterComposer
    extends Composer<_$AppDatabase, $PromptVariablesTable> {
  $$PromptVariablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultValue => $composableBuilder(
      column: $table.defaultValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleValue => $composableBuilder(
      column: $table.exampleValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PromptVariablesTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptVariablesTable> {
  $$PromptVariablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultValue => $composableBuilder(
      column: $table.defaultValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleValue => $composableBuilder(
      column: $table.exampleValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PromptVariablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptVariablesTable> {
  $$PromptVariablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get defaultValue => $composableBuilder(
      column: $table.defaultValue, builder: (column) => column);

  GeneratedColumn<String> get exampleValue => $composableBuilder(
      column: $table.exampleValue, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PromptVariablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptVariablesTable,
    PromptVariable,
    $$PromptVariablesTableFilterComposer,
    $$PromptVariablesTableOrderingComposer,
    $$PromptVariablesTableAnnotationComposer,
    $$PromptVariablesTableCreateCompanionBuilder,
    $$PromptVariablesTableUpdateCompanionBuilder,
    (
      PromptVariable,
      BaseReferences<_$AppDatabase, $PromptVariablesTable, PromptVariable>
    ),
    PromptVariable,
    PrefetchHooks Function()> {
  $$PromptVariablesTableTableManager(
      _$AppDatabase db, $PromptVariablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptVariablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptVariablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptVariablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> promptId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> defaultValue = const Value.absent(),
            Value<String?> exampleValue = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptVariablesCompanion(
            id: id,
            promptId: promptId,
            name: name,
            label: label,
            description: description,
            defaultValue: defaultValue,
            exampleValue: exampleValue,
            isRequired: isRequired,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String promptId,
            required String name,
            Value<String?> label = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> defaultValue = const Value.absent(),
            Value<String?> exampleValue = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptVariablesCompanion.insert(
            id: id,
            promptId: promptId,
            name: name,
            label: label,
            description: description,
            defaultValue: defaultValue,
            exampleValue: exampleValue,
            isRequired: isRequired,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptVariablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PromptVariablesTable,
    PromptVariable,
    $$PromptVariablesTableFilterComposer,
    $$PromptVariablesTableOrderingComposer,
    $$PromptVariablesTableAnnotationComposer,
    $$PromptVariablesTableCreateCompanionBuilder,
    $$PromptVariablesTableUpdateCompanionBuilder,
    (
      PromptVariable,
      BaseReferences<_$AppDatabase, $PromptVariablesTable, PromptVariable>
    ),
    PromptVariable,
    PrefetchHooks Function()>;
typedef $$ContextPacksTableCreateCompanionBuilder = ContextPacksCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String content,
  Value<String?> packType,
  Value<bool> isBuiltin,
  Value<int> sortOrder,
  Value<bool> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$ContextPacksTableUpdateCompanionBuilder = ContextPacksCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> content,
  Value<String?> packType,
  Value<bool> isBuiltin,
  Value<int> sortOrder,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$ContextPacksTableFilterComposer
    extends Composer<_$AppDatabase, $ContextPacksTable> {
  $$ContextPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packType => $composableBuilder(
      column: $table.packType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ContextPacksTableOrderingComposer
    extends Composer<_$AppDatabase, $ContextPacksTable> {
  $$ContextPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packType => $composableBuilder(
      column: $table.packType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ContextPacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContextPacksTable> {
  $$ContextPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get packType =>
      $composableBuilder(column: $table.packType, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ContextPacksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContextPacksTable,
    ContextPack,
    $$ContextPacksTableFilterComposer,
    $$ContextPacksTableOrderingComposer,
    $$ContextPacksTableAnnotationComposer,
    $$ContextPacksTableCreateCompanionBuilder,
    $$ContextPacksTableUpdateCompanionBuilder,
    (
      ContextPack,
      BaseReferences<_$AppDatabase, $ContextPacksTable, ContextPack>
    ),
    ContextPack,
    PrefetchHooks Function()> {
  $$ContextPacksTableTableManager(_$AppDatabase db, $ContextPacksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContextPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContextPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> packType = const Value.absent(),
            Value<bool> isBuiltin = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContextPacksCompanion(
            id: id,
            name: name,
            description: description,
            content: content,
            packType: packType,
            isBuiltin: isBuiltin,
            sortOrder: sortOrder,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String content,
            Value<String?> packType = const Value.absent(),
            Value<bool> isBuiltin = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContextPacksCompanion.insert(
            id: id,
            name: name,
            description: description,
            content: content,
            packType: packType,
            isBuiltin: isBuiltin,
            sortOrder: sortOrder,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContextPacksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContextPacksTable,
    ContextPack,
    $$ContextPacksTableFilterComposer,
    $$ContextPacksTableOrderingComposer,
    $$ContextPacksTableAnnotationComposer,
    $$ContextPacksTableCreateCompanionBuilder,
    $$ContextPacksTableUpdateCompanionBuilder,
    (
      ContextPack,
      BaseReferences<_$AppDatabase, $ContextPacksTable, ContextPack>
    ),
    ContextPack,
    PrefetchHooks Function()>;
typedef $$PromptContextPackLinksTableCreateCompanionBuilder
    = PromptContextPackLinksCompanion Function({
  required String promptId,
  required String contextPackId,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PromptContextPackLinksTableUpdateCompanionBuilder
    = PromptContextPackLinksCompanion Function({
  Value<String> promptId,
  Value<String> contextPackId,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PromptContextPackLinksTableFilterComposer
    extends Composer<_$AppDatabase, $PromptContextPackLinksTable> {
  $$PromptContextPackLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PromptContextPackLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptContextPackLinksTable> {
  $$PromptContextPackLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PromptContextPackLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptContextPackLinksTable> {
  $$PromptContextPackLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PromptContextPackLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptContextPackLinksTable,
    PromptContextPackLink,
    $$PromptContextPackLinksTableFilterComposer,
    $$PromptContextPackLinksTableOrderingComposer,
    $$PromptContextPackLinksTableAnnotationComposer,
    $$PromptContextPackLinksTableCreateCompanionBuilder,
    $$PromptContextPackLinksTableUpdateCompanionBuilder,
    (
      PromptContextPackLink,
      BaseReferences<_$AppDatabase, $PromptContextPackLinksTable,
          PromptContextPackLink>
    ),
    PromptContextPackLink,
    PrefetchHooks Function()> {
  $$PromptContextPackLinksTableTableManager(
      _$AppDatabase db, $PromptContextPackLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptContextPackLinksTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptContextPackLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptContextPackLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> promptId = const Value.absent(),
            Value<String> contextPackId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptContextPackLinksCompanion(
            promptId: promptId,
            contextPackId: contextPackId,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String promptId,
            required String contextPackId,
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptContextPackLinksCompanion.insert(
            promptId: promptId,
            contextPackId: contextPackId,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptContextPackLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PromptContextPackLinksTable,
        PromptContextPackLink,
        $$PromptContextPackLinksTableFilterComposer,
        $$PromptContextPackLinksTableOrderingComposer,
        $$PromptContextPackLinksTableAnnotationComposer,
        $$PromptContextPackLinksTableCreateCompanionBuilder,
        $$PromptContextPackLinksTableUpdateCompanionBuilder,
        (
          PromptContextPackLink,
          BaseReferences<_$AppDatabase, $PromptContextPackLinksTable,
              PromptContextPackLink>
        ),
        PromptContextPackLink,
        PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<String?> colorHex,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> colorHex,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> colorHex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            colorHex: colorHex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> colorHex = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            colorHex: colorHex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()>;
typedef $$PromptTagsTableCreateCompanionBuilder = PromptTagsCompanion Function({
  required String promptId,
  required String tagId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PromptTagsTableUpdateCompanionBuilder = PromptTagsCompanion Function({
  Value<String> promptId,
  Value<String> tagId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PromptTagsTableFilterComposer
    extends Composer<_$AppDatabase, $PromptTagsTable> {
  $$PromptTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PromptTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptTagsTable> {
  $$PromptTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PromptTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptTagsTable> {
  $$PromptTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PromptTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptTagsTable,
    PromptTag,
    $$PromptTagsTableFilterComposer,
    $$PromptTagsTableOrderingComposer,
    $$PromptTagsTableAnnotationComposer,
    $$PromptTagsTableCreateCompanionBuilder,
    $$PromptTagsTableUpdateCompanionBuilder,
    (PromptTag, BaseReferences<_$AppDatabase, $PromptTagsTable, PromptTag>),
    PromptTag,
    PrefetchHooks Function()> {
  $$PromptTagsTableTableManager(_$AppDatabase db, $PromptTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> promptId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptTagsCompanion(
            promptId: promptId,
            tagId: tagId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String promptId,
            required String tagId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptTagsCompanion.insert(
            promptId: promptId,
            tagId: tagId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PromptTagsTable,
    PromptTag,
    $$PromptTagsTableFilterComposer,
    $$PromptTagsTableOrderingComposer,
    $$PromptTagsTableAnnotationComposer,
    $$PromptTagsTableCreateCompanionBuilder,
    $$PromptTagsTableUpdateCompanionBuilder,
    (PromptTag, BaseReferences<_$AppDatabase, $PromptTagsTable, PromptTag>),
    PromptTag,
    PrefetchHooks Function()>;
typedef $$CollectionsTableCreateCompanionBuilder = CollectionsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, BaseReferences<_$AppDatabase, $CollectionsTable, Collection>),
    Collection,
    PrefetchHooks Function()> {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            name: name,
            description: description,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionsCompanion.insert(
            id: id,
            name: name,
            description: description,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, BaseReferences<_$AppDatabase, $CollectionsTable, Collection>),
    Collection,
    PrefetchHooks Function()>;
typedef $$PromptCollectionLinksTableCreateCompanionBuilder
    = PromptCollectionLinksCompanion Function({
  required String promptId,
  required String collectionId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PromptCollectionLinksTableUpdateCompanionBuilder
    = PromptCollectionLinksCompanion Function({
  Value<String> promptId,
  Value<String> collectionId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PromptCollectionLinksTableFilterComposer
    extends Composer<_$AppDatabase, $PromptCollectionLinksTable> {
  $$PromptCollectionLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PromptCollectionLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptCollectionLinksTable> {
  $$PromptCollectionLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionId => $composableBuilder(
      column: $table.collectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PromptCollectionLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptCollectionLinksTable> {
  $$PromptCollectionLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PromptCollectionLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptCollectionLinksTable,
    PromptCollectionLink,
    $$PromptCollectionLinksTableFilterComposer,
    $$PromptCollectionLinksTableOrderingComposer,
    $$PromptCollectionLinksTableAnnotationComposer,
    $$PromptCollectionLinksTableCreateCompanionBuilder,
    $$PromptCollectionLinksTableUpdateCompanionBuilder,
    (
      PromptCollectionLink,
      BaseReferences<_$AppDatabase, $PromptCollectionLinksTable,
          PromptCollectionLink>
    ),
    PromptCollectionLink,
    PrefetchHooks Function()> {
  $$PromptCollectionLinksTableTableManager(
      _$AppDatabase db, $PromptCollectionLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptCollectionLinksTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptCollectionLinksTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptCollectionLinksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> promptId = const Value.absent(),
            Value<String> collectionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptCollectionLinksCompanion(
            promptId: promptId,
            collectionId: collectionId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String promptId,
            required String collectionId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptCollectionLinksCompanion.insert(
            promptId: promptId,
            collectionId: collectionId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptCollectionLinksTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PromptCollectionLinksTable,
        PromptCollectionLink,
        $$PromptCollectionLinksTableFilterComposer,
        $$PromptCollectionLinksTableOrderingComposer,
        $$PromptCollectionLinksTableAnnotationComposer,
        $$PromptCollectionLinksTableCreateCompanionBuilder,
        $$PromptCollectionLinksTableUpdateCompanionBuilder,
        (
          PromptCollectionLink,
          BaseReferences<_$AppDatabase, $PromptCollectionLinksTable,
              PromptCollectionLink>
        ),
        PromptCollectionLink,
        PrefetchHooks Function()>;
typedef $$InboxItemsTableCreateCompanionBuilder = InboxItemsCompanion Function({
  required String id,
  Value<String?> title,
  required String rawText,
  Value<String?> source,
  Value<String> status,
  Value<String?> convertedPromptId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$InboxItemsTableUpdateCompanionBuilder = InboxItemsCompanion Function({
  Value<String> id,
  Value<String?> title,
  Value<String> rawText,
  Value<String?> source,
  Value<String> status,
  Value<String?> convertedPromptId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$InboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get convertedPromptId => $composableBuilder(
      column: $table.convertedPromptId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$InboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get convertedPromptId => $composableBuilder(
      column: $table.convertedPromptId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$InboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get convertedPromptId => $composableBuilder(
      column: $table.convertedPromptId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$InboxItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InboxItemsTable,
    InboxItem,
    $$InboxItemsTableFilterComposer,
    $$InboxItemsTableOrderingComposer,
    $$InboxItemsTableAnnotationComposer,
    $$InboxItemsTableCreateCompanionBuilder,
    $$InboxItemsTableUpdateCompanionBuilder,
    (InboxItem, BaseReferences<_$AppDatabase, $InboxItemsTable, InboxItem>),
    InboxItem,
    PrefetchHooks Function()> {
  $$InboxItemsTableTableManager(_$AppDatabase db, $InboxItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> convertedPromptId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InboxItemsCompanion(
            id: id,
            title: title,
            rawText: rawText,
            source: source,
            status: status,
            convertedPromptId: convertedPromptId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> title = const Value.absent(),
            required String rawText,
            Value<String?> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> convertedPromptId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InboxItemsCompanion.insert(
            id: id,
            title: title,
            rawText: rawText,
            source: source,
            status: status,
            convertedPromptId: convertedPromptId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InboxItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InboxItemsTable,
    InboxItem,
    $$InboxItemsTableFilterComposer,
    $$InboxItemsTableOrderingComposer,
    $$InboxItemsTableAnnotationComposer,
    $$InboxItemsTableCreateCompanionBuilder,
    $$InboxItemsTableUpdateCompanionBuilder,
    (InboxItem, BaseReferences<_$AppDatabase, $InboxItemsTable, InboxItem>),
    InboxItem,
    PrefetchHooks Function()>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()>;
typedef $$PromptExamplesTableCreateCompanionBuilder = PromptExamplesCompanion
    Function({
  required String id,
  required String promptId,
  required String title,
  required String compiledPrompt,
  Value<String?> contextPackId,
  Value<String?> variableValuesJson,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$PromptExamplesTableUpdateCompanionBuilder = PromptExamplesCompanion
    Function({
  Value<String> id,
  Value<String> promptId,
  Value<String> title,
  Value<String> compiledPrompt,
  Value<String?> contextPackId,
  Value<String?> variableValuesJson,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isArchived,
  Value<int> rowid,
});

class $$PromptExamplesTableFilterComposer
    extends Composer<_$AppDatabase, $PromptExamplesTable> {
  $$PromptExamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get compiledPrompt => $composableBuilder(
      column: $table.compiledPrompt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variableValuesJson => $composableBuilder(
      column: $table.variableValuesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));
}

class $$PromptExamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptExamplesTable> {
  $$PromptExamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptId => $composableBuilder(
      column: $table.promptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get compiledPrompt => $composableBuilder(
      column: $table.compiledPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variableValuesJson => $composableBuilder(
      column: $table.variableValuesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));
}

class $$PromptExamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptExamplesTable> {
  $$PromptExamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get compiledPrompt => $composableBuilder(
      column: $table.compiledPrompt, builder: (column) => column);

  GeneratedColumn<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId, builder: (column) => column);

  GeneratedColumn<String> get variableValuesJson => $composableBuilder(
      column: $table.variableValuesJson, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);
}

class $$PromptExamplesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptExamplesTable,
    PromptExample,
    $$PromptExamplesTableFilterComposer,
    $$PromptExamplesTableOrderingComposer,
    $$PromptExamplesTableAnnotationComposer,
    $$PromptExamplesTableCreateCompanionBuilder,
    $$PromptExamplesTableUpdateCompanionBuilder,
    (
      PromptExample,
      BaseReferences<_$AppDatabase, $PromptExamplesTable, PromptExample>
    ),
    PromptExample,
    PrefetchHooks Function()> {
  $$PromptExamplesTableTableManager(
      _$AppDatabase db, $PromptExamplesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptExamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptExamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptExamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> promptId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> compiledPrompt = const Value.absent(),
            Value<String?> contextPackId = const Value.absent(),
            Value<String?> variableValuesJson = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptExamplesCompanion(
            id: id,
            promptId: promptId,
            title: title,
            compiledPrompt: compiledPrompt,
            contextPackId: contextPackId,
            variableValuesJson: variableValuesJson,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String promptId,
            required String title,
            required String compiledPrompt,
            Value<String?> contextPackId = const Value.absent(),
            Value<String?> variableValuesJson = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptExamplesCompanion.insert(
            id: id,
            promptId: promptId,
            title: title,
            compiledPrompt: compiledPrompt,
            contextPackId: contextPackId,
            variableValuesJson: variableValuesJson,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptExamplesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PromptExamplesTable,
    PromptExample,
    $$PromptExamplesTableFilterComposer,
    $$PromptExamplesTableOrderingComposer,
    $$PromptExamplesTableAnnotationComposer,
    $$PromptExamplesTableCreateCompanionBuilder,
    $$PromptExamplesTableUpdateCompanionBuilder,
    (
      PromptExample,
      BaseReferences<_$AppDatabase, $PromptExamplesTable, PromptExample>
    ),
    PromptExample,
    PrefetchHooks Function()>;
typedef $$PromptExampleOutputsTableCreateCompanionBuilder
    = PromptExampleOutputsCompanion Function({
  required String id,
  required String exampleId,
  required String providerName,
  Value<String?> modelName,
  required String outputText,
  Value<int?> score,
  Value<String?> notes,
  Value<bool> isBest,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PromptExampleOutputsTableUpdateCompanionBuilder
    = PromptExampleOutputsCompanion Function({
  Value<String> id,
  Value<String> exampleId,
  Value<String> providerName,
  Value<String?> modelName,
  Value<String> outputText,
  Value<int?> score,
  Value<String?> notes,
  Value<bool> isBest,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PromptExampleOutputsTableFilterComposer
    extends Composer<_$AppDatabase, $PromptExampleOutputsTable> {
  $$PromptExampleOutputsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outputText => $composableBuilder(
      column: $table.outputText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBest => $composableBuilder(
      column: $table.isBest, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PromptExampleOutputsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromptExampleOutputsTable> {
  $$PromptExampleOutputsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerName => $composableBuilder(
      column: $table.providerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outputText => $composableBuilder(
      column: $table.outputText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBest => $composableBuilder(
      column: $table.isBest, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PromptExampleOutputsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromptExampleOutputsTable> {
  $$PromptExampleOutputsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exampleId =>
      $composableBuilder(column: $table.exampleId, builder: (column) => column);

  GeneratedColumn<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get outputText => $composableBuilder(
      column: $table.outputText, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isBest =>
      $composableBuilder(column: $table.isBest, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PromptExampleOutputsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PromptExampleOutputsTable,
    PromptExampleOutput,
    $$PromptExampleOutputsTableFilterComposer,
    $$PromptExampleOutputsTableOrderingComposer,
    $$PromptExampleOutputsTableAnnotationComposer,
    $$PromptExampleOutputsTableCreateCompanionBuilder,
    $$PromptExampleOutputsTableUpdateCompanionBuilder,
    (
      PromptExampleOutput,
      BaseReferences<_$AppDatabase, $PromptExampleOutputsTable,
          PromptExampleOutput>
    ),
    PromptExampleOutput,
    PrefetchHooks Function()> {
  $$PromptExampleOutputsTableTableManager(
      _$AppDatabase db, $PromptExampleOutputsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromptExampleOutputsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromptExampleOutputsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromptExampleOutputsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> exampleId = const Value.absent(),
            Value<String> providerName = const Value.absent(),
            Value<String?> modelName = const Value.absent(),
            Value<String> outputText = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isBest = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptExampleOutputsCompanion(
            id: id,
            exampleId: exampleId,
            providerName: providerName,
            modelName: modelName,
            outputText: outputText,
            score: score,
            notes: notes,
            isBest: isBest,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String exampleId,
            required String providerName,
            Value<String?> modelName = const Value.absent(),
            required String outputText,
            Value<int?> score = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isBest = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PromptExampleOutputsCompanion.insert(
            id: id,
            exampleId: exampleId,
            providerName: providerName,
            modelName: modelName,
            outputText: outputText,
            score: score,
            notes: notes,
            isBest: isBest,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PromptExampleOutputsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PromptExampleOutputsTable,
        PromptExampleOutput,
        $$PromptExampleOutputsTableFilterComposer,
        $$PromptExampleOutputsTableOrderingComposer,
        $$PromptExampleOutputsTableAnnotationComposer,
        $$PromptExampleOutputsTableCreateCompanionBuilder,
        $$PromptExampleOutputsTableUpdateCompanionBuilder,
        (
          PromptExampleOutput,
          BaseReferences<_$AppDatabase, $PromptExampleOutputsTable,
              PromptExampleOutput>
        ),
        PromptExampleOutput,
        PrefetchHooks Function()>;
typedef $$ContextPackVersionsTableCreateCompanionBuilder
    = ContextPackVersionsCompanion Function({
  required String id,
  required String contextPackId,
  required String name,
  Value<String?> description,
  required String content,
  Value<String?> note,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ContextPackVersionsTableUpdateCompanionBuilder
    = ContextPackVersionsCompanion Function({
  Value<String> id,
  Value<String> contextPackId,
  Value<String> name,
  Value<String?> description,
  Value<String> content,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ContextPackVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $ContextPackVersionsTable> {
  $$ContextPackVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ContextPackVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContextPackVersionsTable> {
  $$ContextPackVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ContextPackVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContextPackVersionsTable> {
  $$ContextPackVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contextPackId => $composableBuilder(
      column: $table.contextPackId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContextPackVersionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContextPackVersionsTable,
    ContextPackVersion,
    $$ContextPackVersionsTableFilterComposer,
    $$ContextPackVersionsTableOrderingComposer,
    $$ContextPackVersionsTableAnnotationComposer,
    $$ContextPackVersionsTableCreateCompanionBuilder,
    $$ContextPackVersionsTableUpdateCompanionBuilder,
    (
      ContextPackVersion,
      BaseReferences<_$AppDatabase, $ContextPackVersionsTable,
          ContextPackVersion>
    ),
    ContextPackVersion,
    PrefetchHooks Function()> {
  $$ContextPackVersionsTableTableManager(
      _$AppDatabase db, $ContextPackVersionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextPackVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContextPackVersionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContextPackVersionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> contextPackId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContextPackVersionsCompanion(
            id: id,
            contextPackId: contextPackId,
            name: name,
            description: description,
            content: content,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String contextPackId,
            required String name,
            Value<String?> description = const Value.absent(),
            required String content,
            Value<String?> note = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ContextPackVersionsCompanion.insert(
            id: id,
            contextPackId: contextPackId,
            name: name,
            description: description,
            content: content,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContextPackVersionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContextPackVersionsTable,
    ContextPackVersion,
    $$ContextPackVersionsTableFilterComposer,
    $$ContextPackVersionsTableOrderingComposer,
    $$ContextPackVersionsTableAnnotationComposer,
    $$ContextPackVersionsTableCreateCompanionBuilder,
    $$ContextPackVersionsTableUpdateCompanionBuilder,
    (
      ContextPackVersion,
      BaseReferences<_$AppDatabase, $ContextPackVersionsTable,
          ContextPackVersion>
    ),
    ContextPackVersion,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PromptsTableTableManager get prompts =>
      $$PromptsTableTableManager(_db, _db.prompts);
  $$PromptVersionsTableTableManager get promptVersions =>
      $$PromptVersionsTableTableManager(_db, _db.promptVersions);
  $$PromptVariablesTableTableManager get promptVariables =>
      $$PromptVariablesTableTableManager(_db, _db.promptVariables);
  $$ContextPacksTableTableManager get contextPacks =>
      $$ContextPacksTableTableManager(_db, _db.contextPacks);
  $$PromptContextPackLinksTableTableManager get promptContextPackLinks =>
      $$PromptContextPackLinksTableTableManager(
          _db, _db.promptContextPackLinks);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$PromptTagsTableTableManager get promptTags =>
      $$PromptTagsTableTableManager(_db, _db.promptTags);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$PromptCollectionLinksTableTableManager get promptCollectionLinks =>
      $$PromptCollectionLinksTableTableManager(_db, _db.promptCollectionLinks);
  $$InboxItemsTableTableManager get inboxItems =>
      $$InboxItemsTableTableManager(_db, _db.inboxItems);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$PromptExamplesTableTableManager get promptExamples =>
      $$PromptExamplesTableTableManager(_db, _db.promptExamples);
  $$PromptExampleOutputsTableTableManager get promptExampleOutputs =>
      $$PromptExampleOutputsTableTableManager(_db, _db.promptExampleOutputs);
  $$ContextPackVersionsTableTableManager get contextPackVersions =>
      $$ContextPackVersionsTableTableManager(_db, _db.contextPackVersions);
}
