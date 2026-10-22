// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserSettingsTableTable extends UserSettingsTable
    with TableInfo<$UserSettingsTableTable, UserSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _paydayDayMeta =
      const VerificationMeta('paydayDay');
  @override
  late final GeneratedColumn<int> paydayDay = GeneratedColumn<int>(
      'payday_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('₹'));
  static const VerificationMeta _rolloverStrategyMeta =
      const VerificationMeta('rolloverStrategy');
  @override
  late final GeneratedColumn<String> rolloverStrategy = GeneratedColumn<String>(
      'rollover_strategy', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('dynamic_smoothing'));
  static const VerificationMeta _isSeriousModeMeta =
      const VerificationMeta('isSeriousMode');
  @override
  late final GeneratedColumn<bool> isSeriousMode = GeneratedColumn<bool>(
      'is_serious_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_serious_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reducedMotionMeta =
      const VerificationMeta('reducedMotion');
  @override
  late final GeneratedColumn<bool> reducedMotion = GeneratedColumn<bool>(
      'reduced_motion', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reduced_motion" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _biometricLockMeta =
      const VerificationMeta('biometricLock');
  @override
  late final GeneratedColumn<bool> biometricLock = GeneratedColumn<bool>(
      'biometric_lock', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("biometric_lock" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autoFlowSavingsMeta =
      const VerificationMeta('autoFlowSavings');
  @override
  late final GeneratedColumn<bool> autoFlowSavings = GeneratedColumn<bool>(
      'auto_flow_savings', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_flow_savings" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autoFlowGoalIdMeta =
      const VerificationMeta('autoFlowGoalId');
  @override
  late final GeneratedColumn<String> autoFlowGoalId = GeneratedColumn<String>(
      'auto_flow_goal_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastKnownDeviceTimestampMeta =
      const VerificationMeta('lastKnownDeviceTimestamp');
  @override
  late final GeneratedColumn<DateTime> lastKnownDeviceTimestamp =
      GeneratedColumn<DateTime>(
          'last_known_device_timestamp', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        paydayDay,
        currencySymbol,
        rolloverStrategy,
        isSeriousMode,
        reducedMotion,
        biometricLock,
        autoFlowSavings,
        autoFlowGoalId,
        lastKnownDeviceTimestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payday_day')) {
      context.handle(_paydayDayMeta,
          paydayDay.isAcceptableOrUnknown(data['payday_day']!, _paydayDayMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    }
    if (data.containsKey('rollover_strategy')) {
      context.handle(
          _rolloverStrategyMeta,
          rolloverStrategy.isAcceptableOrUnknown(
              data['rollover_strategy']!, _rolloverStrategyMeta));
    }
    if (data.containsKey('is_serious_mode')) {
      context.handle(
          _isSeriousModeMeta,
          isSeriousMode.isAcceptableOrUnknown(
              data['is_serious_mode']!, _isSeriousModeMeta));
    }
    if (data.containsKey('reduced_motion')) {
      context.handle(
          _reducedMotionMeta,
          reducedMotion.isAcceptableOrUnknown(
              data['reduced_motion']!, _reducedMotionMeta));
    }
    if (data.containsKey('biometric_lock')) {
      context.handle(
          _biometricLockMeta,
          biometricLock.isAcceptableOrUnknown(
              data['biometric_lock']!, _biometricLockMeta));
    }
    if (data.containsKey('auto_flow_savings')) {
      context.handle(
          _autoFlowSavingsMeta,
          autoFlowSavings.isAcceptableOrUnknown(
              data['auto_flow_savings']!, _autoFlowSavingsMeta));
    }
    if (data.containsKey('auto_flow_goal_id')) {
      context.handle(
          _autoFlowGoalIdMeta,
          autoFlowGoalId.isAcceptableOrUnknown(
              data['auto_flow_goal_id']!, _autoFlowGoalIdMeta));
    }
    if (data.containsKey('last_known_device_timestamp')) {
      context.handle(
          _lastKnownDeviceTimestampMeta,
          lastKnownDeviceTimestamp.isAcceptableOrUnknown(
              data['last_known_device_timestamp']!,
              _lastKnownDeviceTimestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      paydayDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payday_day'])!,
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      rolloverStrategy: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rollover_strategy'])!,
      isSeriousMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_serious_mode'])!,
      reducedMotion: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reduced_motion'])!,
      biometricLock: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}biometric_lock'])!,
      autoFlowSavings: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_flow_savings'])!,
      autoFlowGoalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}auto_flow_goal_id']),
      lastKnownDeviceTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_known_device_timestamp']),
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }
}

class UserSettingsTableData extends DataClass
    implements Insertable<UserSettingsTableData> {
  final int id;
  final int paydayDay;
  final String currencySymbol;
  final String rolloverStrategy;
  final bool isSeriousMode;
  final bool reducedMotion;
  final bool biometricLock;
  final bool autoFlowSavings;
  final String? autoFlowGoalId;
  final DateTime? lastKnownDeviceTimestamp;
  const UserSettingsTableData(
      {required this.id,
      required this.paydayDay,
      required this.currencySymbol,
      required this.rolloverStrategy,
      required this.isSeriousMode,
      required this.reducedMotion,
      required this.biometricLock,
      required this.autoFlowSavings,
      this.autoFlowGoalId,
      this.lastKnownDeviceTimestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payday_day'] = Variable<int>(paydayDay);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['rollover_strategy'] = Variable<String>(rolloverStrategy);
    map['is_serious_mode'] = Variable<bool>(isSeriousMode);
    map['reduced_motion'] = Variable<bool>(reducedMotion);
    map['biometric_lock'] = Variable<bool>(biometricLock);
    map['auto_flow_savings'] = Variable<bool>(autoFlowSavings);
    if (!nullToAbsent || autoFlowGoalId != null) {
      map['auto_flow_goal_id'] = Variable<String>(autoFlowGoalId);
    }
    if (!nullToAbsent || lastKnownDeviceTimestamp != null) {
      map['last_known_device_timestamp'] =
          Variable<DateTime>(lastKnownDeviceTimestamp);
    }
    return map;
  }

  UserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsTableCompanion(
      id: Value(id),
      paydayDay: Value(paydayDay),
      currencySymbol: Value(currencySymbol),
      rolloverStrategy: Value(rolloverStrategy),
      isSeriousMode: Value(isSeriousMode),
      reducedMotion: Value(reducedMotion),
      biometricLock: Value(biometricLock),
      autoFlowSavings: Value(autoFlowSavings),
      autoFlowGoalId: autoFlowGoalId == null && nullToAbsent
          ? const Value.absent()
          : Value(autoFlowGoalId),
      lastKnownDeviceTimestamp: lastKnownDeviceTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(lastKnownDeviceTimestamp),
    );
  }

  factory UserSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      paydayDay: serializer.fromJson<int>(json['paydayDay']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      rolloverStrategy: serializer.fromJson<String>(json['rolloverStrategy']),
      isSeriousMode: serializer.fromJson<bool>(json['isSeriousMode']),
      reducedMotion: serializer.fromJson<bool>(json['reducedMotion']),
      biometricLock: serializer.fromJson<bool>(json['biometricLock']),
      autoFlowSavings: serializer.fromJson<bool>(json['autoFlowSavings']),
      autoFlowGoalId: serializer.fromJson<String?>(json['autoFlowGoalId']),
      lastKnownDeviceTimestamp:
          serializer.fromJson<DateTime?>(json['lastKnownDeviceTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paydayDay': serializer.toJson<int>(paydayDay),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'rolloverStrategy': serializer.toJson<String>(rolloverStrategy),
      'isSeriousMode': serializer.toJson<bool>(isSeriousMode),
      'reducedMotion': serializer.toJson<bool>(reducedMotion),
      'biometricLock': serializer.toJson<bool>(biometricLock),
      'autoFlowSavings': serializer.toJson<bool>(autoFlowSavings),
      'autoFlowGoalId': serializer.toJson<String?>(autoFlowGoalId),
      'lastKnownDeviceTimestamp':
          serializer.toJson<DateTime?>(lastKnownDeviceTimestamp),
    };
  }

  UserSettingsTableData copyWith(
          {int? id,
          int? paydayDay,
          String? currencySymbol,
          String? rolloverStrategy,
          bool? isSeriousMode,
          bool? reducedMotion,
          bool? biometricLock,
          bool? autoFlowSavings,
          Value<String?> autoFlowGoalId = const Value.absent(),
          Value<DateTime?> lastKnownDeviceTimestamp = const Value.absent()}) =>
      UserSettingsTableData(
        id: id ?? this.id,
        paydayDay: paydayDay ?? this.paydayDay,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        rolloverStrategy: rolloverStrategy ?? this.rolloverStrategy,
        isSeriousMode: isSeriousMode ?? this.isSeriousMode,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        biometricLock: biometricLock ?? this.biometricLock,
        autoFlowSavings: autoFlowSavings ?? this.autoFlowSavings,
        autoFlowGoalId:
            autoFlowGoalId.present ? autoFlowGoalId.value : this.autoFlowGoalId,
        lastKnownDeviceTimestamp: lastKnownDeviceTimestamp.present
            ? lastKnownDeviceTimestamp.value
            : this.lastKnownDeviceTimestamp,
      );
  UserSettingsTableData copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      paydayDay: data.paydayDay.present ? data.paydayDay.value : this.paydayDay,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      rolloverStrategy: data.rolloverStrategy.present
          ? data.rolloverStrategy.value
          : this.rolloverStrategy,
      isSeriousMode: data.isSeriousMode.present
          ? data.isSeriousMode.value
          : this.isSeriousMode,
      reducedMotion: data.reducedMotion.present
          ? data.reducedMotion.value
          : this.reducedMotion,
      biometricLock: data.biometricLock.present
          ? data.biometricLock.value
          : this.biometricLock,
      autoFlowSavings: data.autoFlowSavings.present
          ? data.autoFlowSavings.value
          : this.autoFlowSavings,
      autoFlowGoalId: data.autoFlowGoalId.present
          ? data.autoFlowGoalId.value
          : this.autoFlowGoalId,
      lastKnownDeviceTimestamp: data.lastKnownDeviceTimestamp.present
          ? data.lastKnownDeviceTimestamp.value
          : this.lastKnownDeviceTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableData(')
          ..write('id: $id, ')
          ..write('paydayDay: $paydayDay, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('rolloverStrategy: $rolloverStrategy, ')
          ..write('isSeriousMode: $isSeriousMode, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('biometricLock: $biometricLock, ')
          ..write('autoFlowSavings: $autoFlowSavings, ')
          ..write('autoFlowGoalId: $autoFlowGoalId, ')
          ..write('lastKnownDeviceTimestamp: $lastKnownDeviceTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      paydayDay,
      currencySymbol,
      rolloverStrategy,
      isSeriousMode,
      reducedMotion,
      biometricLock,
      autoFlowSavings,
      autoFlowGoalId,
      lastKnownDeviceTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsTableData &&
          other.id == this.id &&
          other.paydayDay == this.paydayDay &&
          other.currencySymbol == this.currencySymbol &&
          other.rolloverStrategy == this.rolloverStrategy &&
          other.isSeriousMode == this.isSeriousMode &&
          other.reducedMotion == this.reducedMotion &&
          other.biometricLock == this.biometricLock &&
          other.autoFlowSavings == this.autoFlowSavings &&
          other.autoFlowGoalId == this.autoFlowGoalId &&
          other.lastKnownDeviceTimestamp == this.lastKnownDeviceTimestamp);
}

class UserSettingsTableCompanion
    extends UpdateCompanion<UserSettingsTableData> {
  final Value<int> id;
  final Value<int> paydayDay;
  final Value<String> currencySymbol;
  final Value<String> rolloverStrategy;
  final Value<bool> isSeriousMode;
  final Value<bool> reducedMotion;
  final Value<bool> biometricLock;
  final Value<bool> autoFlowSavings;
  final Value<String?> autoFlowGoalId;
  final Value<DateTime?> lastKnownDeviceTimestamp;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.paydayDay = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.rolloverStrategy = const Value.absent(),
    this.isSeriousMode = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    this.biometricLock = const Value.absent(),
    this.autoFlowSavings = const Value.absent(),
    this.autoFlowGoalId = const Value.absent(),
    this.lastKnownDeviceTimestamp = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.paydayDay = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.rolloverStrategy = const Value.absent(),
    this.isSeriousMode = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    this.biometricLock = const Value.absent(),
    this.autoFlowSavings = const Value.absent(),
    this.autoFlowGoalId = const Value.absent(),
    this.lastKnownDeviceTimestamp = const Value.absent(),
  });
  static Insertable<UserSettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? paydayDay,
    Expression<String>? currencySymbol,
    Expression<String>? rolloverStrategy,
    Expression<bool>? isSeriousMode,
    Expression<bool>? reducedMotion,
    Expression<bool>? biometricLock,
    Expression<bool>? autoFlowSavings,
    Expression<String>? autoFlowGoalId,
    Expression<DateTime>? lastKnownDeviceTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paydayDay != null) 'payday_day': paydayDay,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (rolloverStrategy != null) 'rollover_strategy': rolloverStrategy,
      if (isSeriousMode != null) 'is_serious_mode': isSeriousMode,
      if (reducedMotion != null) 'reduced_motion': reducedMotion,
      if (biometricLock != null) 'biometric_lock': biometricLock,
      if (autoFlowSavings != null) 'auto_flow_savings': autoFlowSavings,
      if (autoFlowGoalId != null) 'auto_flow_goal_id': autoFlowGoalId,
      if (lastKnownDeviceTimestamp != null)
        'last_known_device_timestamp': lastKnownDeviceTimestamp,
    });
  }

  UserSettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? paydayDay,
      Value<String>? currencySymbol,
      Value<String>? rolloverStrategy,
      Value<bool>? isSeriousMode,
      Value<bool>? reducedMotion,
      Value<bool>? biometricLock,
      Value<bool>? autoFlowSavings,
      Value<String?>? autoFlowGoalId,
      Value<DateTime?>? lastKnownDeviceTimestamp}) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      paydayDay: paydayDay ?? this.paydayDay,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      rolloverStrategy: rolloverStrategy ?? this.rolloverStrategy,
      isSeriousMode: isSeriousMode ?? this.isSeriousMode,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      biometricLock: biometricLock ?? this.biometricLock,
      autoFlowSavings: autoFlowSavings ?? this.autoFlowSavings,
      autoFlowGoalId: autoFlowGoalId ?? this.autoFlowGoalId,
      lastKnownDeviceTimestamp:
          lastKnownDeviceTimestamp ?? this.lastKnownDeviceTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paydayDay.present) {
      map['payday_day'] = Variable<int>(paydayDay.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (rolloverStrategy.present) {
      map['rollover_strategy'] = Variable<String>(rolloverStrategy.value);
    }
    if (isSeriousMode.present) {
      map['is_serious_mode'] = Variable<bool>(isSeriousMode.value);
    }
    if (reducedMotion.present) {
      map['reduced_motion'] = Variable<bool>(reducedMotion.value);
    }
    if (biometricLock.present) {
      map['biometric_lock'] = Variable<bool>(biometricLock.value);
    }
    if (autoFlowSavings.present) {
      map['auto_flow_savings'] = Variable<bool>(autoFlowSavings.value);
    }
    if (autoFlowGoalId.present) {
      map['auto_flow_goal_id'] = Variable<String>(autoFlowGoalId.value);
    }
    if (lastKnownDeviceTimestamp.present) {
      map['last_known_device_timestamp'] =
          Variable<DateTime>(lastKnownDeviceTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('paydayDay: $paydayDay, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('rolloverStrategy: $rolloverStrategy, ')
          ..write('isSeriousMode: $isSeriousMode, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('biometricLock: $biometricLock, ')
          ..write('autoFlowSavings: $autoFlowSavings, ')
          ..write('autoFlowGoalId: $autoFlowGoalId, ')
          ..write('lastKnownDeviceTimestamp: $lastKnownDeviceTimestamp')
          ..write(')'))
        .toString();
  }
}

class $CyclesTableTable extends CyclesTable
    with TableInfo<$CyclesTableTable, CyclesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalDaysMeta =
      const VerificationMeta('totalDays');
  @override
  late final GeneratedColumn<int> totalDays = GeneratedColumn<int>(
      'total_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _paydayDayMeta =
      const VerificationMeta('paydayDay');
  @override
  late final GeneratedColumn<int> paydayDay = GeneratedColumn<int>(
      'payday_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _salaryReceivedDateMeta =
      const VerificationMeta('salaryReceivedDate');
  @override
  late final GeneratedColumn<DateTime> salaryReceivedDate =
      GeneratedColumn<DateTime>('salary_received_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _inHandSalaryPaiseMeta =
      const VerificationMeta('inHandSalaryPaise');
  @override
  late final GeneratedColumn<int> inHandSalaryPaise = GeneratedColumn<int>(
      'in_hand_salary_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fixedExpensesPaiseMeta =
      const VerificationMeta('fixedExpensesPaise');
  @override
  late final GeneratedColumn<int> fixedExpensesPaise = GeneratedColumn<int>(
      'fixed_expenses_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _savingsTargetPaiseMeta =
      const VerificationMeta('savingsTargetPaise');
  @override
  late final GeneratedColumn<int> savingsTargetPaise = GeneratedColumn<int>(
      'savings_target_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rolloverStrategyMeta =
      const VerificationMeta('rolloverStrategy');
  @override
  late final GeneratedColumn<String> rolloverStrategy = GeneratedColumn<String>(
      'rollover_strategy', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('dynamic_smoothing'));
  static const VerificationMeta _bossCurrentHpMeta =
      const VerificationMeta('bossCurrentHp');
  @override
  late final GeneratedColumn<int> bossCurrentHp = GeneratedColumn<int>(
      'boss_current_hp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bossMaxHpMeta =
      const VerificationMeta('bossMaxHp');
  @override
  late final GeneratedColumn<int> bossMaxHp = GeneratedColumn<int>(
      'boss_max_hp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
        startDate,
        endDate,
        totalDays,
        paydayDay,
        salaryReceivedDate,
        inHandSalaryPaise,
        fixedExpensesPaise,
        savingsTargetPaise,
        rolloverStrategy,
        bossCurrentHp,
        bossMaxHp,
        isArchived
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycles_table';
  @override
  VerificationContext validateIntegrity(Insertable<CyclesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('total_days')) {
      context.handle(_totalDaysMeta,
          totalDays.isAcceptableOrUnknown(data['total_days']!, _totalDaysMeta));
    } else if (isInserting) {
      context.missing(_totalDaysMeta);
    }
    if (data.containsKey('payday_day')) {
      context.handle(_paydayDayMeta,
          paydayDay.isAcceptableOrUnknown(data['payday_day']!, _paydayDayMeta));
    }
    if (data.containsKey('salary_received_date')) {
      context.handle(
          _salaryReceivedDateMeta,
          salaryReceivedDate.isAcceptableOrUnknown(
              data['salary_received_date']!, _salaryReceivedDateMeta));
    }
    if (data.containsKey('in_hand_salary_paise')) {
      context.handle(
          _inHandSalaryPaiseMeta,
          inHandSalaryPaise.isAcceptableOrUnknown(
              data['in_hand_salary_paise']!, _inHandSalaryPaiseMeta));
    } else if (isInserting) {
      context.missing(_inHandSalaryPaiseMeta);
    }
    if (data.containsKey('fixed_expenses_paise')) {
      context.handle(
          _fixedExpensesPaiseMeta,
          fixedExpensesPaise.isAcceptableOrUnknown(
              data['fixed_expenses_paise']!, _fixedExpensesPaiseMeta));
    } else if (isInserting) {
      context.missing(_fixedExpensesPaiseMeta);
    }
    if (data.containsKey('savings_target_paise')) {
      context.handle(
          _savingsTargetPaiseMeta,
          savingsTargetPaise.isAcceptableOrUnknown(
              data['savings_target_paise']!, _savingsTargetPaiseMeta));
    } else if (isInserting) {
      context.missing(_savingsTargetPaiseMeta);
    }
    if (data.containsKey('rollover_strategy')) {
      context.handle(
          _rolloverStrategyMeta,
          rolloverStrategy.isAcceptableOrUnknown(
              data['rollover_strategy']!, _rolloverStrategyMeta));
    }
    if (data.containsKey('boss_current_hp')) {
      context.handle(
          _bossCurrentHpMeta,
          bossCurrentHp.isAcceptableOrUnknown(
              data['boss_current_hp']!, _bossCurrentHpMeta));
    } else if (isInserting) {
      context.missing(_bossCurrentHpMeta);
    }
    if (data.containsKey('boss_max_hp')) {
      context.handle(
          _bossMaxHpMeta,
          bossMaxHp.isAcceptableOrUnknown(
              data['boss_max_hp']!, _bossMaxHpMeta));
    } else if (isInserting) {
      context.missing(_bossMaxHpMeta);
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
  CyclesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      totalDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_days'])!,
      paydayDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payday_day'])!,
      salaryReceivedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}salary_received_date']),
      inHandSalaryPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}in_hand_salary_paise'])!,
      fixedExpensesPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}fixed_expenses_paise'])!,
      savingsTargetPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}savings_target_paise'])!,
      rolloverStrategy: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}rollover_strategy'])!,
      bossCurrentHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}boss_current_hp'])!,
      bossMaxHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}boss_max_hp'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $CyclesTableTable createAlias(String alias) {
    return $CyclesTableTable(attachedDatabase, alias);
  }
}

class CyclesTableData extends DataClass implements Insertable<CyclesTableData> {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int paydayDay;
  final DateTime? salaryReceivedDate;
  final int inHandSalaryPaise;
  final int fixedExpensesPaise;
  final int savingsTargetPaise;
  final String rolloverStrategy;
  final int bossCurrentHp;
  final int bossMaxHp;
  final bool isArchived;
  const CyclesTableData(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.totalDays,
      required this.paydayDay,
      this.salaryReceivedDate,
      required this.inHandSalaryPaise,
      required this.fixedExpensesPaise,
      required this.savingsTargetPaise,
      required this.rolloverStrategy,
      required this.bossCurrentHp,
      required this.bossMaxHp,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['total_days'] = Variable<int>(totalDays);
    map['payday_day'] = Variable<int>(paydayDay);
    if (!nullToAbsent || salaryReceivedDate != null) {
      map['salary_received_date'] = Variable<DateTime>(salaryReceivedDate);
    }
    map['in_hand_salary_paise'] = Variable<int>(inHandSalaryPaise);
    map['fixed_expenses_paise'] = Variable<int>(fixedExpensesPaise);
    map['savings_target_paise'] = Variable<int>(savingsTargetPaise);
    map['rollover_strategy'] = Variable<String>(rolloverStrategy);
    map['boss_current_hp'] = Variable<int>(bossCurrentHp);
    map['boss_max_hp'] = Variable<int>(bossMaxHp);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  CyclesTableCompanion toCompanion(bool nullToAbsent) {
    return CyclesTableCompanion(
      id: Value(id),
      startDate: Value(startDate),
      endDate: Value(endDate),
      totalDays: Value(totalDays),
      paydayDay: Value(paydayDay),
      salaryReceivedDate: salaryReceivedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryReceivedDate),
      inHandSalaryPaise: Value(inHandSalaryPaise),
      fixedExpensesPaise: Value(fixedExpensesPaise),
      savingsTargetPaise: Value(savingsTargetPaise),
      rolloverStrategy: Value(rolloverStrategy),
      bossCurrentHp: Value(bossCurrentHp),
      bossMaxHp: Value(bossMaxHp),
      isArchived: Value(isArchived),
    );
  }

  factory CyclesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclesTableData(
      id: serializer.fromJson<String>(json['id']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      totalDays: serializer.fromJson<int>(json['totalDays']),
      paydayDay: serializer.fromJson<int>(json['paydayDay']),
      salaryReceivedDate:
          serializer.fromJson<DateTime?>(json['salaryReceivedDate']),
      inHandSalaryPaise: serializer.fromJson<int>(json['inHandSalaryPaise']),
      fixedExpensesPaise: serializer.fromJson<int>(json['fixedExpensesPaise']),
      savingsTargetPaise: serializer.fromJson<int>(json['savingsTargetPaise']),
      rolloverStrategy: serializer.fromJson<String>(json['rolloverStrategy']),
      bossCurrentHp: serializer.fromJson<int>(json['bossCurrentHp']),
      bossMaxHp: serializer.fromJson<int>(json['bossMaxHp']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'totalDays': serializer.toJson<int>(totalDays),
      'paydayDay': serializer.toJson<int>(paydayDay),
      'salaryReceivedDate': serializer.toJson<DateTime?>(salaryReceivedDate),
      'inHandSalaryPaise': serializer.toJson<int>(inHandSalaryPaise),
      'fixedExpensesPaise': serializer.toJson<int>(fixedExpensesPaise),
      'savingsTargetPaise': serializer.toJson<int>(savingsTargetPaise),
      'rolloverStrategy': serializer.toJson<String>(rolloverStrategy),
      'bossCurrentHp': serializer.toJson<int>(bossCurrentHp),
      'bossMaxHp': serializer.toJson<int>(bossMaxHp),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  CyclesTableData copyWith(
          {String? id,
          DateTime? startDate,
          DateTime? endDate,
          int? totalDays,
          int? paydayDay,
          Value<DateTime?> salaryReceivedDate = const Value.absent(),
          int? inHandSalaryPaise,
          int? fixedExpensesPaise,
          int? savingsTargetPaise,
          String? rolloverStrategy,
          int? bossCurrentHp,
          int? bossMaxHp,
          bool? isArchived}) =>
      CyclesTableData(
        id: id ?? this.id,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        totalDays: totalDays ?? this.totalDays,
        paydayDay: paydayDay ?? this.paydayDay,
        salaryReceivedDate: salaryReceivedDate.present
            ? salaryReceivedDate.value
            : this.salaryReceivedDate,
        inHandSalaryPaise: inHandSalaryPaise ?? this.inHandSalaryPaise,
        fixedExpensesPaise: fixedExpensesPaise ?? this.fixedExpensesPaise,
        savingsTargetPaise: savingsTargetPaise ?? this.savingsTargetPaise,
        rolloverStrategy: rolloverStrategy ?? this.rolloverStrategy,
        bossCurrentHp: bossCurrentHp ?? this.bossCurrentHp,
        bossMaxHp: bossMaxHp ?? this.bossMaxHp,
        isArchived: isArchived ?? this.isArchived,
      );
  CyclesTableData copyWithCompanion(CyclesTableCompanion data) {
    return CyclesTableData(
      id: data.id.present ? data.id.value : this.id,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      totalDays: data.totalDays.present ? data.totalDays.value : this.totalDays,
      paydayDay: data.paydayDay.present ? data.paydayDay.value : this.paydayDay,
      salaryReceivedDate: data.salaryReceivedDate.present
          ? data.salaryReceivedDate.value
          : this.salaryReceivedDate,
      inHandSalaryPaise: data.inHandSalaryPaise.present
          ? data.inHandSalaryPaise.value
          : this.inHandSalaryPaise,
      fixedExpensesPaise: data.fixedExpensesPaise.present
          ? data.fixedExpensesPaise.value
          : this.fixedExpensesPaise,
      savingsTargetPaise: data.savingsTargetPaise.present
          ? data.savingsTargetPaise.value
          : this.savingsTargetPaise,
      rolloverStrategy: data.rolloverStrategy.present
          ? data.rolloverStrategy.value
          : this.rolloverStrategy,
      bossCurrentHp: data.bossCurrentHp.present
          ? data.bossCurrentHp.value
          : this.bossCurrentHp,
      bossMaxHp: data.bossMaxHp.present ? data.bossMaxHp.value : this.bossMaxHp,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclesTableData(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('totalDays: $totalDays, ')
          ..write('paydayDay: $paydayDay, ')
          ..write('salaryReceivedDate: $salaryReceivedDate, ')
          ..write('inHandSalaryPaise: $inHandSalaryPaise, ')
          ..write('fixedExpensesPaise: $fixedExpensesPaise, ')
          ..write('savingsTargetPaise: $savingsTargetPaise, ')
          ..write('rolloverStrategy: $rolloverStrategy, ')
          ..write('bossCurrentHp: $bossCurrentHp, ')
          ..write('bossMaxHp: $bossMaxHp, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      startDate,
      endDate,
      totalDays,
      paydayDay,
      salaryReceivedDate,
      inHandSalaryPaise,
      fixedExpensesPaise,
      savingsTargetPaise,
      rolloverStrategy,
      bossCurrentHp,
      bossMaxHp,
      isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclesTableData &&
          other.id == this.id &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.totalDays == this.totalDays &&
          other.paydayDay == this.paydayDay &&
          other.salaryReceivedDate == this.salaryReceivedDate &&
          other.inHandSalaryPaise == this.inHandSalaryPaise &&
          other.fixedExpensesPaise == this.fixedExpensesPaise &&
          other.savingsTargetPaise == this.savingsTargetPaise &&
          other.rolloverStrategy == this.rolloverStrategy &&
          other.bossCurrentHp == this.bossCurrentHp &&
          other.bossMaxHp == this.bossMaxHp &&
          other.isArchived == this.isArchived);
}

class CyclesTableCompanion extends UpdateCompanion<CyclesTableData> {
  final Value<String> id;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int> totalDays;
  final Value<int> paydayDay;
  final Value<DateTime?> salaryReceivedDate;
  final Value<int> inHandSalaryPaise;
  final Value<int> fixedExpensesPaise;
  final Value<int> savingsTargetPaise;
  final Value<String> rolloverStrategy;
  final Value<int> bossCurrentHp;
  final Value<int> bossMaxHp;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const CyclesTableCompanion({
    this.id = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.totalDays = const Value.absent(),
    this.paydayDay = const Value.absent(),
    this.salaryReceivedDate = const Value.absent(),
    this.inHandSalaryPaise = const Value.absent(),
    this.fixedExpensesPaise = const Value.absent(),
    this.savingsTargetPaise = const Value.absent(),
    this.rolloverStrategy = const Value.absent(),
    this.bossCurrentHp = const Value.absent(),
    this.bossMaxHp = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CyclesTableCompanion.insert({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
    required int totalDays,
    this.paydayDay = const Value.absent(),
    this.salaryReceivedDate = const Value.absent(),
    required int inHandSalaryPaise,
    required int fixedExpensesPaise,
    required int savingsTargetPaise,
    this.rolloverStrategy = const Value.absent(),
    required int bossCurrentHp,
    required int bossMaxHp,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startDate = Value(startDate),
        endDate = Value(endDate),
        totalDays = Value(totalDays),
        inHandSalaryPaise = Value(inHandSalaryPaise),
        fixedExpensesPaise = Value(fixedExpensesPaise),
        savingsTargetPaise = Value(savingsTargetPaise),
        bossCurrentHp = Value(bossCurrentHp),
        bossMaxHp = Value(bossMaxHp);
  static Insertable<CyclesTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? totalDays,
    Expression<int>? paydayDay,
    Expression<DateTime>? salaryReceivedDate,
    Expression<int>? inHandSalaryPaise,
    Expression<int>? fixedExpensesPaise,
    Expression<int>? savingsTargetPaise,
    Expression<String>? rolloverStrategy,
    Expression<int>? bossCurrentHp,
    Expression<int>? bossMaxHp,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (totalDays != null) 'total_days': totalDays,
      if (paydayDay != null) 'payday_day': paydayDay,
      if (salaryReceivedDate != null)
        'salary_received_date': salaryReceivedDate,
      if (inHandSalaryPaise != null) 'in_hand_salary_paise': inHandSalaryPaise,
      if (fixedExpensesPaise != null)
        'fixed_expenses_paise': fixedExpensesPaise,
      if (savingsTargetPaise != null)
        'savings_target_paise': savingsTargetPaise,
      if (rolloverStrategy != null) 'rollover_strategy': rolloverStrategy,
      if (bossCurrentHp != null) 'boss_current_hp': bossCurrentHp,
      if (bossMaxHp != null) 'boss_max_hp': bossMaxHp,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CyclesTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<int>? totalDays,
      Value<int>? paydayDay,
      Value<DateTime?>? salaryReceivedDate,
      Value<int>? inHandSalaryPaise,
      Value<int>? fixedExpensesPaise,
      Value<int>? savingsTargetPaise,
      Value<String>? rolloverStrategy,
      Value<int>? bossCurrentHp,
      Value<int>? bossMaxHp,
      Value<bool>? isArchived,
      Value<int>? rowid}) {
    return CyclesTableCompanion(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      paydayDay: paydayDay ?? this.paydayDay,
      salaryReceivedDate: salaryReceivedDate ?? this.salaryReceivedDate,
      inHandSalaryPaise: inHandSalaryPaise ?? this.inHandSalaryPaise,
      fixedExpensesPaise: fixedExpensesPaise ?? this.fixedExpensesPaise,
      savingsTargetPaise: savingsTargetPaise ?? this.savingsTargetPaise,
      rolloverStrategy: rolloverStrategy ?? this.rolloverStrategy,
      bossCurrentHp: bossCurrentHp ?? this.bossCurrentHp,
      bossMaxHp: bossMaxHp ?? this.bossMaxHp,
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
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (totalDays.present) {
      map['total_days'] = Variable<int>(totalDays.value);
    }
    if (paydayDay.present) {
      map['payday_day'] = Variable<int>(paydayDay.value);
    }
    if (salaryReceivedDate.present) {
      map['salary_received_date'] =
          Variable<DateTime>(salaryReceivedDate.value);
    }
    if (inHandSalaryPaise.present) {
      map['in_hand_salary_paise'] = Variable<int>(inHandSalaryPaise.value);
    }
    if (fixedExpensesPaise.present) {
      map['fixed_expenses_paise'] = Variable<int>(fixedExpensesPaise.value);
    }
    if (savingsTargetPaise.present) {
      map['savings_target_paise'] = Variable<int>(savingsTargetPaise.value);
    }
    if (rolloverStrategy.present) {
      map['rollover_strategy'] = Variable<String>(rolloverStrategy.value);
    }
    if (bossCurrentHp.present) {
      map['boss_current_hp'] = Variable<int>(bossCurrentHp.value);
    }
    if (bossMaxHp.present) {
      map['boss_max_hp'] = Variable<int>(bossMaxHp.value);
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
    return (StringBuffer('CyclesTableCompanion(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('totalDays: $totalDays, ')
          ..write('paydayDay: $paydayDay, ')
          ..write('salaryReceivedDate: $salaryReceivedDate, ')
          ..write('inHandSalaryPaise: $inHandSalaryPaise, ')
          ..write('fixedExpensesPaise: $fixedExpensesPaise, ')
          ..write('savingsTargetPaise: $savingsTargetPaise, ')
          ..write('rolloverStrategy: $rolloverStrategy, ')
          ..write('bossCurrentHp: $bossCurrentHp, ')
          ..write('bossMaxHp: $bossMaxHp, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyBudgetsTableTable extends DailyBudgetsTable
    with TableInfo<$DailyBudgetsTableTable, DailyBudgetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyBudgetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cycleIdMeta =
      const VerificationMeta('cycleId');
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
      'cycle_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cycles_table (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dayIndexMeta =
      const VerificationMeta('dayIndex');
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
      'day_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _allocatedBudgetPaiseMeta =
      const VerificationMeta('allocatedBudgetPaise');
  @override
  late final GeneratedColumn<int> allocatedBudgetPaise = GeneratedColumn<int>(
      'allocated_budget_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actualSpentPaiseMeta =
      const VerificationMeta('actualSpentPaise');
  @override
  late final GeneratedColumn<int> actualSpentPaise = GeneratedColumn<int>(
      'actual_spent_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isClosedMeta =
      const VerificationMeta('isClosed');
  @override
  late final GeneratedColumn<bool> isClosed = GeneratedColumn<bool>(
      'is_closed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_closed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cycleId,
        date,
        dayIndex,
        allocatedBudgetPaise,
        actualSpentPaise,
        isClosed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_budgets_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<DailyBudgetsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(_cycleIdMeta,
          cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta));
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(_dayIndexMeta,
          dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta));
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('allocated_budget_paise')) {
      context.handle(
          _allocatedBudgetPaiseMeta,
          allocatedBudgetPaise.isAcceptableOrUnknown(
              data['allocated_budget_paise']!, _allocatedBudgetPaiseMeta));
    } else if (isInserting) {
      context.missing(_allocatedBudgetPaiseMeta);
    }
    if (data.containsKey('actual_spent_paise')) {
      context.handle(
          _actualSpentPaiseMeta,
          actualSpentPaise.isAcceptableOrUnknown(
              data['actual_spent_paise']!, _actualSpentPaiseMeta));
    } else if (isInserting) {
      context.missing(_actualSpentPaiseMeta);
    }
    if (data.containsKey('is_closed')) {
      context.handle(_isClosedMeta,
          isClosed.isAcceptableOrUnknown(data['is_closed']!, _isClosedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyBudgetsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyBudgetsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cycleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cycle_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      dayIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_index'])!,
      allocatedBudgetPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}allocated_budget_paise'])!,
      actualSpentPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}actual_spent_paise'])!,
      isClosed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_closed'])!,
    );
  }

  @override
  $DailyBudgetsTableTable createAlias(String alias) {
    return $DailyBudgetsTableTable(attachedDatabase, alias);
  }
}

class DailyBudgetsTableData extends DataClass
    implements Insertable<DailyBudgetsTableData> {
  final String id;
  final String cycleId;
  final DateTime date;
  final int dayIndex;
  final int allocatedBudgetPaise;
  final int actualSpentPaise;
  final bool isClosed;
  const DailyBudgetsTableData(
      {required this.id,
      required this.cycleId,
      required this.date,
      required this.dayIndex,
      required this.allocatedBudgetPaise,
      required this.actualSpentPaise,
      required this.isClosed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<String>(cycleId);
    map['date'] = Variable<DateTime>(date);
    map['day_index'] = Variable<int>(dayIndex);
    map['allocated_budget_paise'] = Variable<int>(allocatedBudgetPaise);
    map['actual_spent_paise'] = Variable<int>(actualSpentPaise);
    map['is_closed'] = Variable<bool>(isClosed);
    return map;
  }

  DailyBudgetsTableCompanion toCompanion(bool nullToAbsent) {
    return DailyBudgetsTableCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      date: Value(date),
      dayIndex: Value(dayIndex),
      allocatedBudgetPaise: Value(allocatedBudgetPaise),
      actualSpentPaise: Value(actualSpentPaise),
      isClosed: Value(isClosed),
    );
  }

  factory DailyBudgetsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyBudgetsTableData(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      date: serializer.fromJson<DateTime>(json['date']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      allocatedBudgetPaise:
          serializer.fromJson<int>(json['allocatedBudgetPaise']),
      actualSpentPaise: serializer.fromJson<int>(json['actualSpentPaise']),
      isClosed: serializer.fromJson<bool>(json['isClosed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<String>(cycleId),
      'date': serializer.toJson<DateTime>(date),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'allocatedBudgetPaise': serializer.toJson<int>(allocatedBudgetPaise),
      'actualSpentPaise': serializer.toJson<int>(actualSpentPaise),
      'isClosed': serializer.toJson<bool>(isClosed),
    };
  }

  DailyBudgetsTableData copyWith(
          {String? id,
          String? cycleId,
          DateTime? date,
          int? dayIndex,
          int? allocatedBudgetPaise,
          int? actualSpentPaise,
          bool? isClosed}) =>
      DailyBudgetsTableData(
        id: id ?? this.id,
        cycleId: cycleId ?? this.cycleId,
        date: date ?? this.date,
        dayIndex: dayIndex ?? this.dayIndex,
        allocatedBudgetPaise: allocatedBudgetPaise ?? this.allocatedBudgetPaise,
        actualSpentPaise: actualSpentPaise ?? this.actualSpentPaise,
        isClosed: isClosed ?? this.isClosed,
      );
  DailyBudgetsTableData copyWithCompanion(DailyBudgetsTableCompanion data) {
    return DailyBudgetsTableData(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      date: data.date.present ? data.date.value : this.date,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      allocatedBudgetPaise: data.allocatedBudgetPaise.present
          ? data.allocatedBudgetPaise.value
          : this.allocatedBudgetPaise,
      actualSpentPaise: data.actualSpentPaise.present
          ? data.actualSpentPaise.value
          : this.actualSpentPaise,
      isClosed: data.isClosed.present ? data.isClosed.value : this.isClosed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudgetsTableData(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('date: $date, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('allocatedBudgetPaise: $allocatedBudgetPaise, ')
          ..write('actualSpentPaise: $actualSpentPaise, ')
          ..write('isClosed: $isClosed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cycleId, date, dayIndex,
      allocatedBudgetPaise, actualSpentPaise, isClosed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyBudgetsTableData &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.date == this.date &&
          other.dayIndex == this.dayIndex &&
          other.allocatedBudgetPaise == this.allocatedBudgetPaise &&
          other.actualSpentPaise == this.actualSpentPaise &&
          other.isClosed == this.isClosed);
}

class DailyBudgetsTableCompanion
    extends UpdateCompanion<DailyBudgetsTableData> {
  final Value<String> id;
  final Value<String> cycleId;
  final Value<DateTime> date;
  final Value<int> dayIndex;
  final Value<int> allocatedBudgetPaise;
  final Value<int> actualSpentPaise;
  final Value<bool> isClosed;
  final Value<int> rowid;
  const DailyBudgetsTableCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.date = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.allocatedBudgetPaise = const Value.absent(),
    this.actualSpentPaise = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyBudgetsTableCompanion.insert({
    required String id,
    required String cycleId,
    required DateTime date,
    required int dayIndex,
    required int allocatedBudgetPaise,
    required int actualSpentPaise,
    this.isClosed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cycleId = Value(cycleId),
        date = Value(date),
        dayIndex = Value(dayIndex),
        allocatedBudgetPaise = Value(allocatedBudgetPaise),
        actualSpentPaise = Value(actualSpentPaise);
  static Insertable<DailyBudgetsTableData> custom({
    Expression<String>? id,
    Expression<String>? cycleId,
    Expression<DateTime>? date,
    Expression<int>? dayIndex,
    Expression<int>? allocatedBudgetPaise,
    Expression<int>? actualSpentPaise,
    Expression<bool>? isClosed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (date != null) 'date': date,
      if (dayIndex != null) 'day_index': dayIndex,
      if (allocatedBudgetPaise != null)
        'allocated_budget_paise': allocatedBudgetPaise,
      if (actualSpentPaise != null) 'actual_spent_paise': actualSpentPaise,
      if (isClosed != null) 'is_closed': isClosed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyBudgetsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? cycleId,
      Value<DateTime>? date,
      Value<int>? dayIndex,
      Value<int>? allocatedBudgetPaise,
      Value<int>? actualSpentPaise,
      Value<bool>? isClosed,
      Value<int>? rowid}) {
    return DailyBudgetsTableCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      date: date ?? this.date,
      dayIndex: dayIndex ?? this.dayIndex,
      allocatedBudgetPaise: allocatedBudgetPaise ?? this.allocatedBudgetPaise,
      actualSpentPaise: actualSpentPaise ?? this.actualSpentPaise,
      isClosed: isClosed ?? this.isClosed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (allocatedBudgetPaise.present) {
      map['allocated_budget_paise'] = Variable<int>(allocatedBudgetPaise.value);
    }
    if (actualSpentPaise.present) {
      map['actual_spent_paise'] = Variable<int>(actualSpentPaise.value);
    }
    if (isClosed.present) {
      map['is_closed'] = Variable<bool>(isClosed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudgetsTableCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('date: $date, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('allocatedBudgetPaise: $allocatedBudgetPaise, ')
          ..write('actualSpentPaise: $actualSpentPaise, ')
          ..write('isClosed: $isClosed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cycleIdMeta =
      const VerificationMeta('cycleId');
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
      'cycle_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountPaiseMeta =
      const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
      'amount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _isFixedExpenseMeta =
      const VerificationMeta('isFixedExpense');
  @override
  late final GeneratedColumn<bool> isFixedExpense = GeneratedColumn<bool>(
      'is_fixed_expense', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_fixed_expense" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('expense'));
  static const VerificationMeta _dedupeKeyMeta =
      const VerificationMeta('dedupeKey');
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
      'dedupe_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _earnedXpMeta =
      const VerificationMeta('earnedXp');
  @override
  late final GeneratedColumn<int> earnedXp = GeneratedColumn<int>(
      'earned_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _earnedCoinsMeta =
      const VerificationMeta('earnedCoins');
  @override
  late final GeneratedColumn<int> earnedCoins = GeneratedColumn<int>(
      'earned_coins', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _splitTotalPaiseMeta =
      const VerificationMeta('splitTotalPaise');
  @override
  late final GeneratedColumn<int> splitTotalPaise = GeneratedColumn<int>(
      'split_total_paise', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _splitUserSharePaiseMeta =
      const VerificationMeta('splitUserSharePaise');
  @override
  late final GeneratedColumn<int> splitUserSharePaise = GeneratedColumn<int>(
      'split_user_share_paise', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pendingReimbursementPaiseMeta =
      const VerificationMeta('pendingReimbursementPaise');
  @override
  late final GeneratedColumn<int> pendingReimbursementPaise =
      GeneratedColumn<int>('pending_reimbursement_paise', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isReimbursementMeta =
      const VerificationMeta('isReimbursement');
  @override
  late final GeneratedColumn<bool> isReimbursement = GeneratedColumn<bool>(
      'is_reimbursement', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_reimbursement" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _parentTransactionIdMeta =
      const VerificationMeta('parentTransactionId');
  @override
  late final GeneratedColumn<String> parentTransactionId =
      GeneratedColumn<String>('parent_transaction_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cycleId,
        amountPaise,
        title,
        category,
        timestamp,
        source,
        isFixedExpense,
        transactionType,
        dedupeKey,
        earnedXp,
        earnedCoins,
        splitTotalPaise,
        splitUserSharePaise,
        pendingReimbursementPaise,
        isReimbursement,
        parentTransactionId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(_cycleIdMeta,
          cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta));
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
          _amountPaiseMeta,
          amountPaise.isAcceptableOrUnknown(
              data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('is_fixed_expense')) {
      context.handle(
          _isFixedExpenseMeta,
          isFixedExpense.isAcceptableOrUnknown(
              data['is_fixed_expense']!, _isFixedExpenseMeta));
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(_dedupeKeyMeta,
          dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta));
    }
    if (data.containsKey('earned_xp')) {
      context.handle(_earnedXpMeta,
          earnedXp.isAcceptableOrUnknown(data['earned_xp']!, _earnedXpMeta));
    }
    if (data.containsKey('earned_coins')) {
      context.handle(
          _earnedCoinsMeta,
          earnedCoins.isAcceptableOrUnknown(
              data['earned_coins']!, _earnedCoinsMeta));
    }
    if (data.containsKey('split_total_paise')) {
      context.handle(
          _splitTotalPaiseMeta,
          splitTotalPaise.isAcceptableOrUnknown(
              data['split_total_paise']!, _splitTotalPaiseMeta));
    }
    if (data.containsKey('split_user_share_paise')) {
      context.handle(
          _splitUserSharePaiseMeta,
          splitUserSharePaise.isAcceptableOrUnknown(
              data['split_user_share_paise']!, _splitUserSharePaiseMeta));
    }
    if (data.containsKey('pending_reimbursement_paise')) {
      context.handle(
          _pendingReimbursementPaiseMeta,
          pendingReimbursementPaise.isAcceptableOrUnknown(
              data['pending_reimbursement_paise']!,
              _pendingReimbursementPaiseMeta));
    }
    if (data.containsKey('is_reimbursement')) {
      context.handle(
          _isReimbursementMeta,
          isReimbursement.isAcceptableOrUnknown(
              data['is_reimbursement']!, _isReimbursementMeta));
    }
    if (data.containsKey('parent_transaction_id')) {
      context.handle(
          _parentTransactionIdMeta,
          parentTransactionId.isAcceptableOrUnknown(
              data['parent_transaction_id']!, _parentTransactionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cycleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cycle_id'])!,
      amountPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      isFixedExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_fixed_expense'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      dedupeKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dedupe_key']),
      earnedXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}earned_xp'])!,
      earnedCoins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}earned_coins'])!,
      splitTotalPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}split_total_paise']),
      splitUserSharePaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}split_user_share_paise']),
      pendingReimbursementPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}pending_reimbursement_paise']),
      isReimbursement: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_reimbursement'])!,
      parentTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_transaction_id']),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final String id;
  final String cycleId;
  final int amountPaise;
  final String title;
  final String category;
  final DateTime timestamp;
  final String source;
  final bool isFixedExpense;
  final String transactionType;
  final String? dedupeKey;
  final int earnedXp;
  final int earnedCoins;
  final int? splitTotalPaise;
  final int? splitUserSharePaise;
  final int? pendingReimbursementPaise;
  final bool isReimbursement;
  final String? parentTransactionId;
  const TransactionsTableData(
      {required this.id,
      required this.cycleId,
      required this.amountPaise,
      required this.title,
      required this.category,
      required this.timestamp,
      required this.source,
      required this.isFixedExpense,
      required this.transactionType,
      this.dedupeKey,
      required this.earnedXp,
      required this.earnedCoins,
      this.splitTotalPaise,
      this.splitUserSharePaise,
      this.pendingReimbursementPaise,
      required this.isReimbursement,
      this.parentTransactionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cycle_id'] = Variable<String>(cycleId);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['source'] = Variable<String>(source);
    map['is_fixed_expense'] = Variable<bool>(isFixedExpense);
    map['transaction_type'] = Variable<String>(transactionType);
    if (!nullToAbsent || dedupeKey != null) {
      map['dedupe_key'] = Variable<String>(dedupeKey);
    }
    map['earned_xp'] = Variable<int>(earnedXp);
    map['earned_coins'] = Variable<int>(earnedCoins);
    if (!nullToAbsent || splitTotalPaise != null) {
      map['split_total_paise'] = Variable<int>(splitTotalPaise);
    }
    if (!nullToAbsent || splitUserSharePaise != null) {
      map['split_user_share_paise'] = Variable<int>(splitUserSharePaise);
    }
    if (!nullToAbsent || pendingReimbursementPaise != null) {
      map['pending_reimbursement_paise'] =
          Variable<int>(pendingReimbursementPaise);
    }
    map['is_reimbursement'] = Variable<bool>(isReimbursement);
    if (!nullToAbsent || parentTransactionId != null) {
      map['parent_transaction_id'] = Variable<String>(parentTransactionId);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      cycleId: Value(cycleId),
      amountPaise: Value(amountPaise),
      title: Value(title),
      category: Value(category),
      timestamp: Value(timestamp),
      source: Value(source),
      isFixedExpense: Value(isFixedExpense),
      transactionType: Value(transactionType),
      dedupeKey: dedupeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dedupeKey),
      earnedXp: Value(earnedXp),
      earnedCoins: Value(earnedCoins),
      splitTotalPaise: splitTotalPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(splitTotalPaise),
      splitUserSharePaise: splitUserSharePaise == null && nullToAbsent
          ? const Value.absent()
          : Value(splitUserSharePaise),
      pendingReimbursementPaise:
          pendingReimbursementPaise == null && nullToAbsent
              ? const Value.absent()
              : Value(pendingReimbursementPaise),
      isReimbursement: Value(isReimbursement),
      parentTransactionId: parentTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTransactionId),
    );
  }

  factory TransactionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      source: serializer.fromJson<String>(json['source']),
      isFixedExpense: serializer.fromJson<bool>(json['isFixedExpense']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      dedupeKey: serializer.fromJson<String?>(json['dedupeKey']),
      earnedXp: serializer.fromJson<int>(json['earnedXp']),
      earnedCoins: serializer.fromJson<int>(json['earnedCoins']),
      splitTotalPaise: serializer.fromJson<int?>(json['splitTotalPaise']),
      splitUserSharePaise:
          serializer.fromJson<int?>(json['splitUserSharePaise']),
      pendingReimbursementPaise:
          serializer.fromJson<int?>(json['pendingReimbursementPaise']),
      isReimbursement: serializer.fromJson<bool>(json['isReimbursement']),
      parentTransactionId:
          serializer.fromJson<String?>(json['parentTransactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cycleId': serializer.toJson<String>(cycleId),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'source': serializer.toJson<String>(source),
      'isFixedExpense': serializer.toJson<bool>(isFixedExpense),
      'transactionType': serializer.toJson<String>(transactionType),
      'dedupeKey': serializer.toJson<String?>(dedupeKey),
      'earnedXp': serializer.toJson<int>(earnedXp),
      'earnedCoins': serializer.toJson<int>(earnedCoins),
      'splitTotalPaise': serializer.toJson<int?>(splitTotalPaise),
      'splitUserSharePaise': serializer.toJson<int?>(splitUserSharePaise),
      'pendingReimbursementPaise':
          serializer.toJson<int?>(pendingReimbursementPaise),
      'isReimbursement': serializer.toJson<bool>(isReimbursement),
      'parentTransactionId': serializer.toJson<String?>(parentTransactionId),
    };
  }

  TransactionsTableData copyWith(
          {String? id,
          String? cycleId,
          int? amountPaise,
          String? title,
          String? category,
          DateTime? timestamp,
          String? source,
          bool? isFixedExpense,
          String? transactionType,
          Value<String?> dedupeKey = const Value.absent(),
          int? earnedXp,
          int? earnedCoins,
          Value<int?> splitTotalPaise = const Value.absent(),
          Value<int?> splitUserSharePaise = const Value.absent(),
          Value<int?> pendingReimbursementPaise = const Value.absent(),
          bool? isReimbursement,
          Value<String?> parentTransactionId = const Value.absent()}) =>
      TransactionsTableData(
        id: id ?? this.id,
        cycleId: cycleId ?? this.cycleId,
        amountPaise: amountPaise ?? this.amountPaise,
        title: title ?? this.title,
        category: category ?? this.category,
        timestamp: timestamp ?? this.timestamp,
        source: source ?? this.source,
        isFixedExpense: isFixedExpense ?? this.isFixedExpense,
        transactionType: transactionType ?? this.transactionType,
        dedupeKey: dedupeKey.present ? dedupeKey.value : this.dedupeKey,
        earnedXp: earnedXp ?? this.earnedXp,
        earnedCoins: earnedCoins ?? this.earnedCoins,
        splitTotalPaise: splitTotalPaise.present
            ? splitTotalPaise.value
            : this.splitTotalPaise,
        splitUserSharePaise: splitUserSharePaise.present
            ? splitUserSharePaise.value
            : this.splitUserSharePaise,
        pendingReimbursementPaise: pendingReimbursementPaise.present
            ? pendingReimbursementPaise.value
            : this.pendingReimbursementPaise,
        isReimbursement: isReimbursement ?? this.isReimbursement,
        parentTransactionId: parentTransactionId.present
            ? parentTransactionId.value
            : this.parentTransactionId,
      );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      amountPaise:
          data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      source: data.source.present ? data.source.value : this.source,
      isFixedExpense: data.isFixedExpense.present
          ? data.isFixedExpense.value
          : this.isFixedExpense,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      earnedXp: data.earnedXp.present ? data.earnedXp.value : this.earnedXp,
      earnedCoins:
          data.earnedCoins.present ? data.earnedCoins.value : this.earnedCoins,
      splitTotalPaise: data.splitTotalPaise.present
          ? data.splitTotalPaise.value
          : this.splitTotalPaise,
      splitUserSharePaise: data.splitUserSharePaise.present
          ? data.splitUserSharePaise.value
          : this.splitUserSharePaise,
      pendingReimbursementPaise: data.pendingReimbursementPaise.present
          ? data.pendingReimbursementPaise.value
          : this.pendingReimbursementPaise,
      isReimbursement: data.isReimbursement.present
          ? data.isReimbursement.value
          : this.isReimbursement,
      parentTransactionId: data.parentTransactionId.present
          ? data.parentTransactionId.value
          : this.parentTransactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('timestamp: $timestamp, ')
          ..write('source: $source, ')
          ..write('isFixedExpense: $isFixedExpense, ')
          ..write('transactionType: $transactionType, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('earnedXp: $earnedXp, ')
          ..write('earnedCoins: $earnedCoins, ')
          ..write('splitTotalPaise: $splitTotalPaise, ')
          ..write('splitUserSharePaise: $splitUserSharePaise, ')
          ..write('pendingReimbursementPaise: $pendingReimbursementPaise, ')
          ..write('isReimbursement: $isReimbursement, ')
          ..write('parentTransactionId: $parentTransactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cycleId,
      amountPaise,
      title,
      category,
      timestamp,
      source,
      isFixedExpense,
      transactionType,
      dedupeKey,
      earnedXp,
      earnedCoins,
      splitTotalPaise,
      splitUserSharePaise,
      pendingReimbursementPaise,
      isReimbursement,
      parentTransactionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.cycleId == this.cycleId &&
          other.amountPaise == this.amountPaise &&
          other.title == this.title &&
          other.category == this.category &&
          other.timestamp == this.timestamp &&
          other.source == this.source &&
          other.isFixedExpense == this.isFixedExpense &&
          other.transactionType == this.transactionType &&
          other.dedupeKey == this.dedupeKey &&
          other.earnedXp == this.earnedXp &&
          other.earnedCoins == this.earnedCoins &&
          other.splitTotalPaise == this.splitTotalPaise &&
          other.splitUserSharePaise == this.splitUserSharePaise &&
          other.pendingReimbursementPaise == this.pendingReimbursementPaise &&
          other.isReimbursement == this.isReimbursement &&
          other.parentTransactionId == this.parentTransactionId);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<String> id;
  final Value<String> cycleId;
  final Value<int> amountPaise;
  final Value<String> title;
  final Value<String> category;
  final Value<DateTime> timestamp;
  final Value<String> source;
  final Value<bool> isFixedExpense;
  final Value<String> transactionType;
  final Value<String?> dedupeKey;
  final Value<int> earnedXp;
  final Value<int> earnedCoins;
  final Value<int?> splitTotalPaise;
  final Value<int?> splitUserSharePaise;
  final Value<int?> pendingReimbursementPaise;
  final Value<bool> isReimbursement;
  final Value<String?> parentTransactionId;
  final Value<int> rowid;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.source = const Value.absent(),
    this.isFixedExpense = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.earnedXp = const Value.absent(),
    this.earnedCoins = const Value.absent(),
    this.splitTotalPaise = const Value.absent(),
    this.splitUserSharePaise = const Value.absent(),
    this.pendingReimbursementPaise = const Value.absent(),
    this.isReimbursement = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    required String cycleId,
    required int amountPaise,
    required String title,
    required String category,
    required DateTime timestamp,
    this.source = const Value.absent(),
    this.isFixedExpense = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.earnedXp = const Value.absent(),
    this.earnedCoins = const Value.absent(),
    this.splitTotalPaise = const Value.absent(),
    this.splitUserSharePaise = const Value.absent(),
    this.pendingReimbursementPaise = const Value.absent(),
    this.isReimbursement = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cycleId = Value(cycleId),
        amountPaise = Value(amountPaise),
        title = Value(title),
        category = Value(category),
        timestamp = Value(timestamp);
  static Insertable<TransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? cycleId,
    Expression<int>? amountPaise,
    Expression<String>? title,
    Expression<String>? category,
    Expression<DateTime>? timestamp,
    Expression<String>? source,
    Expression<bool>? isFixedExpense,
    Expression<String>? transactionType,
    Expression<String>? dedupeKey,
    Expression<int>? earnedXp,
    Expression<int>? earnedCoins,
    Expression<int>? splitTotalPaise,
    Expression<int>? splitUserSharePaise,
    Expression<int>? pendingReimbursementPaise,
    Expression<bool>? isReimbursement,
    Expression<String>? parentTransactionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleId != null) 'cycle_id': cycleId,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (timestamp != null) 'timestamp': timestamp,
      if (source != null) 'source': source,
      if (isFixedExpense != null) 'is_fixed_expense': isFixedExpense,
      if (transactionType != null) 'transaction_type': transactionType,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (earnedXp != null) 'earned_xp': earnedXp,
      if (earnedCoins != null) 'earned_coins': earnedCoins,
      if (splitTotalPaise != null) 'split_total_paise': splitTotalPaise,
      if (splitUserSharePaise != null)
        'split_user_share_paise': splitUserSharePaise,
      if (pendingReimbursementPaise != null)
        'pending_reimbursement_paise': pendingReimbursementPaise,
      if (isReimbursement != null) 'is_reimbursement': isReimbursement,
      if (parentTransactionId != null)
        'parent_transaction_id': parentTransactionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? cycleId,
      Value<int>? amountPaise,
      Value<String>? title,
      Value<String>? category,
      Value<DateTime>? timestamp,
      Value<String>? source,
      Value<bool>? isFixedExpense,
      Value<String>? transactionType,
      Value<String?>? dedupeKey,
      Value<int>? earnedXp,
      Value<int>? earnedCoins,
      Value<int?>? splitTotalPaise,
      Value<int?>? splitUserSharePaise,
      Value<int?>? pendingReimbursementPaise,
      Value<bool>? isReimbursement,
      Value<String?>? parentTransactionId,
      Value<int>? rowid}) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      amountPaise: amountPaise ?? this.amountPaise,
      title: title ?? this.title,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      isFixedExpense: isFixedExpense ?? this.isFixedExpense,
      transactionType: transactionType ?? this.transactionType,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      earnedXp: earnedXp ?? this.earnedXp,
      earnedCoins: earnedCoins ?? this.earnedCoins,
      splitTotalPaise: splitTotalPaise ?? this.splitTotalPaise,
      splitUserSharePaise: splitUserSharePaise ?? this.splitUserSharePaise,
      pendingReimbursementPaise:
          pendingReimbursementPaise ?? this.pendingReimbursementPaise,
      isReimbursement: isReimbursement ?? this.isReimbursement,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isFixedExpense.present) {
      map['is_fixed_expense'] = Variable<bool>(isFixedExpense.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (earnedXp.present) {
      map['earned_xp'] = Variable<int>(earnedXp.value);
    }
    if (earnedCoins.present) {
      map['earned_coins'] = Variable<int>(earnedCoins.value);
    }
    if (splitTotalPaise.present) {
      map['split_total_paise'] = Variable<int>(splitTotalPaise.value);
    }
    if (splitUserSharePaise.present) {
      map['split_user_share_paise'] = Variable<int>(splitUserSharePaise.value);
    }
    if (pendingReimbursementPaise.present) {
      map['pending_reimbursement_paise'] =
          Variable<int>(pendingReimbursementPaise.value);
    }
    if (isReimbursement.present) {
      map['is_reimbursement'] = Variable<bool>(isReimbursement.value);
    }
    if (parentTransactionId.present) {
      map['parent_transaction_id'] =
          Variable<String>(parentTransactionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('cycleId: $cycleId, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('timestamp: $timestamp, ')
          ..write('source: $source, ')
          ..write('isFixedExpense: $isFixedExpense, ')
          ..write('transactionType: $transactionType, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('earnedXp: $earnedXp, ')
          ..write('earnedCoins: $earnedCoins, ')
          ..write('splitTotalPaise: $splitTotalPaise, ')
          ..write('splitUserSharePaise: $splitUserSharePaise, ')
          ..write('pendingReimbursementPaise: $pendingReimbursementPaise, ')
          ..write('isReimbursement: $isReimbursement, ')
          ..write('parentTransactionId: $parentTransactionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeroStateTableTable extends HeroStateTable
    with TableInfo<$HeroStateTableTable, HeroStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeroStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Aero'));
  static const VerificationMeta _archetypeMeta =
      const VerificationMeta('archetype');
  @override
  late final GeneratedColumn<String> archetype = GeneratedColumn<String>(
      'archetype', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('knight'));
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _currentXpMeta =
      const VerificationMeta('currentXp');
  @override
  late final GeneratedColumn<int> currentXp = GeneratedColumn<int>(
      'current_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxXpMeta = const VerificationMeta('maxXp');
  @override
  late final GeneratedColumn<int> maxXp = GeneratedColumn<int>(
      'max_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _currentHpMeta =
      const VerificationMeta('currentHp');
  @override
  late final GeneratedColumn<int> currentHp = GeneratedColumn<int>(
      'current_hp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _maxHpMeta = const VerificationMeta('maxHp');
  @override
  late final GeneratedColumn<int> maxHp = GeneratedColumn<int>(
      'max_hp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
      'coins', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _streakDaysMeta =
      const VerificationMeta('streakDays');
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
      'streak_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _lastLoginDateMeta =
      const VerificationMeta('lastLoginDate');
  @override
  late final GeneratedColumn<DateTime> lastLoginDate =
      GeneratedColumn<DateTime>('last_login_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _previousStreakDaysMeta =
      const VerificationMeta('previousStreakDays');
  @override
  late final GeneratedColumn<int> previousStreakDays = GeneratedColumn<int>(
      'previous_streak_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _streakShieldAvailableMeta =
      const VerificationMeta('streakShieldAvailable');
  @override
  late final GeneratedColumn<bool> streakShieldAvailable =
      GeneratedColumn<bool>('streak_shield_available', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("streak_shield_available" IN (0, 1))'),
          defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        archetype,
        level,
        currentXp,
        maxXp,
        currentHp,
        maxHp,
        coins,
        streakDays,
        lastLoginDate,
        previousStreakDays,
        streakShieldAvailable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hero_state_table';
  @override
  VerificationContext validateIntegrity(Insertable<HeroStateTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('archetype')) {
      context.handle(_archetypeMeta,
          archetype.isAcceptableOrUnknown(data['archetype']!, _archetypeMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('current_xp')) {
      context.handle(_currentXpMeta,
          currentXp.isAcceptableOrUnknown(data['current_xp']!, _currentXpMeta));
    }
    if (data.containsKey('max_xp')) {
      context.handle(
          _maxXpMeta, maxXp.isAcceptableOrUnknown(data['max_xp']!, _maxXpMeta));
    }
    if (data.containsKey('current_hp')) {
      context.handle(_currentHpMeta,
          currentHp.isAcceptableOrUnknown(data['current_hp']!, _currentHpMeta));
    }
    if (data.containsKey('max_hp')) {
      context.handle(
          _maxHpMeta, maxHp.isAcceptableOrUnknown(data['max_hp']!, _maxHpMeta));
    }
    if (data.containsKey('coins')) {
      context.handle(
          _coinsMeta, coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta));
    }
    if (data.containsKey('streak_days')) {
      context.handle(
          _streakDaysMeta,
          streakDays.isAcceptableOrUnknown(
              data['streak_days']!, _streakDaysMeta));
    }
    if (data.containsKey('last_login_date')) {
      context.handle(
          _lastLoginDateMeta,
          lastLoginDate.isAcceptableOrUnknown(
              data['last_login_date']!, _lastLoginDateMeta));
    }
    if (data.containsKey('previous_streak_days')) {
      context.handle(
          _previousStreakDaysMeta,
          previousStreakDays.isAcceptableOrUnknown(
              data['previous_streak_days']!, _previousStreakDaysMeta));
    }
    if (data.containsKey('streak_shield_available')) {
      context.handle(
          _streakShieldAvailableMeta,
          streakShieldAvailable.isAcceptableOrUnknown(
              data['streak_shield_available']!, _streakShieldAvailableMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HeroStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeroStateTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      archetype: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}archetype'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      currentXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_xp'])!,
      maxXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_xp'])!,
      currentHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_hp'])!,
      maxHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_hp'])!,
      coins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}coins'])!,
      streakDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak_days'])!,
      lastLoginDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_login_date']),
      previousStreakDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}previous_streak_days'])!,
      streakShieldAvailable: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}streak_shield_available'])!,
    );
  }

  @override
  $HeroStateTableTable createAlias(String alias) {
    return $HeroStateTableTable(attachedDatabase, alias);
  }
}

class HeroStateTableData extends DataClass
    implements Insertable<HeroStateTableData> {
  final int id;
  final String name;
  final String archetype;
  final int level;
  final int currentXp;
  final int maxXp;
  final int currentHp;
  final int maxHp;
  final int coins;
  final int streakDays;
  final DateTime? lastLoginDate;
  final int previousStreakDays;
  final bool streakShieldAvailable;
  const HeroStateTableData(
      {required this.id,
      required this.name,
      required this.archetype,
      required this.level,
      required this.currentXp,
      required this.maxXp,
      required this.currentHp,
      required this.maxHp,
      required this.coins,
      required this.streakDays,
      this.lastLoginDate,
      required this.previousStreakDays,
      required this.streakShieldAvailable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['archetype'] = Variable<String>(archetype);
    map['level'] = Variable<int>(level);
    map['current_xp'] = Variable<int>(currentXp);
    map['max_xp'] = Variable<int>(maxXp);
    map['current_hp'] = Variable<int>(currentHp);
    map['max_hp'] = Variable<int>(maxHp);
    map['coins'] = Variable<int>(coins);
    map['streak_days'] = Variable<int>(streakDays);
    if (!nullToAbsent || lastLoginDate != null) {
      map['last_login_date'] = Variable<DateTime>(lastLoginDate);
    }
    map['previous_streak_days'] = Variable<int>(previousStreakDays);
    map['streak_shield_available'] = Variable<bool>(streakShieldAvailable);
    return map;
  }

  HeroStateTableCompanion toCompanion(bool nullToAbsent) {
    return HeroStateTableCompanion(
      id: Value(id),
      name: Value(name),
      archetype: Value(archetype),
      level: Value(level),
      currentXp: Value(currentXp),
      maxXp: Value(maxXp),
      currentHp: Value(currentHp),
      maxHp: Value(maxHp),
      coins: Value(coins),
      streakDays: Value(streakDays),
      lastLoginDate: lastLoginDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginDate),
      previousStreakDays: Value(previousStreakDays),
      streakShieldAvailable: Value(streakShieldAvailable),
    );
  }

  factory HeroStateTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeroStateTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      archetype: serializer.fromJson<String>(json['archetype']),
      level: serializer.fromJson<int>(json['level']),
      currentXp: serializer.fromJson<int>(json['currentXp']),
      maxXp: serializer.fromJson<int>(json['maxXp']),
      currentHp: serializer.fromJson<int>(json['currentHp']),
      maxHp: serializer.fromJson<int>(json['maxHp']),
      coins: serializer.fromJson<int>(json['coins']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      lastLoginDate: serializer.fromJson<DateTime?>(json['lastLoginDate']),
      previousStreakDays: serializer.fromJson<int>(json['previousStreakDays']),
      streakShieldAvailable:
          serializer.fromJson<bool>(json['streakShieldAvailable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'archetype': serializer.toJson<String>(archetype),
      'level': serializer.toJson<int>(level),
      'currentXp': serializer.toJson<int>(currentXp),
      'maxXp': serializer.toJson<int>(maxXp),
      'currentHp': serializer.toJson<int>(currentHp),
      'maxHp': serializer.toJson<int>(maxHp),
      'coins': serializer.toJson<int>(coins),
      'streakDays': serializer.toJson<int>(streakDays),
      'lastLoginDate': serializer.toJson<DateTime?>(lastLoginDate),
      'previousStreakDays': serializer.toJson<int>(previousStreakDays),
      'streakShieldAvailable': serializer.toJson<bool>(streakShieldAvailable),
    };
  }

  HeroStateTableData copyWith(
          {int? id,
          String? name,
          String? archetype,
          int? level,
          int? currentXp,
          int? maxXp,
          int? currentHp,
          int? maxHp,
          int? coins,
          int? streakDays,
          Value<DateTime?> lastLoginDate = const Value.absent(),
          int? previousStreakDays,
          bool? streakShieldAvailable}) =>
      HeroStateTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        archetype: archetype ?? this.archetype,
        level: level ?? this.level,
        currentXp: currentXp ?? this.currentXp,
        maxXp: maxXp ?? this.maxXp,
        currentHp: currentHp ?? this.currentHp,
        maxHp: maxHp ?? this.maxHp,
        coins: coins ?? this.coins,
        streakDays: streakDays ?? this.streakDays,
        lastLoginDate:
            lastLoginDate.present ? lastLoginDate.value : this.lastLoginDate,
        previousStreakDays: previousStreakDays ?? this.previousStreakDays,
        streakShieldAvailable:
            streakShieldAvailable ?? this.streakShieldAvailable,
      );
  HeroStateTableData copyWithCompanion(HeroStateTableCompanion data) {
    return HeroStateTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      archetype: data.archetype.present ? data.archetype.value : this.archetype,
      level: data.level.present ? data.level.value : this.level,
      currentXp: data.currentXp.present ? data.currentXp.value : this.currentXp,
      maxXp: data.maxXp.present ? data.maxXp.value : this.maxXp,
      currentHp: data.currentHp.present ? data.currentHp.value : this.currentHp,
      maxHp: data.maxHp.present ? data.maxHp.value : this.maxHp,
      coins: data.coins.present ? data.coins.value : this.coins,
      streakDays:
          data.streakDays.present ? data.streakDays.value : this.streakDays,
      lastLoginDate: data.lastLoginDate.present
          ? data.lastLoginDate.value
          : this.lastLoginDate,
      previousStreakDays: data.previousStreakDays.present
          ? data.previousStreakDays.value
          : this.previousStreakDays,
      streakShieldAvailable: data.streakShieldAvailable.present
          ? data.streakShieldAvailable.value
          : this.streakShieldAvailable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeroStateTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('archetype: $archetype, ')
          ..write('level: $level, ')
          ..write('currentXp: $currentXp, ')
          ..write('maxXp: $maxXp, ')
          ..write('currentHp: $currentHp, ')
          ..write('maxHp: $maxHp, ')
          ..write('coins: $coins, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastLoginDate: $lastLoginDate, ')
          ..write('previousStreakDays: $previousStreakDays, ')
          ..write('streakShieldAvailable: $streakShieldAvailable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      archetype,
      level,
      currentXp,
      maxXp,
      currentHp,
      maxHp,
      coins,
      streakDays,
      lastLoginDate,
      previousStreakDays,
      streakShieldAvailable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeroStateTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.archetype == this.archetype &&
          other.level == this.level &&
          other.currentXp == this.currentXp &&
          other.maxXp == this.maxXp &&
          other.currentHp == this.currentHp &&
          other.maxHp == this.maxHp &&
          other.coins == this.coins &&
          other.streakDays == this.streakDays &&
          other.lastLoginDate == this.lastLoginDate &&
          other.previousStreakDays == this.previousStreakDays &&
          other.streakShieldAvailable == this.streakShieldAvailable);
}

class HeroStateTableCompanion extends UpdateCompanion<HeroStateTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> archetype;
  final Value<int> level;
  final Value<int> currentXp;
  final Value<int> maxXp;
  final Value<int> currentHp;
  final Value<int> maxHp;
  final Value<int> coins;
  final Value<int> streakDays;
  final Value<DateTime?> lastLoginDate;
  final Value<int> previousStreakDays;
  final Value<bool> streakShieldAvailable;
  const HeroStateTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.archetype = const Value.absent(),
    this.level = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.maxXp = const Value.absent(),
    this.currentHp = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.coins = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastLoginDate = const Value.absent(),
    this.previousStreakDays = const Value.absent(),
    this.streakShieldAvailable = const Value.absent(),
  });
  HeroStateTableCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.archetype = const Value.absent(),
    this.level = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.maxXp = const Value.absent(),
    this.currentHp = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.coins = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastLoginDate = const Value.absent(),
    this.previousStreakDays = const Value.absent(),
    this.streakShieldAvailable = const Value.absent(),
  });
  static Insertable<HeroStateTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? archetype,
    Expression<int>? level,
    Expression<int>? currentXp,
    Expression<int>? maxXp,
    Expression<int>? currentHp,
    Expression<int>? maxHp,
    Expression<int>? coins,
    Expression<int>? streakDays,
    Expression<DateTime>? lastLoginDate,
    Expression<int>? previousStreakDays,
    Expression<bool>? streakShieldAvailable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (archetype != null) 'archetype': archetype,
      if (level != null) 'level': level,
      if (currentXp != null) 'current_xp': currentXp,
      if (maxXp != null) 'max_xp': maxXp,
      if (currentHp != null) 'current_hp': currentHp,
      if (maxHp != null) 'max_hp': maxHp,
      if (coins != null) 'coins': coins,
      if (streakDays != null) 'streak_days': streakDays,
      if (lastLoginDate != null) 'last_login_date': lastLoginDate,
      if (previousStreakDays != null)
        'previous_streak_days': previousStreakDays,
      if (streakShieldAvailable != null)
        'streak_shield_available': streakShieldAvailable,
    });
  }

  HeroStateTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? archetype,
      Value<int>? level,
      Value<int>? currentXp,
      Value<int>? maxXp,
      Value<int>? currentHp,
      Value<int>? maxHp,
      Value<int>? coins,
      Value<int>? streakDays,
      Value<DateTime?>? lastLoginDate,
      Value<int>? previousStreakDays,
      Value<bool>? streakShieldAvailable}) {
    return HeroStateTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      archetype: archetype ?? this.archetype,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      maxXp: maxXp ?? this.maxXp,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      previousStreakDays: previousStreakDays ?? this.previousStreakDays,
      streakShieldAvailable:
          streakShieldAvailable ?? this.streakShieldAvailable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (archetype.present) {
      map['archetype'] = Variable<String>(archetype.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (currentXp.present) {
      map['current_xp'] = Variable<int>(currentXp.value);
    }
    if (maxXp.present) {
      map['max_xp'] = Variable<int>(maxXp.value);
    }
    if (currentHp.present) {
      map['current_hp'] = Variable<int>(currentHp.value);
    }
    if (maxHp.present) {
      map['max_hp'] = Variable<int>(maxHp.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (lastLoginDate.present) {
      map['last_login_date'] = Variable<DateTime>(lastLoginDate.value);
    }
    if (previousStreakDays.present) {
      map['previous_streak_days'] = Variable<int>(previousStreakDays.value);
    }
    if (streakShieldAvailable.present) {
      map['streak_shield_available'] =
          Variable<bool>(streakShieldAvailable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeroStateTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('archetype: $archetype, ')
          ..write('level: $level, ')
          ..write('currentXp: $currentXp, ')
          ..write('maxXp: $maxXp, ')
          ..write('currentHp: $currentHp, ')
          ..write('maxHp: $maxHp, ')
          ..write('coins: $coins, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastLoginDate: $lastLoginDate, ')
          ..write('previousStreakDays: $previousStreakDays, ')
          ..write('streakShieldAvailable: $streakShieldAvailable')
          ..write(')'))
        .toString();
  }
}

class $QuestsTableTable extends QuestsTable
    with TableInfo<$QuestsTableTable, QuestsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetValueMeta =
      const VerificationMeta('targetValue');
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
      'target_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _progressValueMeta =
      const VerificationMeta('progressValue');
  @override
  late final GeneratedColumn<double> progressValue = GeneratedColumn<double>(
      'progress_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rewardXpMeta =
      const VerificationMeta('rewardXp');
  @override
  late final GeneratedColumn<int> rewardXp = GeneratedColumn<int>(
      'reward_xp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rewardCoinsMeta =
      const VerificationMeta('rewardCoins');
  @override
  late final GeneratedColumn<int> rewardCoins = GeneratedColumn<int>(
      'reward_coins', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isClaimedMeta =
      const VerificationMeta('isClaimed');
  @override
  late final GeneratedColumn<bool> isClaimed = GeneratedColumn<bool>(
      'is_claimed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_claimed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        title,
        description,
        type,
        targetValue,
        progressValue,
        rewardXp,
        rewardCoins,
        isCompleted,
        isClaimed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests_table';
  @override
  VerificationContext validateIntegrity(Insertable<QuestsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
          _targetValueMeta,
          targetValue.isAcceptableOrUnknown(
              data['target_value']!, _targetValueMeta));
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('progress_value')) {
      context.handle(
          _progressValueMeta,
          progressValue.isAcceptableOrUnknown(
              data['progress_value']!, _progressValueMeta));
    } else if (isInserting) {
      context.missing(_progressValueMeta);
    }
    if (data.containsKey('reward_xp')) {
      context.handle(_rewardXpMeta,
          rewardXp.isAcceptableOrUnknown(data['reward_xp']!, _rewardXpMeta));
    } else if (isInserting) {
      context.missing(_rewardXpMeta);
    }
    if (data.containsKey('reward_coins')) {
      context.handle(
          _rewardCoinsMeta,
          rewardCoins.isAcceptableOrUnknown(
              data['reward_coins']!, _rewardCoinsMeta));
    } else if (isInserting) {
      context.missing(_rewardCoinsMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_claimed')) {
      context.handle(_isClaimedMeta,
          isClaimed.isAcceptableOrUnknown(data['is_claimed']!, _isClaimedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      targetValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_value'])!,
      progressValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress_value'])!,
      rewardXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reward_xp'])!,
      rewardCoins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reward_coins'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isClaimed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_claimed'])!,
    );
  }

  @override
  $QuestsTableTable createAlias(String alias) {
    return $QuestsTableTable(attachedDatabase, alias);
  }
}

class QuestsTableData extends DataClass implements Insertable<QuestsTableData> {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final String type;
  final double targetValue;
  final double progressValue;
  final int rewardXp;
  final int rewardCoins;
  final bool isCompleted;
  final bool isClaimed;
  const QuestsTableData(
      {required this.id,
      required this.date,
      required this.title,
      required this.description,
      required this.type,
      required this.targetValue,
      required this.progressValue,
      required this.rewardXp,
      required this.rewardCoins,
      required this.isCompleted,
      required this.isClaimed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    map['target_value'] = Variable<double>(targetValue);
    map['progress_value'] = Variable<double>(progressValue);
    map['reward_xp'] = Variable<int>(rewardXp);
    map['reward_coins'] = Variable<int>(rewardCoins);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_claimed'] = Variable<bool>(isClaimed);
    return map;
  }

  QuestsTableCompanion toCompanion(bool nullToAbsent) {
    return QuestsTableCompanion(
      id: Value(id),
      date: Value(date),
      title: Value(title),
      description: Value(description),
      type: Value(type),
      targetValue: Value(targetValue),
      progressValue: Value(progressValue),
      rewardXp: Value(rewardXp),
      rewardCoins: Value(rewardCoins),
      isCompleted: Value(isCompleted),
      isClaimed: Value(isClaimed),
    );
  }

  factory QuestsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestsTableData(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      progressValue: serializer.fromJson<double>(json['progressValue']),
      rewardXp: serializer.fromJson<int>(json['rewardXp']),
      rewardCoins: serializer.fromJson<int>(json['rewardCoins']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isClaimed: serializer.fromJson<bool>(json['isClaimed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'targetValue': serializer.toJson<double>(targetValue),
      'progressValue': serializer.toJson<double>(progressValue),
      'rewardXp': serializer.toJson<int>(rewardXp),
      'rewardCoins': serializer.toJson<int>(rewardCoins),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isClaimed': serializer.toJson<bool>(isClaimed),
    };
  }

  QuestsTableData copyWith(
          {String? id,
          DateTime? date,
          String? title,
          String? description,
          String? type,
          double? targetValue,
          double? progressValue,
          int? rewardXp,
          int? rewardCoins,
          bool? isCompleted,
          bool? isClaimed}) =>
      QuestsTableData(
        id: id ?? this.id,
        date: date ?? this.date,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        targetValue: targetValue ?? this.targetValue,
        progressValue: progressValue ?? this.progressValue,
        rewardXp: rewardXp ?? this.rewardXp,
        rewardCoins: rewardCoins ?? this.rewardCoins,
        isCompleted: isCompleted ?? this.isCompleted,
        isClaimed: isClaimed ?? this.isClaimed,
      );
  QuestsTableData copyWithCompanion(QuestsTableCompanion data) {
    return QuestsTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      targetValue:
          data.targetValue.present ? data.targetValue.value : this.targetValue,
      progressValue: data.progressValue.present
          ? data.progressValue.value
          : this.progressValue,
      rewardXp: data.rewardXp.present ? data.rewardXp.value : this.rewardXp,
      rewardCoins:
          data.rewardCoins.present ? data.rewardCoins.value : this.rewardCoins,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isClaimed: data.isClaimed.present ? data.isClaimed.value : this.isClaimed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestsTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('targetValue: $targetValue, ')
          ..write('progressValue: $progressValue, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardCoins: $rewardCoins, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isClaimed: $isClaimed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      date,
      title,
      description,
      type,
      targetValue,
      progressValue,
      rewardXp,
      rewardCoins,
      isCompleted,
      isClaimed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestsTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.targetValue == this.targetValue &&
          other.progressValue == this.progressValue &&
          other.rewardXp == this.rewardXp &&
          other.rewardCoins == this.rewardCoins &&
          other.isCompleted == this.isCompleted &&
          other.isClaimed == this.isClaimed);
}

class QuestsTableCompanion extends UpdateCompanion<QuestsTableData> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> title;
  final Value<String> description;
  final Value<String> type;
  final Value<double> targetValue;
  final Value<double> progressValue;
  final Value<int> rewardXp;
  final Value<int> rewardCoins;
  final Value<bool> isCompleted;
  final Value<bool> isClaimed;
  final Value<int> rowid;
  const QuestsTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.progressValue = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.rewardCoins = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isClaimed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestsTableCompanion.insert({
    required String id,
    required DateTime date,
    required String title,
    required String description,
    required String type,
    required double targetValue,
    required double progressValue,
    required int rewardXp,
    required int rewardCoins,
    this.isCompleted = const Value.absent(),
    this.isClaimed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        title = Value(title),
        description = Value(description),
        type = Value(type),
        targetValue = Value(targetValue),
        progressValue = Value(progressValue),
        rewardXp = Value(rewardXp),
        rewardCoins = Value(rewardCoins);
  static Insertable<QuestsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<double>? targetValue,
    Expression<double>? progressValue,
    Expression<int>? rewardXp,
    Expression<int>? rewardCoins,
    Expression<bool>? isCompleted,
    Expression<bool>? isClaimed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (targetValue != null) 'target_value': targetValue,
      if (progressValue != null) 'progress_value': progressValue,
      if (rewardXp != null) 'reward_xp': rewardXp,
      if (rewardCoins != null) 'reward_coins': rewardCoins,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isClaimed != null) 'is_claimed': isClaimed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestsTableCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String>? title,
      Value<String>? description,
      Value<String>? type,
      Value<double>? targetValue,
      Value<double>? progressValue,
      Value<int>? rewardXp,
      Value<int>? rewardCoins,
      Value<bool>? isCompleted,
      Value<bool>? isClaimed,
      Value<int>? rowid}) {
    return QuestsTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      progressValue: progressValue ?? this.progressValue,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (progressValue.present) {
      map['progress_value'] = Variable<double>(progressValue.value);
    }
    if (rewardXp.present) {
      map['reward_xp'] = Variable<int>(rewardXp.value);
    }
    if (rewardCoins.present) {
      map['reward_coins'] = Variable<int>(rewardCoins.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isClaimed.present) {
      map['is_claimed'] = Variable<bool>(isClaimed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('targetValue: $targetValue, ')
          ..write('progressValue: $progressValue, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardCoins: $rewardCoins, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isClaimed: $isClaimed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTableTable extends AchievementsTable
    with TableInfo<$AchievementsTableTable, AchievementsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
      'unlocked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, description, icon, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AchievementsTableData> instance,
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
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AchievementsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}unlocked_at']),
    );
  }

  @override
  $AchievementsTableTable createAlias(String alias) {
    return $AchievementsTableTable(attachedDatabase, alias);
  }
}

class AchievementsTableData extends DataClass
    implements Insertable<AchievementsTableData> {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  const AchievementsTableData(
      {required this.id,
      required this.title,
      required this.description,
      required this.icon,
      this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  AchievementsTableCompanion toCompanion(bool nullToAbsent) {
    return AchievementsTableCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      icon: Value(icon),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory AchievementsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      icon: serializer.fromJson<String>(json['icon']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'icon': serializer.toJson<String>(icon),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  AchievementsTableData copyWith(
          {String? id,
          String? title,
          String? description,
          String? icon,
          Value<DateTime?> unlockedAt = const Value.absent()}) =>
      AchievementsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
      );
  AchievementsTableData copyWithCompanion(AchievementsTableCompanion data) {
    return AchievementsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, icon, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsTableCompanion
    extends UpdateCompanion<AchievementsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> icon;
  final Value<DateTime?> unlockedAt;
  final Value<int> rowid;
  const AchievementsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsTableCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String icon,
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        icon = Value(icon);
  static Insertable<AchievementsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? icon,
      Value<DateTime?>? unlockedAt,
      Value<int>? rowid}) {
    return AchievementsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTableTable extends SavingsGoalsTable
    with TableInfo<$SavingsGoalsTableTable, SavingsGoalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetAmountPaiseMeta =
      const VerificationMeta('targetAmountPaise');
  @override
  late final GeneratedColumn<int> targetAmountPaise = GeneratedColumn<int>(
      'target_amount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _savedAmountPaiseMeta =
      const VerificationMeta('savedAmountPaise');
  @override
  late final GeneratedColumn<int> savedAmountPaise = GeneratedColumn<int>(
      'saved_amount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('🎯'));
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        targetAmountPaise,
        savedAmountPaise,
        icon,
        isPrimary,
        deadline,
        isCompleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SavingsGoalsTableData> instance,
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
    if (data.containsKey('target_amount_paise')) {
      context.handle(
          _targetAmountPaiseMeta,
          targetAmountPaise.isAcceptableOrUnknown(
              data['target_amount_paise']!, _targetAmountPaiseMeta));
    } else if (isInserting) {
      context.missing(_targetAmountPaiseMeta);
    }
    if (data.containsKey('saved_amount_paise')) {
      context.handle(
          _savedAmountPaiseMeta,
          savedAmountPaise.isAcceptableOrUnknown(
              data['saved_amount_paise']!, _savedAmountPaiseMeta));
    } else if (isInserting) {
      context.missing(_savedAmountPaiseMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoalsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoalsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      targetAmountPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}target_amount_paise'])!,
      savedAmountPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}saved_amount_paise'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
    );
  }

  @override
  $SavingsGoalsTableTable createAlias(String alias) {
    return $SavingsGoalsTableTable(attachedDatabase, alias);
  }
}

class SavingsGoalsTableData extends DataClass
    implements Insertable<SavingsGoalsTableData> {
  final String id;
  final String title;
  final int targetAmountPaise;
  final int savedAmountPaise;
  final String icon;
  final bool isPrimary;
  final DateTime? deadline;
  final bool isCompleted;
  const SavingsGoalsTableData(
      {required this.id,
      required this.title,
      required this.targetAmountPaise,
      required this.savedAmountPaise,
      required this.icon,
      required this.isPrimary,
      this.deadline,
      required this.isCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['target_amount_paise'] = Variable<int>(targetAmountPaise);
    map['saved_amount_paise'] = Variable<int>(savedAmountPaise);
    map['icon'] = Variable<String>(icon);
    map['is_primary'] = Variable<bool>(isPrimary);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  SavingsGoalsTableCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsTableCompanion(
      id: Value(id),
      title: Value(title),
      targetAmountPaise: Value(targetAmountPaise),
      savedAmountPaise: Value(savedAmountPaise),
      icon: Value(icon),
      isPrimary: Value(isPrimary),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      isCompleted: Value(isCompleted),
    );
  }

  factory SavingsGoalsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoalsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      targetAmountPaise: serializer.fromJson<int>(json['targetAmountPaise']),
      savedAmountPaise: serializer.fromJson<int>(json['savedAmountPaise']),
      icon: serializer.fromJson<String>(json['icon']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'targetAmountPaise': serializer.toJson<int>(targetAmountPaise),
      'savedAmountPaise': serializer.toJson<int>(savedAmountPaise),
      'icon': serializer.toJson<String>(icon),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  SavingsGoalsTableData copyWith(
          {String? id,
          String? title,
          int? targetAmountPaise,
          int? savedAmountPaise,
          String? icon,
          bool? isPrimary,
          Value<DateTime?> deadline = const Value.absent(),
          bool? isCompleted}) =>
      SavingsGoalsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        targetAmountPaise: targetAmountPaise ?? this.targetAmountPaise,
        savedAmountPaise: savedAmountPaise ?? this.savedAmountPaise,
        icon: icon ?? this.icon,
        isPrimary: isPrimary ?? this.isPrimary,
        deadline: deadline.present ? deadline.value : this.deadline,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  SavingsGoalsTableData copyWithCompanion(SavingsGoalsTableCompanion data) {
    return SavingsGoalsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      targetAmountPaise: data.targetAmountPaise.present
          ? data.targetAmountPaise.value
          : this.targetAmountPaise,
      savedAmountPaise: data.savedAmountPaise.present
          ? data.savedAmountPaise.value
          : this.savedAmountPaise,
      icon: data.icon.present ? data.icon.value : this.icon,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetAmountPaise: $targetAmountPaise, ')
          ..write('savedAmountPaise: $savedAmountPaise, ')
          ..write('icon: $icon, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('deadline: $deadline, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, targetAmountPaise,
      savedAmountPaise, icon, isPrimary, deadline, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoalsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.targetAmountPaise == this.targetAmountPaise &&
          other.savedAmountPaise == this.savedAmountPaise &&
          other.icon == this.icon &&
          other.isPrimary == this.isPrimary &&
          other.deadline == this.deadline &&
          other.isCompleted == this.isCompleted);
}

class SavingsGoalsTableCompanion
    extends UpdateCompanion<SavingsGoalsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> targetAmountPaise;
  final Value<int> savedAmountPaise;
  final Value<String> icon;
  final Value<bool> isPrimary;
  final Value<DateTime?> deadline;
  final Value<bool> isCompleted;
  final Value<int> rowid;
  const SavingsGoalsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.targetAmountPaise = const Value.absent(),
    this.savedAmountPaise = const Value.absent(),
    this.icon = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.deadline = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsTableCompanion.insert({
    required String id,
    required String title,
    required int targetAmountPaise,
    required int savedAmountPaise,
    this.icon = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.deadline = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        targetAmountPaise = Value(targetAmountPaise),
        savedAmountPaise = Value(savedAmountPaise);
  static Insertable<SavingsGoalsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? targetAmountPaise,
    Expression<int>? savedAmountPaise,
    Expression<String>? icon,
    Expression<bool>? isPrimary,
    Expression<DateTime>? deadline,
    Expression<bool>? isCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (targetAmountPaise != null) 'target_amount_paise': targetAmountPaise,
      if (savedAmountPaise != null) 'saved_amount_paise': savedAmountPaise,
      if (icon != null) 'icon': icon,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (deadline != null) 'deadline': deadline,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<int>? targetAmountPaise,
      Value<int>? savedAmountPaise,
      Value<String>? icon,
      Value<bool>? isPrimary,
      Value<DateTime?>? deadline,
      Value<bool>? isCompleted,
      Value<int>? rowid}) {
    return SavingsGoalsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmountPaise: targetAmountPaise ?? this.targetAmountPaise,
      savedAmountPaise: savedAmountPaise ?? this.savedAmountPaise,
      icon: icon ?? this.icon,
      isPrimary: isPrimary ?? this.isPrimary,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
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
    if (targetAmountPaise.present) {
      map['target_amount_paise'] = Variable<int>(targetAmountPaise.value);
    }
    if (savedAmountPaise.present) {
      map['saved_amount_paise'] = Variable<int>(savedAmountPaise.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetAmountPaise: $targetAmountPaise, ')
          ..write('savedAmountPaise: $savedAmountPaise, ')
          ..write('icon: $icon, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('deadline: $deadline, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  late final $CyclesTableTable cyclesTable = $CyclesTableTable(this);
  late final $DailyBudgetsTableTable dailyBudgetsTable =
      $DailyBudgetsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $HeroStateTableTable heroStateTable = $HeroStateTableTable(this);
  late final $QuestsTableTable questsTable = $QuestsTableTable(this);
  late final $AchievementsTableTable achievementsTable =
      $AchievementsTableTable(this);
  late final $SavingsGoalsTableTable savingsGoalsTable =
      $SavingsGoalsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userSettingsTable,
        cyclesTable,
        dailyBudgetsTable,
        transactionsTable,
        heroStateTable,
        questsTable,
        achievementsTable,
        savingsGoalsTable
      ];
}

typedef $$UserSettingsTableTableCreateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  Value<int> paydayDay,
  Value<String> currencySymbol,
  Value<String> rolloverStrategy,
  Value<bool> isSeriousMode,
  Value<bool> reducedMotion,
  Value<bool> biometricLock,
  Value<bool> autoFlowSavings,
  Value<String?> autoFlowGoalId,
  Value<DateTime?> lastKnownDeviceTimestamp,
});
typedef $$UserSettingsTableTableUpdateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  Value<int> paydayDay,
  Value<String> currencySymbol,
  Value<String> rolloverStrategy,
  Value<bool> isSeriousMode,
  Value<bool> reducedMotion,
  Value<bool> biometricLock,
  Value<bool> autoFlowSavings,
  Value<String?> autoFlowGoalId,
  Value<DateTime?> lastKnownDeviceTimestamp,
});

class $$UserSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paydayDay => $composableBuilder(
      column: $table.paydayDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rolloverStrategy => $composableBuilder(
      column: $table.rolloverStrategy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSeriousMode => $composableBuilder(
      column: $table.isSeriousMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reducedMotion => $composableBuilder(
      column: $table.reducedMotion, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get biometricLock => $composableBuilder(
      column: $table.biometricLock, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoFlowSavings => $composableBuilder(
      column: $table.autoFlowSavings,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get autoFlowGoalId => $composableBuilder(
      column: $table.autoFlowGoalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastKnownDeviceTimestamp => $composableBuilder(
      column: $table.lastKnownDeviceTimestamp,
      builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paydayDay => $composableBuilder(
      column: $table.paydayDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rolloverStrategy => $composableBuilder(
      column: $table.rolloverStrategy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSeriousMode => $composableBuilder(
      column: $table.isSeriousMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reducedMotion => $composableBuilder(
      column: $table.reducedMotion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get biometricLock => $composableBuilder(
      column: $table.biometricLock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoFlowSavings => $composableBuilder(
      column: $table.autoFlowSavings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get autoFlowGoalId => $composableBuilder(
      column: $table.autoFlowGoalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastKnownDeviceTimestamp => $composableBuilder(
      column: $table.lastKnownDeviceTimestamp,
      builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get paydayDay =>
      $composableBuilder(column: $table.paydayDay, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<String> get rolloverStrategy => $composableBuilder(
      column: $table.rolloverStrategy, builder: (column) => column);

  GeneratedColumn<bool> get isSeriousMode => $composableBuilder(
      column: $table.isSeriousMode, builder: (column) => column);

  GeneratedColumn<bool> get reducedMotion => $composableBuilder(
      column: $table.reducedMotion, builder: (column) => column);

  GeneratedColumn<bool> get biometricLock => $composableBuilder(
      column: $table.biometricLock, builder: (column) => column);

  GeneratedColumn<bool> get autoFlowSavings => $composableBuilder(
      column: $table.autoFlowSavings, builder: (column) => column);

  GeneratedColumn<String> get autoFlowGoalId => $composableBuilder(
      column: $table.autoFlowGoalId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastKnownDeviceTimestamp => $composableBuilder(
      column: $table.lastKnownDeviceTimestamp, builder: (column) => column);
}

class $$UserSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTableTable,
    UserSettingsTableData,
    $$UserSettingsTableTableFilterComposer,
    $$UserSettingsTableTableOrderingComposer,
    $$UserSettingsTableTableAnnotationComposer,
    $$UserSettingsTableTableCreateCompanionBuilder,
    $$UserSettingsTableTableUpdateCompanionBuilder,
    (
      UserSettingsTableData,
      BaseReferences<_$AppDatabase, $UserSettingsTableTable,
          UserSettingsTableData>
    ),
    UserSettingsTableData,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableTableManager(
      _$AppDatabase db, $UserSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> paydayDay = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String> rolloverStrategy = const Value.absent(),
            Value<bool> isSeriousMode = const Value.absent(),
            Value<bool> reducedMotion = const Value.absent(),
            Value<bool> biometricLock = const Value.absent(),
            Value<bool> autoFlowSavings = const Value.absent(),
            Value<String?> autoFlowGoalId = const Value.absent(),
            Value<DateTime?> lastKnownDeviceTimestamp = const Value.absent(),
          }) =>
              UserSettingsTableCompanion(
            id: id,
            paydayDay: paydayDay,
            currencySymbol: currencySymbol,
            rolloverStrategy: rolloverStrategy,
            isSeriousMode: isSeriousMode,
            reducedMotion: reducedMotion,
            biometricLock: biometricLock,
            autoFlowSavings: autoFlowSavings,
            autoFlowGoalId: autoFlowGoalId,
            lastKnownDeviceTimestamp: lastKnownDeviceTimestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> paydayDay = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String> rolloverStrategy = const Value.absent(),
            Value<bool> isSeriousMode = const Value.absent(),
            Value<bool> reducedMotion = const Value.absent(),
            Value<bool> biometricLock = const Value.absent(),
            Value<bool> autoFlowSavings = const Value.absent(),
            Value<String?> autoFlowGoalId = const Value.absent(),
            Value<DateTime?> lastKnownDeviceTimestamp = const Value.absent(),
          }) =>
              UserSettingsTableCompanion.insert(
            id: id,
            paydayDay: paydayDay,
            currencySymbol: currencySymbol,
            rolloverStrategy: rolloverStrategy,
            isSeriousMode: isSeriousMode,
            reducedMotion: reducedMotion,
            biometricLock: biometricLock,
            autoFlowSavings: autoFlowSavings,
            autoFlowGoalId: autoFlowGoalId,
            lastKnownDeviceTimestamp: lastKnownDeviceTimestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UserSettingsTableTable, UserSettingsTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $UserSettingsTableTable,
                        UserSettingsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTableTable,
    UserSettingsTableData,
    $$UserSettingsTableTableFilterComposer,
    $$UserSettingsTableTableOrderingComposer,
    $$UserSettingsTableTableAnnotationComposer,
    $$UserSettingsTableTableCreateCompanionBuilder,
    $$UserSettingsTableTableUpdateCompanionBuilder,
    (
      UserSettingsTableData,
      BaseReferences<_$AppDatabase, $UserSettingsTableTable,
          UserSettingsTableData>
    ),
    UserSettingsTableData,
    PrefetchHooks Function()>;
typedef $$CyclesTableTableCreateCompanionBuilder = CyclesTableCompanion
    Function({
  required String id,
  required DateTime startDate,
  required DateTime endDate,
  required int totalDays,
  Value<int> paydayDay,
  Value<DateTime?> salaryReceivedDate,
  required int inHandSalaryPaise,
  required int fixedExpensesPaise,
  required int savingsTargetPaise,
  Value<String> rolloverStrategy,
  required int bossCurrentHp,
  required int bossMaxHp,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$CyclesTableTableUpdateCompanionBuilder = CyclesTableCompanion
    Function({
  Value<String> id,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<int> totalDays,
  Value<int> paydayDay,
  Value<DateTime?> salaryReceivedDate,
  Value<int> inHandSalaryPaise,
  Value<int> fixedExpensesPaise,
  Value<int> savingsTargetPaise,
  Value<String> rolloverStrategy,
  Value<int> bossCurrentHp,
  Value<int> bossMaxHp,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$CyclesTableTableReferences
    extends BaseReferences<_$AppDatabase, $CyclesTableTable, CyclesTableData> {
  $$CyclesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DailyBudgetsTableTable,
      List<DailyBudgetsTableData>> _dailyBudgetsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dailyBudgetsTable,
          aliasName: 'cycles_table__id__daily_budgets_table__cycle_id');

  $$DailyBudgetsTableTableProcessedTableManager get dailyBudgetsTableRefs {
    final manager =
        $$DailyBudgetsTableTableTableManager($_db, $_db.dailyBudgetsTable)
            .filter((f) => f.cycleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_dailyBudgetsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CyclesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CyclesTableTable> {
  $$CyclesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalDays => $composableBuilder(
      column: $table.totalDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paydayDay => $composableBuilder(
      column: $table.paydayDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get salaryReceivedDate => $composableBuilder(
      column: $table.salaryReceivedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get inHandSalaryPaise => $composableBuilder(
      column: $table.inHandSalaryPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fixedExpensesPaise => $composableBuilder(
      column: $table.fixedExpensesPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get savingsTargetPaise => $composableBuilder(
      column: $table.savingsTargetPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rolloverStrategy => $composableBuilder(
      column: $table.rolloverStrategy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bossCurrentHp => $composableBuilder(
      column: $table.bossCurrentHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bossMaxHp => $composableBuilder(
      column: $table.bossMaxHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  Expression<bool> dailyBudgetsTableRefs(
      Expression<bool> Function($$DailyBudgetsTableTableFilterComposer f) f) {
    final $$DailyBudgetsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dailyBudgetsTable,
        getReferencedColumn: (t) => t.cycleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyBudgetsTableTableFilterComposer(
              $db: $db,
              $table: $db.dailyBudgetsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CyclesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CyclesTableTable> {
  $$CyclesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalDays => $composableBuilder(
      column: $table.totalDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paydayDay => $composableBuilder(
      column: $table.paydayDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get salaryReceivedDate => $composableBuilder(
      column: $table.salaryReceivedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get inHandSalaryPaise => $composableBuilder(
      column: $table.inHandSalaryPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fixedExpensesPaise => $composableBuilder(
      column: $table.fixedExpensesPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get savingsTargetPaise => $composableBuilder(
      column: $table.savingsTargetPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rolloverStrategy => $composableBuilder(
      column: $table.rolloverStrategy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bossCurrentHp => $composableBuilder(
      column: $table.bossCurrentHp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bossMaxHp => $composableBuilder(
      column: $table.bossMaxHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));
}

class $$CyclesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CyclesTableTable> {
  $$CyclesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get totalDays =>
      $composableBuilder(column: $table.totalDays, builder: (column) => column);

  GeneratedColumn<int> get paydayDay =>
      $composableBuilder(column: $table.paydayDay, builder: (column) => column);

  GeneratedColumn<DateTime> get salaryReceivedDate => $composableBuilder(
      column: $table.salaryReceivedDate, builder: (column) => column);

  GeneratedColumn<int> get inHandSalaryPaise => $composableBuilder(
      column: $table.inHandSalaryPaise, builder: (column) => column);

  GeneratedColumn<int> get fixedExpensesPaise => $composableBuilder(
      column: $table.fixedExpensesPaise, builder: (column) => column);

  GeneratedColumn<int> get savingsTargetPaise => $composableBuilder(
      column: $table.savingsTargetPaise, builder: (column) => column);

  GeneratedColumn<String> get rolloverStrategy => $composableBuilder(
      column: $table.rolloverStrategy, builder: (column) => column);

  GeneratedColumn<int> get bossCurrentHp => $composableBuilder(
      column: $table.bossCurrentHp, builder: (column) => column);

  GeneratedColumn<int> get bossMaxHp =>
      $composableBuilder(column: $table.bossMaxHp, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  Expression<T> dailyBudgetsTableRefs<T extends Object>(
      Expression<T> Function($$DailyBudgetsTableTableAnnotationComposer a) f) {
    final $$DailyBudgetsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.dailyBudgetsTable,
            getReferencedColumn: (t) => t.cycleId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DailyBudgetsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.dailyBudgetsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CyclesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CyclesTableTable,
    CyclesTableData,
    $$CyclesTableTableFilterComposer,
    $$CyclesTableTableOrderingComposer,
    $$CyclesTableTableAnnotationComposer,
    $$CyclesTableTableCreateCompanionBuilder,
    $$CyclesTableTableUpdateCompanionBuilder,
    (CyclesTableData, $$CyclesTableTableReferences),
    CyclesTableData,
    PrefetchHooks Function({bool dailyBudgetsTableRefs})> {
  $$CyclesTableTableTableManager(_$AppDatabase db, $CyclesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<int> totalDays = const Value.absent(),
            Value<int> paydayDay = const Value.absent(),
            Value<DateTime?> salaryReceivedDate = const Value.absent(),
            Value<int> inHandSalaryPaise = const Value.absent(),
            Value<int> fixedExpensesPaise = const Value.absent(),
            Value<int> savingsTargetPaise = const Value.absent(),
            Value<String> rolloverStrategy = const Value.absent(),
            Value<int> bossCurrentHp = const Value.absent(),
            Value<int> bossMaxHp = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CyclesTableCompanion(
            id: id,
            startDate: startDate,
            endDate: endDate,
            totalDays: totalDays,
            paydayDay: paydayDay,
            salaryReceivedDate: salaryReceivedDate,
            inHandSalaryPaise: inHandSalaryPaise,
            fixedExpensesPaise: fixedExpensesPaise,
            savingsTargetPaise: savingsTargetPaise,
            rolloverStrategy: rolloverStrategy,
            bossCurrentHp: bossCurrentHp,
            bossMaxHp: bossMaxHp,
            isArchived: isArchived,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime startDate,
            required DateTime endDate,
            required int totalDays,
            Value<int> paydayDay = const Value.absent(),
            Value<DateTime?> salaryReceivedDate = const Value.absent(),
            required int inHandSalaryPaise,
            required int fixedExpensesPaise,
            required int savingsTargetPaise,
            Value<String> rolloverStrategy = const Value.absent(),
            required int bossCurrentHp,
            required int bossMaxHp,
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CyclesTableCompanion.insert(
            id: id,
            startDate: startDate,
            endDate: endDate,
            totalDays: totalDays,
            paydayDay: paydayDay,
            salaryReceivedDate: salaryReceivedDate,
            inHandSalaryPaise: inHandSalaryPaise,
            fixedExpensesPaise: fixedExpensesPaise,
            savingsTargetPaise: savingsTargetPaise,
            rolloverStrategy: rolloverStrategy,
            bossCurrentHp: bossCurrentHp,
            bossMaxHp: bossMaxHp,
            isArchived: isArchived,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CyclesTableTable, CyclesTableData>(table),
                    $$CyclesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dailyBudgetsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dailyBudgetsTableRefs) db.dailyBudgetsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dailyBudgetsTableRefs)
                    await $_getPrefetchedData<CyclesTableData,
                            $CyclesTableTable, DailyBudgetsTableData>(
                        currentTable: table,
                        referencedTable: $$CyclesTableTableReferences
                            ._dailyBudgetsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CyclesTableTableReferences(db, table, p0)
                                .dailyBudgetsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cycleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CyclesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CyclesTableTable,
    CyclesTableData,
    $$CyclesTableTableFilterComposer,
    $$CyclesTableTableOrderingComposer,
    $$CyclesTableTableAnnotationComposer,
    $$CyclesTableTableCreateCompanionBuilder,
    $$CyclesTableTableUpdateCompanionBuilder,
    (CyclesTableData, $$CyclesTableTableReferences),
    CyclesTableData,
    PrefetchHooks Function({bool dailyBudgetsTableRefs})>;
typedef $$DailyBudgetsTableTableCreateCompanionBuilder
    = DailyBudgetsTableCompanion Function({
  required String id,
  required String cycleId,
  required DateTime date,
  required int dayIndex,
  required int allocatedBudgetPaise,
  required int actualSpentPaise,
  Value<bool> isClosed,
  Value<int> rowid,
});
typedef $$DailyBudgetsTableTableUpdateCompanionBuilder
    = DailyBudgetsTableCompanion Function({
  Value<String> id,
  Value<String> cycleId,
  Value<DateTime> date,
  Value<int> dayIndex,
  Value<int> allocatedBudgetPaise,
  Value<int> actualSpentPaise,
  Value<bool> isClosed,
  Value<int> rowid,
});

final class $$DailyBudgetsTableTableReferences extends BaseReferences<
    _$AppDatabase, $DailyBudgetsTableTable, DailyBudgetsTableData> {
  $$DailyBudgetsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CyclesTableTable _cycleIdTable(_$AppDatabase db) => db.cyclesTable
      .createAlias('daily_budgets_table__cycle_id__cycles_table__id');

  $$CyclesTableTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<String>('cycle_id')!;

    final manager = $$CyclesTableTableTableManager($_db, $_db.cyclesTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DailyBudgetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTableTable> {
  $$DailyBudgetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayIndex => $composableBuilder(
      column: $table.dayIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get allocatedBudgetPaise => $composableBuilder(
      column: $table.allocatedBudgetPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualSpentPaise => $composableBuilder(
      column: $table.actualSpentPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isClosed => $composableBuilder(
      column: $table.isClosed, builder: (column) => ColumnFilters(column));

  $$CyclesTableTableFilterComposer get cycleId {
    final $$CyclesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cycleId,
        referencedTable: $db.cyclesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CyclesTableTableFilterComposer(
              $db: $db,
              $table: $db.cyclesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyBudgetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTableTable> {
  $$DailyBudgetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayIndex => $composableBuilder(
      column: $table.dayIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get allocatedBudgetPaise => $composableBuilder(
      column: $table.allocatedBudgetPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualSpentPaise => $composableBuilder(
      column: $table.actualSpentPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isClosed => $composableBuilder(
      column: $table.isClosed, builder: (column) => ColumnOrderings(column));

  $$CyclesTableTableOrderingComposer get cycleId {
    final $$CyclesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cycleId,
        referencedTable: $db.cyclesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CyclesTableTableOrderingComposer(
              $db: $db,
              $table: $db.cyclesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyBudgetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTableTable> {
  $$DailyBudgetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<int> get allocatedBudgetPaise => $composableBuilder(
      column: $table.allocatedBudgetPaise, builder: (column) => column);

  GeneratedColumn<int> get actualSpentPaise => $composableBuilder(
      column: $table.actualSpentPaise, builder: (column) => column);

  GeneratedColumn<bool> get isClosed =>
      $composableBuilder(column: $table.isClosed, builder: (column) => column);

  $$CyclesTableTableAnnotationComposer get cycleId {
    final $$CyclesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cycleId,
        referencedTable: $db.cyclesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CyclesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.cyclesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyBudgetsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyBudgetsTableTable,
    DailyBudgetsTableData,
    $$DailyBudgetsTableTableFilterComposer,
    $$DailyBudgetsTableTableOrderingComposer,
    $$DailyBudgetsTableTableAnnotationComposer,
    $$DailyBudgetsTableTableCreateCompanionBuilder,
    $$DailyBudgetsTableTableUpdateCompanionBuilder,
    (DailyBudgetsTableData, $$DailyBudgetsTableTableReferences),
    DailyBudgetsTableData,
    PrefetchHooks Function({bool cycleId})> {
  $$DailyBudgetsTableTableTableManager(
      _$AppDatabase db, $DailyBudgetsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyBudgetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyBudgetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyBudgetsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cycleId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> dayIndex = const Value.absent(),
            Value<int> allocatedBudgetPaise = const Value.absent(),
            Value<int> actualSpentPaise = const Value.absent(),
            Value<bool> isClosed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyBudgetsTableCompanion(
            id: id,
            cycleId: cycleId,
            date: date,
            dayIndex: dayIndex,
            allocatedBudgetPaise: allocatedBudgetPaise,
            actualSpentPaise: actualSpentPaise,
            isClosed: isClosed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cycleId,
            required DateTime date,
            required int dayIndex,
            required int allocatedBudgetPaise,
            required int actualSpentPaise,
            Value<bool> isClosed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyBudgetsTableCompanion.insert(
            id: id,
            cycleId: cycleId,
            date: date,
            dayIndex: dayIndex,
            allocatedBudgetPaise: allocatedBudgetPaise,
            actualSpentPaise: actualSpentPaise,
            isClosed: isClosed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DailyBudgetsTableTable, DailyBudgetsTableData>(
                        table),
                    $$DailyBudgetsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (cycleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cycleId,
                    referencedTable:
                        $$DailyBudgetsTableTableReferences._cycleIdTable(db),
                    referencedColumn:
                        $$DailyBudgetsTableTableReferences._cycleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DailyBudgetsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyBudgetsTableTable,
    DailyBudgetsTableData,
    $$DailyBudgetsTableTableFilterComposer,
    $$DailyBudgetsTableTableOrderingComposer,
    $$DailyBudgetsTableTableAnnotationComposer,
    $$DailyBudgetsTableTableCreateCompanionBuilder,
    $$DailyBudgetsTableTableUpdateCompanionBuilder,
    (DailyBudgetsTableData, $$DailyBudgetsTableTableReferences),
    DailyBudgetsTableData,
    PrefetchHooks Function({bool cycleId})>;
typedef $$TransactionsTableTableCreateCompanionBuilder
    = TransactionsTableCompanion Function({
  required String id,
  required String cycleId,
  required int amountPaise,
  required String title,
  required String category,
  required DateTime timestamp,
  Value<String> source,
  Value<bool> isFixedExpense,
  Value<String> transactionType,
  Value<String?> dedupeKey,
  Value<int> earnedXp,
  Value<int> earnedCoins,
  Value<int?> splitTotalPaise,
  Value<int?> splitUserSharePaise,
  Value<int?> pendingReimbursementPaise,
  Value<bool> isReimbursement,
  Value<String?> parentTransactionId,
  Value<int> rowid,
});
typedef $$TransactionsTableTableUpdateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<String> id,
  Value<String> cycleId,
  Value<int> amountPaise,
  Value<String> title,
  Value<String> category,
  Value<DateTime> timestamp,
  Value<String> source,
  Value<bool> isFixedExpense,
  Value<String> transactionType,
  Value<String?> dedupeKey,
  Value<int> earnedXp,
  Value<int> earnedCoins,
  Value<int?> splitTotalPaise,
  Value<int?> splitUserSharePaise,
  Value<int?> pendingReimbursementPaise,
  Value<bool> isReimbursement,
  Value<String?> parentTransactionId,
  Value<int> rowid,
});

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cycleId => $composableBuilder(
      column: $table.cycleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFixedExpense => $composableBuilder(
      column: $table.isFixedExpense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get earnedXp => $composableBuilder(
      column: $table.earnedXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get earnedCoins => $composableBuilder(
      column: $table.earnedCoins, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get splitTotalPaise => $composableBuilder(
      column: $table.splitTotalPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get splitUserSharePaise => $composableBuilder(
      column: $table.splitUserSharePaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pendingReimbursementPaise => $composableBuilder(
      column: $table.pendingReimbursementPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isReimbursement => $composableBuilder(
      column: $table.isReimbursement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentTransactionId => $composableBuilder(
      column: $table.parentTransactionId,
      builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cycleId => $composableBuilder(
      column: $table.cycleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFixedExpense => $composableBuilder(
      column: $table.isFixedExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get earnedXp => $composableBuilder(
      column: $table.earnedXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get earnedCoins => $composableBuilder(
      column: $table.earnedCoins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get splitTotalPaise => $composableBuilder(
      column: $table.splitTotalPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get splitUserSharePaise => $composableBuilder(
      column: $table.splitUserSharePaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pendingReimbursementPaise => $composableBuilder(
      column: $table.pendingReimbursementPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isReimbursement => $composableBuilder(
      column: $table.isReimbursement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentTransactionId => $composableBuilder(
      column: $table.parentTransactionId,
      builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isFixedExpense => $composableBuilder(
      column: $table.isFixedExpense, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<int> get earnedXp =>
      $composableBuilder(column: $table.earnedXp, builder: (column) => column);

  GeneratedColumn<int> get earnedCoins => $composableBuilder(
      column: $table.earnedCoins, builder: (column) => column);

  GeneratedColumn<int> get splitTotalPaise => $composableBuilder(
      column: $table.splitTotalPaise, builder: (column) => column);

  GeneratedColumn<int> get splitUserSharePaise => $composableBuilder(
      column: $table.splitUserSharePaise, builder: (column) => column);

  GeneratedColumn<int> get pendingReimbursementPaise => $composableBuilder(
      column: $table.pendingReimbursementPaise, builder: (column) => column);

  GeneratedColumn<bool> get isReimbursement => $composableBuilder(
      column: $table.isReimbursement, builder: (column) => column);

  GeneratedColumn<String> get parentTransactionId => $composableBuilder(
      column: $table.parentTransactionId, builder: (column) => column);
}

class $$TransactionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (
      TransactionsTableData,
      BaseReferences<_$AppDatabase, $TransactionsTableTable,
          TransactionsTableData>
    ),
    TransactionsTableData,
    PrefetchHooks Function()> {
  $$TransactionsTableTableTableManager(
      _$AppDatabase db, $TransactionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cycleId = const Value.absent(),
            Value<int> amountPaise = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<bool> isFixedExpense = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String?> dedupeKey = const Value.absent(),
            Value<int> earnedXp = const Value.absent(),
            Value<int> earnedCoins = const Value.absent(),
            Value<int?> splitTotalPaise = const Value.absent(),
            Value<int?> splitUserSharePaise = const Value.absent(),
            Value<int?> pendingReimbursementPaise = const Value.absent(),
            Value<bool> isReimbursement = const Value.absent(),
            Value<String?> parentTransactionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsTableCompanion(
            id: id,
            cycleId: cycleId,
            amountPaise: amountPaise,
            title: title,
            category: category,
            timestamp: timestamp,
            source: source,
            isFixedExpense: isFixedExpense,
            transactionType: transactionType,
            dedupeKey: dedupeKey,
            earnedXp: earnedXp,
            earnedCoins: earnedCoins,
            splitTotalPaise: splitTotalPaise,
            splitUserSharePaise: splitUserSharePaise,
            pendingReimbursementPaise: pendingReimbursementPaise,
            isReimbursement: isReimbursement,
            parentTransactionId: parentTransactionId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cycleId,
            required int amountPaise,
            required String title,
            required String category,
            required DateTime timestamp,
            Value<String> source = const Value.absent(),
            Value<bool> isFixedExpense = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String?> dedupeKey = const Value.absent(),
            Value<int> earnedXp = const Value.absent(),
            Value<int> earnedCoins = const Value.absent(),
            Value<int?> splitTotalPaise = const Value.absent(),
            Value<int?> splitUserSharePaise = const Value.absent(),
            Value<int?> pendingReimbursementPaise = const Value.absent(),
            Value<bool> isReimbursement = const Value.absent(),
            Value<String?> parentTransactionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsTableCompanion.insert(
            id: id,
            cycleId: cycleId,
            amountPaise: amountPaise,
            title: title,
            category: category,
            timestamp: timestamp,
            source: source,
            isFixedExpense: isFixedExpense,
            transactionType: transactionType,
            dedupeKey: dedupeKey,
            earnedXp: earnedXp,
            earnedCoins: earnedCoins,
            splitTotalPaise: splitTotalPaise,
            splitUserSharePaise: splitUserSharePaise,
            pendingReimbursementPaise: pendingReimbursementPaise,
            isReimbursement: isReimbursement,
            parentTransactionId: parentTransactionId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TransactionsTableTable, TransactionsTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $TransactionsTableTable,
                        TransactionsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (
      TransactionsTableData,
      BaseReferences<_$AppDatabase, $TransactionsTableTable,
          TransactionsTableData>
    ),
    TransactionsTableData,
    PrefetchHooks Function()>;
typedef $$HeroStateTableTableCreateCompanionBuilder = HeroStateTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> archetype,
  Value<int> level,
  Value<int> currentXp,
  Value<int> maxXp,
  Value<int> currentHp,
  Value<int> maxHp,
  Value<int> coins,
  Value<int> streakDays,
  Value<DateTime?> lastLoginDate,
  Value<int> previousStreakDays,
  Value<bool> streakShieldAvailable,
});
typedef $$HeroStateTableTableUpdateCompanionBuilder = HeroStateTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> archetype,
  Value<int> level,
  Value<int> currentXp,
  Value<int> maxXp,
  Value<int> currentHp,
  Value<int> maxHp,
  Value<int> coins,
  Value<int> streakDays,
  Value<DateTime?> lastLoginDate,
  Value<int> previousStreakDays,
  Value<bool> streakShieldAvailable,
});

class $$HeroStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $HeroStateTableTable> {
  $$HeroStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archetype => $composableBuilder(
      column: $table.archetype, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentXp => $composableBuilder(
      column: $table.currentXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxXp => $composableBuilder(
      column: $table.maxXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coins => $composableBuilder(
      column: $table.coins, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streakDays => $composableBuilder(
      column: $table.streakDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLoginDate => $composableBuilder(
      column: $table.lastLoginDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get previousStreakDays => $composableBuilder(
      column: $table.previousStreakDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get streakShieldAvailable => $composableBuilder(
      column: $table.streakShieldAvailable,
      builder: (column) => ColumnFilters(column));
}

class $$HeroStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HeroStateTableTable> {
  $$HeroStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archetype => $composableBuilder(
      column: $table.archetype, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentXp => $composableBuilder(
      column: $table.currentXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxXp => $composableBuilder(
      column: $table.maxXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coins => $composableBuilder(
      column: $table.coins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streakDays => $composableBuilder(
      column: $table.streakDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLoginDate => $composableBuilder(
      column: $table.lastLoginDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get previousStreakDays => $composableBuilder(
      column: $table.previousStreakDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get streakShieldAvailable => $composableBuilder(
      column: $table.streakShieldAvailable,
      builder: (column) => ColumnOrderings(column));
}

class $$HeroStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeroStateTableTable> {
  $$HeroStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get archetype =>
      $composableBuilder(column: $table.archetype, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get currentXp =>
      $composableBuilder(column: $table.currentXp, builder: (column) => column);

  GeneratedColumn<int> get maxXp =>
      $composableBuilder(column: $table.maxXp, builder: (column) => column);

  GeneratedColumn<int> get currentHp =>
      $composableBuilder(column: $table.currentHp, builder: (column) => column);

  GeneratedColumn<int> get maxHp =>
      $composableBuilder(column: $table.maxHp, builder: (column) => column);

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);

  GeneratedColumn<int> get streakDays => $composableBuilder(
      column: $table.streakDays, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginDate => $composableBuilder(
      column: $table.lastLoginDate, builder: (column) => column);

  GeneratedColumn<int> get previousStreakDays => $composableBuilder(
      column: $table.previousStreakDays, builder: (column) => column);

  GeneratedColumn<bool> get streakShieldAvailable => $composableBuilder(
      column: $table.streakShieldAvailable, builder: (column) => column);
}

class $$HeroStateTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HeroStateTableTable,
    HeroStateTableData,
    $$HeroStateTableTableFilterComposer,
    $$HeroStateTableTableOrderingComposer,
    $$HeroStateTableTableAnnotationComposer,
    $$HeroStateTableTableCreateCompanionBuilder,
    $$HeroStateTableTableUpdateCompanionBuilder,
    (
      HeroStateTableData,
      BaseReferences<_$AppDatabase, $HeroStateTableTable, HeroStateTableData>
    ),
    HeroStateTableData,
    PrefetchHooks Function()> {
  $$HeroStateTableTableTableManager(
      _$AppDatabase db, $HeroStateTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeroStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeroStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeroStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> archetype = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> currentXp = const Value.absent(),
            Value<int> maxXp = const Value.absent(),
            Value<int> currentHp = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> coins = const Value.absent(),
            Value<int> streakDays = const Value.absent(),
            Value<DateTime?> lastLoginDate = const Value.absent(),
            Value<int> previousStreakDays = const Value.absent(),
            Value<bool> streakShieldAvailable = const Value.absent(),
          }) =>
              HeroStateTableCompanion(
            id: id,
            name: name,
            archetype: archetype,
            level: level,
            currentXp: currentXp,
            maxXp: maxXp,
            currentHp: currentHp,
            maxHp: maxHp,
            coins: coins,
            streakDays: streakDays,
            lastLoginDate: lastLoginDate,
            previousStreakDays: previousStreakDays,
            streakShieldAvailable: streakShieldAvailable,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> archetype = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> currentXp = const Value.absent(),
            Value<int> maxXp = const Value.absent(),
            Value<int> currentHp = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> coins = const Value.absent(),
            Value<int> streakDays = const Value.absent(),
            Value<DateTime?> lastLoginDate = const Value.absent(),
            Value<int> previousStreakDays = const Value.absent(),
            Value<bool> streakShieldAvailable = const Value.absent(),
          }) =>
              HeroStateTableCompanion.insert(
            id: id,
            name: name,
            archetype: archetype,
            level: level,
            currentXp: currentXp,
            maxXp: maxXp,
            currentHp: currentHp,
            maxHp: maxHp,
            coins: coins,
            streakDays: streakDays,
            lastLoginDate: lastLoginDate,
            previousStreakDays: previousStreakDays,
            streakShieldAvailable: streakShieldAvailable,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$HeroStateTableTable, HeroStateTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $HeroStateTableTable,
                        HeroStateTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HeroStateTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HeroStateTableTable,
    HeroStateTableData,
    $$HeroStateTableTableFilterComposer,
    $$HeroStateTableTableOrderingComposer,
    $$HeroStateTableTableAnnotationComposer,
    $$HeroStateTableTableCreateCompanionBuilder,
    $$HeroStateTableTableUpdateCompanionBuilder,
    (
      HeroStateTableData,
      BaseReferences<_$AppDatabase, $HeroStateTableTable, HeroStateTableData>
    ),
    HeroStateTableData,
    PrefetchHooks Function()>;
typedef $$QuestsTableTableCreateCompanionBuilder = QuestsTableCompanion
    Function({
  required String id,
  required DateTime date,
  required String title,
  required String description,
  required String type,
  required double targetValue,
  required double progressValue,
  required int rewardXp,
  required int rewardCoins,
  Value<bool> isCompleted,
  Value<bool> isClaimed,
  Value<int> rowid,
});
typedef $$QuestsTableTableUpdateCompanionBuilder = QuestsTableCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String> title,
  Value<String> description,
  Value<String> type,
  Value<double> targetValue,
  Value<double> progressValue,
  Value<int> rewardXp,
  Value<int> rewardCoins,
  Value<bool> isCompleted,
  Value<bool> isClaimed,
  Value<int> rowid,
});

class $$QuestsTableTableFilterComposer
    extends Composer<_$AppDatabase, $QuestsTableTable> {
  $$QuestsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progressValue => $composableBuilder(
      column: $table.progressValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rewardXp => $composableBuilder(
      column: $table.rewardXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rewardCoins => $composableBuilder(
      column: $table.rewardCoins, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isClaimed => $composableBuilder(
      column: $table.isClaimed, builder: (column) => ColumnFilters(column));
}

class $$QuestsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestsTableTable> {
  $$QuestsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progressValue => $composableBuilder(
      column: $table.progressValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rewardXp => $composableBuilder(
      column: $table.rewardXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rewardCoins => $composableBuilder(
      column: $table.rewardCoins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isClaimed => $composableBuilder(
      column: $table.isClaimed, builder: (column) => ColumnOrderings(column));
}

class $$QuestsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestsTableTable> {
  $$QuestsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => column);

  GeneratedColumn<double> get progressValue => $composableBuilder(
      column: $table.progressValue, builder: (column) => column);

  GeneratedColumn<int> get rewardXp =>
      $composableBuilder(column: $table.rewardXp, builder: (column) => column);

  GeneratedColumn<int> get rewardCoins => $composableBuilder(
      column: $table.rewardCoins, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isClaimed =>
      $composableBuilder(column: $table.isClaimed, builder: (column) => column);
}

class $$QuestsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestsTableTable,
    QuestsTableData,
    $$QuestsTableTableFilterComposer,
    $$QuestsTableTableOrderingComposer,
    $$QuestsTableTableAnnotationComposer,
    $$QuestsTableTableCreateCompanionBuilder,
    $$QuestsTableTableUpdateCompanionBuilder,
    (
      QuestsTableData,
      BaseReferences<_$AppDatabase, $QuestsTableTable, QuestsTableData>
    ),
    QuestsTableData,
    PrefetchHooks Function()> {
  $$QuestsTableTableTableManager(_$AppDatabase db, $QuestsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> targetValue = const Value.absent(),
            Value<double> progressValue = const Value.absent(),
            Value<int> rewardXp = const Value.absent(),
            Value<int> rewardCoins = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isClaimed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestsTableCompanion(
            id: id,
            date: date,
            title: title,
            description: description,
            type: type,
            targetValue: targetValue,
            progressValue: progressValue,
            rewardXp: rewardXp,
            rewardCoins: rewardCoins,
            isCompleted: isCompleted,
            isClaimed: isClaimed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required String title,
            required String description,
            required String type,
            required double targetValue,
            required double progressValue,
            required int rewardXp,
            required int rewardCoins,
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isClaimed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestsTableCompanion.insert(
            id: id,
            date: date,
            title: title,
            description: description,
            type: type,
            targetValue: targetValue,
            progressValue: progressValue,
            rewardXp: rewardXp,
            rewardCoins: rewardCoins,
            isCompleted: isCompleted,
            isClaimed: isClaimed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$QuestsTableTable, QuestsTableData>(table),
                    BaseReferences<_$AppDatabase, $QuestsTableTable,
                        QuestsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuestsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestsTableTable,
    QuestsTableData,
    $$QuestsTableTableFilterComposer,
    $$QuestsTableTableOrderingComposer,
    $$QuestsTableTableAnnotationComposer,
    $$QuestsTableTableCreateCompanionBuilder,
    $$QuestsTableTableUpdateCompanionBuilder,
    (
      QuestsTableData,
      BaseReferences<_$AppDatabase, $QuestsTableTable, QuestsTableData>
    ),
    QuestsTableData,
    PrefetchHooks Function()>;
typedef $$AchievementsTableTableCreateCompanionBuilder
    = AchievementsTableCompanion Function({
  required String id,
  required String title,
  required String description,
  required String icon,
  Value<DateTime?> unlockedAt,
  Value<int> rowid,
});
typedef $$AchievementsTableTableUpdateCompanionBuilder
    = AchievementsTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> icon,
  Value<DateTime?> unlockedAt,
  Value<int> rowid,
});

class $$AchievementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));
}

class $$AchievementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));
}

class $$AchievementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTableTable> {
  $$AchievementsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);
}

class $$AchievementsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsTableTable,
    AchievementsTableData,
    $$AchievementsTableTableFilterComposer,
    $$AchievementsTableTableOrderingComposer,
    $$AchievementsTableTableAnnotationComposer,
    $$AchievementsTableTableCreateCompanionBuilder,
    $$AchievementsTableTableUpdateCompanionBuilder,
    (
      AchievementsTableData,
      BaseReferences<_$AppDatabase, $AchievementsTableTable,
          AchievementsTableData>
    ),
    AchievementsTableData,
    PrefetchHooks Function()> {
  $$AchievementsTableTableTableManager(
      _$AppDatabase db, $AchievementsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsTableCompanion(
            id: id,
            title: title,
            description: description,
            icon: icon,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required String icon,
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsTableCompanion.insert(
            id: id,
            title: title,
            description: description,
            icon: icon,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AchievementsTableTable, AchievementsTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $AchievementsTableTable,
                        AchievementsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsTableTable,
    AchievementsTableData,
    $$AchievementsTableTableFilterComposer,
    $$AchievementsTableTableOrderingComposer,
    $$AchievementsTableTableAnnotationComposer,
    $$AchievementsTableTableCreateCompanionBuilder,
    $$AchievementsTableTableUpdateCompanionBuilder,
    (
      AchievementsTableData,
      BaseReferences<_$AppDatabase, $AchievementsTableTable,
          AchievementsTableData>
    ),
    AchievementsTableData,
    PrefetchHooks Function()>;
typedef $$SavingsGoalsTableTableCreateCompanionBuilder
    = SavingsGoalsTableCompanion Function({
  required String id,
  required String title,
  required int targetAmountPaise,
  required int savedAmountPaise,
  Value<String> icon,
  Value<bool> isPrimary,
  Value<DateTime?> deadline,
  Value<bool> isCompleted,
  Value<int> rowid,
});
typedef $$SavingsGoalsTableTableUpdateCompanionBuilder
    = SavingsGoalsTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<int> targetAmountPaise,
  Value<int> savedAmountPaise,
  Value<String> icon,
  Value<bool> isPrimary,
  Value<DateTime?> deadline,
  Value<bool> isCompleted,
  Value<int> rowid,
});

class $$SavingsGoalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTableTable> {
  $$SavingsGoalsTableTableFilterComposer({
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

  ColumnFilters<int> get targetAmountPaise => $composableBuilder(
      column: $table.targetAmountPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get savedAmountPaise => $composableBuilder(
      column: $table.savedAmountPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));
}

class $$SavingsGoalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTableTable> {
  $$SavingsGoalsTableTableOrderingComposer({
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

  ColumnOrderings<int> get targetAmountPaise => $composableBuilder(
      column: $table.targetAmountPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get savedAmountPaise => $composableBuilder(
      column: $table.savedAmountPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));
}

class $$SavingsGoalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTableTable> {
  $$SavingsGoalsTableTableAnnotationComposer({
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

  GeneratedColumn<int> get targetAmountPaise => $composableBuilder(
      column: $table.targetAmountPaise, builder: (column) => column);

  GeneratedColumn<int> get savedAmountPaise => $composableBuilder(
      column: $table.savedAmountPaise, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);
}

class $$SavingsGoalsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavingsGoalsTableTable,
    SavingsGoalsTableData,
    $$SavingsGoalsTableTableFilterComposer,
    $$SavingsGoalsTableTableOrderingComposer,
    $$SavingsGoalsTableTableAnnotationComposer,
    $$SavingsGoalsTableTableCreateCompanionBuilder,
    $$SavingsGoalsTableTableUpdateCompanionBuilder,
    (
      SavingsGoalsTableData,
      BaseReferences<_$AppDatabase, $SavingsGoalsTableTable,
          SavingsGoalsTableData>
    ),
    SavingsGoalsTableData,
    PrefetchHooks Function()> {
  $$SavingsGoalsTableTableTableManager(
      _$AppDatabase db, $SavingsGoalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> targetAmountPaise = const Value.absent(),
            Value<int> savedAmountPaise = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingsGoalsTableCompanion(
            id: id,
            title: title,
            targetAmountPaise: targetAmountPaise,
            savedAmountPaise: savedAmountPaise,
            icon: icon,
            isPrimary: isPrimary,
            deadline: deadline,
            isCompleted: isCompleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required int targetAmountPaise,
            required int savedAmountPaise,
            Value<String> icon = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingsGoalsTableCompanion.insert(
            id: id,
            title: title,
            targetAmountPaise: targetAmountPaise,
            savedAmountPaise: savedAmountPaise,
            icon: icon,
            isPrimary: isPrimary,
            deadline: deadline,
            isCompleted: isCompleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SavingsGoalsTableTable, SavingsGoalsTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $SavingsGoalsTableTable,
                        SavingsGoalsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavingsGoalsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavingsGoalsTableTable,
    SavingsGoalsTableData,
    $$SavingsGoalsTableTableFilterComposer,
    $$SavingsGoalsTableTableOrderingComposer,
    $$SavingsGoalsTableTableAnnotationComposer,
    $$SavingsGoalsTableTableCreateCompanionBuilder,
    $$SavingsGoalsTableTableUpdateCompanionBuilder,
    (
      SavingsGoalsTableData,
      BaseReferences<_$AppDatabase, $SavingsGoalsTableTable,
          SavingsGoalsTableData>
    ),
    SavingsGoalsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
  $$CyclesTableTableTableManager get cyclesTable =>
      $$CyclesTableTableTableManager(_db, _db.cyclesTable);
  $$DailyBudgetsTableTableTableManager get dailyBudgetsTable =>
      $$DailyBudgetsTableTableTableManager(_db, _db.dailyBudgetsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$HeroStateTableTableTableManager get heroStateTable =>
      $$HeroStateTableTableTableManager(_db, _db.heroStateTable);
  $$QuestsTableTableTableManager get questsTable =>
      $$QuestsTableTableTableManager(_db, _db.questsTable);
  $$AchievementsTableTableTableManager get achievementsTable =>
      $$AchievementsTableTableTableManager(_db, _db.achievementsTable);
  $$SavingsGoalsTableTableTableManager get savingsGoalsTable =>
      $$SavingsGoalsTableTableTableManager(_db, _db.savingsGoalsTable);
}
