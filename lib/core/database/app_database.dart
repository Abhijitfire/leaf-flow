import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// -----------------------------------------------------------------------------
// Tables
// -----------------------------------------------------------------------------

@DataClassName('LocalWorker')
class LocalWorkers extends Table {
  TextColumn get pfNumber => text()();
  TextColumn get fullName => text()();
  TextColumn get dafaId => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  RealColumn get dailyQuotaKg => real().nullable()();

  @override
  Set<Column> get primaryKey => {pfNumber};
}

@DataClassName('LocalAttendanceRecord')
class LocalAttendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get planId => text()();
  TextColumn get workerId => text()();
  DateTimeColumn get recordDate => dateTime()();
  BoolColumn get isPresent => boolean()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Sync tracking
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// -----------------------------------------------------------------------------
// Database
// -----------------------------------------------------------------------------

@DriftDatabase(tables: [LocalWorkers, LocalAttendance])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'leafflow_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
