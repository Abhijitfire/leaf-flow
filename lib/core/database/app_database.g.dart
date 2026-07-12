// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalWorkersTable extends LocalWorkers
    with TableInfo<$LocalWorkersTable, LocalWorker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWorkersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pfNumberMeta = const VerificationMeta(
    'pfNumber',
  );
  @override
  late final GeneratedColumn<String> pfNumber = GeneratedColumn<String>(
    'pf_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dafaIdMeta = const VerificationMeta('dafaId');
  @override
  late final GeneratedColumn<String> dafaId = GeneratedColumn<String>(
    'dafa_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyQuotaKgMeta = const VerificationMeta(
    'dailyQuotaKg',
  );
  @override
  late final GeneratedColumn<double> dailyQuotaKg = GeneratedColumn<double>(
    'daily_quota_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pfNumber,
    fullName,
    dafaId,
    phoneNumber,
    dailyQuotaKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_workers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWorker> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pf_number')) {
      context.handle(
        _pfNumberMeta,
        pfNumber.isAcceptableOrUnknown(data['pf_number']!, _pfNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pfNumberMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('dafa_id')) {
      context.handle(
        _dafaIdMeta,
        dafaId.isAcceptableOrUnknown(data['dafa_id']!, _dafaIdMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('daily_quota_kg')) {
      context.handle(
        _dailyQuotaKgMeta,
        dailyQuotaKg.isAcceptableOrUnknown(
          data['daily_quota_kg']!,
          _dailyQuotaKgMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pfNumber};
  @override
  LocalWorker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWorker(
      pfNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pf_number'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      dafaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dafa_id'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      dailyQuotaKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_quota_kg'],
      ),
    );
  }

  @override
  $LocalWorkersTable createAlias(String alias) {
    return $LocalWorkersTable(attachedDatabase, alias);
  }
}

class LocalWorker extends DataClass implements Insertable<LocalWorker> {
  final String pfNumber;
  final String fullName;
  final String? dafaId;
  final String? phoneNumber;
  final double? dailyQuotaKg;
  const LocalWorker({
    required this.pfNumber,
    required this.fullName,
    this.dafaId,
    this.phoneNumber,
    this.dailyQuotaKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pf_number'] = Variable<String>(pfNumber);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || dafaId != null) {
      map['dafa_id'] = Variable<String>(dafaId);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || dailyQuotaKg != null) {
      map['daily_quota_kg'] = Variable<double>(dailyQuotaKg);
    }
    return map;
  }

  LocalWorkersCompanion toCompanion(bool nullToAbsent) {
    return LocalWorkersCompanion(
      pfNumber: Value(pfNumber),
      fullName: Value(fullName),
      dafaId: dafaId == null && nullToAbsent
          ? const Value.absent()
          : Value(dafaId),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      dailyQuotaKg: dailyQuotaKg == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyQuotaKg),
    );
  }

  factory LocalWorker.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWorker(
      pfNumber: serializer.fromJson<String>(json['pfNumber']),
      fullName: serializer.fromJson<String>(json['fullName']),
      dafaId: serializer.fromJson<String?>(json['dafaId']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      dailyQuotaKg: serializer.fromJson<double?>(json['dailyQuotaKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pfNumber': serializer.toJson<String>(pfNumber),
      'fullName': serializer.toJson<String>(fullName),
      'dafaId': serializer.toJson<String?>(dafaId),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'dailyQuotaKg': serializer.toJson<double?>(dailyQuotaKg),
    };
  }

  LocalWorker copyWith({
    String? pfNumber,
    String? fullName,
    Value<String?> dafaId = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<double?> dailyQuotaKg = const Value.absent(),
  }) => LocalWorker(
    pfNumber: pfNumber ?? this.pfNumber,
    fullName: fullName ?? this.fullName,
    dafaId: dafaId.present ? dafaId.value : this.dafaId,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    dailyQuotaKg: dailyQuotaKg.present ? dailyQuotaKg.value : this.dailyQuotaKg,
  );
  LocalWorker copyWithCompanion(LocalWorkersCompanion data) {
    return LocalWorker(
      pfNumber: data.pfNumber.present ? data.pfNumber.value : this.pfNumber,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      dafaId: data.dafaId.present ? data.dafaId.value : this.dafaId,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      dailyQuotaKg: data.dailyQuotaKg.present
          ? data.dailyQuotaKg.value
          : this.dailyQuotaKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorker(')
          ..write('pfNumber: $pfNumber, ')
          ..write('fullName: $fullName, ')
          ..write('dafaId: $dafaId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('dailyQuotaKg: $dailyQuotaKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(pfNumber, fullName, dafaId, phoneNumber, dailyQuotaKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWorker &&
          other.pfNumber == this.pfNumber &&
          other.fullName == this.fullName &&
          other.dafaId == this.dafaId &&
          other.phoneNumber == this.phoneNumber &&
          other.dailyQuotaKg == this.dailyQuotaKg);
}

class LocalWorkersCompanion extends UpdateCompanion<LocalWorker> {
  final Value<String> pfNumber;
  final Value<String> fullName;
  final Value<String?> dafaId;
  final Value<String?> phoneNumber;
  final Value<double?> dailyQuotaKg;
  final Value<int> rowid;
  const LocalWorkersCompanion({
    this.pfNumber = const Value.absent(),
    this.fullName = const Value.absent(),
    this.dafaId = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.dailyQuotaKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWorkersCompanion.insert({
    required String pfNumber,
    required String fullName,
    this.dafaId = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.dailyQuotaKg = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pfNumber = Value(pfNumber),
       fullName = Value(fullName);
  static Insertable<LocalWorker> custom({
    Expression<String>? pfNumber,
    Expression<String>? fullName,
    Expression<String>? dafaId,
    Expression<String>? phoneNumber,
    Expression<double>? dailyQuotaKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pfNumber != null) 'pf_number': pfNumber,
      if (fullName != null) 'full_name': fullName,
      if (dafaId != null) 'dafa_id': dafaId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (dailyQuotaKg != null) 'daily_quota_kg': dailyQuotaKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWorkersCompanion copyWith({
    Value<String>? pfNumber,
    Value<String>? fullName,
    Value<String?>? dafaId,
    Value<String?>? phoneNumber,
    Value<double?>? dailyQuotaKg,
    Value<int>? rowid,
  }) {
    return LocalWorkersCompanion(
      pfNumber: pfNumber ?? this.pfNumber,
      fullName: fullName ?? this.fullName,
      dafaId: dafaId ?? this.dafaId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dailyQuotaKg: dailyQuotaKg ?? this.dailyQuotaKg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pfNumber.present) {
      map['pf_number'] = Variable<String>(pfNumber.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (dafaId.present) {
      map['dafa_id'] = Variable<String>(dafaId.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (dailyQuotaKg.present) {
      map['daily_quota_kg'] = Variable<double>(dailyQuotaKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkersCompanion(')
          ..write('pfNumber: $pfNumber, ')
          ..write('fullName: $fullName, ')
          ..write('dafaId: $dafaId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('dailyQuotaKg: $dailyQuotaKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAttendanceTable extends LocalAttendance
    with TableInfo<$LocalAttendanceTable, LocalAttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workerIdMeta = const VerificationMeta(
    'workerId',
  );
  @override
  late final GeneratedColumn<String> workerId = GeneratedColumn<String>(
    'worker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPresentMeta = const VerificationMeta(
    'isPresent',
  );
  @override
  late final GeneratedColumn<bool> isPresent = GeneratedColumn<bool>(
    'is_present',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_present" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    workerId,
    recordDate,
    isPresent,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(
        _workerIdMeta,
        workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('is_present')) {
      context.handle(
        _isPresentMeta,
        isPresent.isAcceptableOrUnknown(data['is_present']!, _isPresentMeta),
      );
    } else if (isInserting) {
      context.missing(_isPresentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      workerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worker_id'],
      )!,
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      isPresent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_present'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalAttendanceTable createAlias(String alias) {
    return $LocalAttendanceTable(attachedDatabase, alias);
  }
}

class LocalAttendanceRecord extends DataClass
    implements Insertable<LocalAttendanceRecord> {
  final int id;
  final String planId;
  final String workerId;
  final DateTime recordDate;
  final bool isPresent;
  final DateTime createdAt;
  final bool isSynced;
  const LocalAttendanceRecord({
    required this.id,
    required this.planId,
    required this.workerId,
    required this.recordDate,
    required this.isPresent,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<String>(planId);
    map['worker_id'] = Variable<String>(workerId);
    map['record_date'] = Variable<DateTime>(recordDate);
    map['is_present'] = Variable<bool>(isPresent);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalAttendanceCompanion toCompanion(bool nullToAbsent) {
    return LocalAttendanceCompanion(
      id: Value(id),
      planId: Value(planId),
      workerId: Value(workerId),
      recordDate: Value(recordDate),
      isPresent: Value(isPresent),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory LocalAttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttendanceRecord(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      workerId: serializer.fromJson<String>(json['workerId']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      isPresent: serializer.fromJson<bool>(json['isPresent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<String>(planId),
      'workerId': serializer.toJson<String>(workerId),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'isPresent': serializer.toJson<bool>(isPresent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalAttendanceRecord copyWith({
    int? id,
    String? planId,
    String? workerId,
    DateTime? recordDate,
    bool? isPresent,
    DateTime? createdAt,
    bool? isSynced,
  }) => LocalAttendanceRecord(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    workerId: workerId ?? this.workerId,
    recordDate: recordDate ?? this.recordDate,
    isPresent: isPresent ?? this.isPresent,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalAttendanceRecord copyWithCompanion(LocalAttendanceCompanion data) {
    return LocalAttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      isPresent: data.isPresent.present ? data.isPresent.value : this.isPresent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendanceRecord(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('workerId: $workerId, ')
          ..write('recordDate: $recordDate, ')
          ..write('isPresent: $isPresent, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    workerId,
    recordDate,
    isPresent,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttendanceRecord &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.workerId == this.workerId &&
          other.recordDate == this.recordDate &&
          other.isPresent == this.isPresent &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class LocalAttendanceCompanion extends UpdateCompanion<LocalAttendanceRecord> {
  final Value<int> id;
  final Value<String> planId;
  final Value<String> workerId;
  final Value<DateTime> recordDate;
  final Value<bool> isPresent;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const LocalAttendanceCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.isPresent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  LocalAttendanceCompanion.insert({
    this.id = const Value.absent(),
    required String planId,
    required String workerId,
    required DateTime recordDate,
    required bool isPresent,
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : planId = Value(planId),
       workerId = Value(workerId),
       recordDate = Value(recordDate),
       isPresent = Value(isPresent);
  static Insertable<LocalAttendanceRecord> custom({
    Expression<int>? id,
    Expression<String>? planId,
    Expression<String>? workerId,
    Expression<DateTime>? recordDate,
    Expression<bool>? isPresent,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (workerId != null) 'worker_id': workerId,
      if (recordDate != null) 'record_date': recordDate,
      if (isPresent != null) 'is_present': isPresent,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  LocalAttendanceCompanion copyWith({
    Value<int>? id,
    Value<String>? planId,
    Value<String>? workerId,
    Value<DateTime>? recordDate,
    Value<bool>? isPresent,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return LocalAttendanceCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      workerId: workerId ?? this.workerId,
      recordDate: recordDate ?? this.recordDate,
      isPresent: isPresent ?? this.isPresent,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<String>(workerId.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (isPresent.present) {
      map['is_present'] = Variable<bool>(isPresent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendanceCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('workerId: $workerId, ')
          ..write('recordDate: $recordDate, ')
          ..write('isPresent: $isPresent, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalWorkersTable localWorkers = $LocalWorkersTable(this);
  late final $LocalAttendanceTable localAttendance = $LocalAttendanceTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localWorkers,
    localAttendance,
  ];
}

typedef $$LocalWorkersTableCreateCompanionBuilder =
    LocalWorkersCompanion Function({
      required String pfNumber,
      required String fullName,
      Value<String?> dafaId,
      Value<String?> phoneNumber,
      Value<double?> dailyQuotaKg,
      Value<int> rowid,
    });
typedef $$LocalWorkersTableUpdateCompanionBuilder =
    LocalWorkersCompanion Function({
      Value<String> pfNumber,
      Value<String> fullName,
      Value<String?> dafaId,
      Value<String?> phoneNumber,
      Value<double?> dailyQuotaKg,
      Value<int> rowid,
    });

class $$LocalWorkersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWorkersTable> {
  $$LocalWorkersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pfNumber => $composableBuilder(
    column: $table.pfNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dafaId => $composableBuilder(
    column: $table.dafaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyQuotaKg => $composableBuilder(
    column: $table.dailyQuotaKg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalWorkersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWorkersTable> {
  $$LocalWorkersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pfNumber => $composableBuilder(
    column: $table.pfNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dafaId => $composableBuilder(
    column: $table.dafaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyQuotaKg => $composableBuilder(
    column: $table.dailyQuotaKg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWorkersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWorkersTable> {
  $$LocalWorkersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pfNumber =>
      $composableBuilder(column: $table.pfNumber, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get dafaId =>
      $composableBuilder(column: $table.dafaId, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dailyQuotaKg => $composableBuilder(
    column: $table.dailyQuotaKg,
    builder: (column) => column,
  );
}

class $$LocalWorkersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWorkersTable,
          LocalWorker,
          $$LocalWorkersTableFilterComposer,
          $$LocalWorkersTableOrderingComposer,
          $$LocalWorkersTableAnnotationComposer,
          $$LocalWorkersTableCreateCompanionBuilder,
          $$LocalWorkersTableUpdateCompanionBuilder,
          (
            LocalWorker,
            BaseReferences<_$AppDatabase, $LocalWorkersTable, LocalWorker>,
          ),
          LocalWorker,
          PrefetchHooks Function()
        > {
  $$LocalWorkersTableTableManager(_$AppDatabase db, $LocalWorkersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWorkersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWorkersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalWorkersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pfNumber = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> dafaId = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<double?> dailyQuotaKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkersCompanion(
                pfNumber: pfNumber,
                fullName: fullName,
                dafaId: dafaId,
                phoneNumber: phoneNumber,
                dailyQuotaKg: dailyQuotaKg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pfNumber,
                required String fullName,
                Value<String?> dafaId = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<double?> dailyQuotaKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWorkersCompanion.insert(
                pfNumber: pfNumber,
                fullName: fullName,
                dafaId: dafaId,
                phoneNumber: phoneNumber,
                dailyQuotaKg: dailyQuotaKg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalWorkersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWorkersTable,
      LocalWorker,
      $$LocalWorkersTableFilterComposer,
      $$LocalWorkersTableOrderingComposer,
      $$LocalWorkersTableAnnotationComposer,
      $$LocalWorkersTableCreateCompanionBuilder,
      $$LocalWorkersTableUpdateCompanionBuilder,
      (
        LocalWorker,
        BaseReferences<_$AppDatabase, $LocalWorkersTable, LocalWorker>,
      ),
      LocalWorker,
      PrefetchHooks Function()
    >;
typedef $$LocalAttendanceTableCreateCompanionBuilder =
    LocalAttendanceCompanion Function({
      Value<int> id,
      required String planId,
      required String workerId,
      required DateTime recordDate,
      required bool isPresent,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });
typedef $$LocalAttendanceTableUpdateCompanionBuilder =
    LocalAttendanceCompanion Function({
      Value<int> id,
      Value<String> planId,
      Value<String> workerId,
      Value<DateTime> recordDate,
      Value<bool> isPresent,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

class $$LocalAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttendanceTable> {
  $$LocalAttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPresent => $composableBuilder(
    column: $table.isPresent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttendanceTable> {
  $$LocalAttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workerId => $composableBuilder(
    column: $table.workerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPresent => $composableBuilder(
    column: $table.isPresent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttendanceTable> {
  $$LocalAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get workerId =>
      $composableBuilder(column: $table.workerId, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPresent =>
      $composableBuilder(column: $table.isPresent, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalAttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAttendanceTable,
          LocalAttendanceRecord,
          $$LocalAttendanceTableFilterComposer,
          $$LocalAttendanceTableOrderingComposer,
          $$LocalAttendanceTableAnnotationComposer,
          $$LocalAttendanceTableCreateCompanionBuilder,
          $$LocalAttendanceTableUpdateCompanionBuilder,
          (
            LocalAttendanceRecord,
            BaseReferences<
              _$AppDatabase,
              $LocalAttendanceTable,
              LocalAttendanceRecord
            >,
          ),
          LocalAttendanceRecord,
          PrefetchHooks Function()
        > {
  $$LocalAttendanceTableTableManager(
    _$AppDatabase db,
    $LocalAttendanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<String> workerId = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<bool> isPresent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => LocalAttendanceCompanion(
                id: id,
                planId: planId,
                workerId: workerId,
                recordDate: recordDate,
                isPresent: isPresent,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String planId,
                required String workerId,
                required DateTime recordDate,
                required bool isPresent,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => LocalAttendanceCompanion.insert(
                id: id,
                planId: planId,
                workerId: workerId,
                recordDate: recordDate,
                isPresent: isPresent,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAttendanceTable,
      LocalAttendanceRecord,
      $$LocalAttendanceTableFilterComposer,
      $$LocalAttendanceTableOrderingComposer,
      $$LocalAttendanceTableAnnotationComposer,
      $$LocalAttendanceTableCreateCompanionBuilder,
      $$LocalAttendanceTableUpdateCompanionBuilder,
      (
        LocalAttendanceRecord,
        BaseReferences<
          _$AppDatabase,
          $LocalAttendanceTable,
          LocalAttendanceRecord
        >,
      ),
      LocalAttendanceRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalWorkersTableTableManager get localWorkers =>
      $$LocalWorkersTableTableManager(_db, _db.localWorkers);
  $$LocalAttendanceTableTableManager get localAttendance =>
      $$LocalAttendanceTableTableManager(_db, _db.localAttendance);
}
