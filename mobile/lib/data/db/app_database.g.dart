// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VillagesTable extends Villages
    with TableInfo<$VillagesTable, VillageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VillagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus = GeneratedColumn<int>(
    'local_sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(LocalSyncStatus.synced.index),
  ).withConverter<LocalSyncStatus>($VillagesTable.$converterlocalSyncStatus);
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    name,
    district,
    city,
    lat,
    lng,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'villages';
  @override
  VerificationContext validateIntegrity(
    Insertable<VillageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VillageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VillageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $VillagesTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
    );
  }

  @override
  $VillagesTable createAlias(String alias) {
    return $VillagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class VillageRow extends DataClass implements Insertable<VillageRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String name;
  final String? district;
  final String? city;
  final double? lat;
  final double? lng;
  const VillageRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    required this.name,
    this.district,
    this.city,
    this.lat,
    this.lng,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $VillagesTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    return map;
  }

  VillagesCompanion toCompanion(bool nullToAbsent) {
    return VillagesCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      name: Value(name),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
    );
  }

  factory VillageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VillageRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $VillagesTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      name: serializer.fromJson<String>(json['name']),
      district: serializer.fromJson<String?>(json['district']),
      city: serializer.fromJson<String?>(json['city']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $VillagesTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'name': serializer.toJson<String>(name),
      'district': serializer.toJson<String?>(district),
      'city': serializer.toJson<String?>(city),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
    };
  }

  VillageRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    String? name,
    Value<String?> district = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
  }) => VillageRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    name: name ?? this.name,
    district: district.present ? district.value : this.district,
    city: city.present ? city.value : this.city,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
  );
  VillageRow copyWithCompanion(VillagesCompanion data) {
    return VillageRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      name: data.name.present ? data.name.value : this.name,
      district: data.district.present ? data.district.value : this.district,
      city: data.city.present ? data.city.value : this.city,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VillageRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('name: $name, ')
          ..write('district: $district, ')
          ..write('city: $city, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    name,
    district,
    city,
    lat,
    lng,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VillageRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.name == this.name &&
          other.district == this.district &&
          other.city == this.city &&
          other.lat == this.lat &&
          other.lng == this.lng);
}

class VillagesCompanion extends UpdateCompanion<VillageRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String> name;
  final Value<String?> district;
  final Value<String?> city;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<int> rowid;
  const VillagesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.name = const Value.absent(),
    this.district = const Value.absent(),
    this.city = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VillagesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    required String name,
    this.district = const Value.absent(),
    this.city = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<VillageRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? name,
    Expression<String>? district,
    Expression<String>? city,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (name != null) 'name': name,
      if (district != null) 'district': district,
      if (city != null) 'city': city,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VillagesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String>? name,
    Value<String?>? district,
    Value<String?>? city,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<int>? rowid,
  }) {
    return VillagesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      name: name ?? this.name,
      district: district ?? this.district,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $VillagesTable.$converterlocalSyncStatus.toSql(localSyncStatus.value),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VillagesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('name: $name, ')
          ..write('district: $district, ')
          ..write('city: $city, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmersTable extends Farmers with TableInfo<$FarmersTable, FarmerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus = GeneratedColumn<int>(
    'local_sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(LocalSyncStatus.synced.index),
  ).withConverter<LocalSyncStatus>($FarmersTable.$converterlocalSyncStatus);
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressDetailMeta = const VerificationMeta(
    'addressDetail',
  );
  @override
  late final GeneratedColumn<String> addressDetail = GeneratedColumn<String>(
    'address_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _smsNotificationsEnabledMeta =
      const VerificationMeta('smsNotificationsEnabled');
  @override
  late final GeneratedColumn<bool> smsNotificationsEnabled =
      GeneratedColumn<bool>(
        'sms_notifications_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sms_notifications_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _preferredSmsLanguageMeta =
      const VerificationMeta('preferredSmsLanguage');
  @override
  late final GeneratedColumn<String> preferredSmsLanguage =
      GeneratedColumn<String>(
        'preferred_sms_language',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('tr'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    villageId,
    firstName,
    lastName,
    phone,
    email,
    addressDetail,
    balance,
    smsNotificationsEnabled,
    preferredSmsLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farmers';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address_detail')) {
      context.handle(
        _addressDetailMeta,
        addressDetail.isAcceptableOrUnknown(
          data['address_detail']!,
          _addressDetailMeta,
        ),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('sms_notifications_enabled')) {
      context.handle(
        _smsNotificationsEnabledMeta,
        smsNotificationsEnabled.isAcceptableOrUnknown(
          data['sms_notifications_enabled']!,
          _smsNotificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('preferred_sms_language')) {
      context.handle(
        _preferredSmsLanguageMeta,
        preferredSmsLanguage.isAcceptableOrUnknown(
          data['preferred_sms_language']!,
          _preferredSmsLanguageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $FarmersTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_id'],
      ),
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      addressDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_detail'],
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      smsNotificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sms_notifications_enabled'],
      )!,
      preferredSmsLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_sms_language'],
      )!,
    );
  }

  @override
  $FarmersTable createAlias(String alias) {
    return $FarmersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class FarmerRow extends DataClass implements Insertable<FarmerRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String? villageId;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? addressDetail;
  final double balance;
  final bool smsNotificationsEnabled;
  final String preferredSmsLanguage;
  const FarmerRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    this.villageId,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    this.addressDetail,
    required this.balance,
    required this.smsNotificationsEnabled,
    required this.preferredSmsLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $FarmersTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    if (!nullToAbsent || villageId != null) {
      map['village_id'] = Variable<String>(villageId);
    }
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || addressDetail != null) {
      map['address_detail'] = Variable<String>(addressDetail);
    }
    map['balance'] = Variable<double>(balance);
    map['sms_notifications_enabled'] = Variable<bool>(smsNotificationsEnabled);
    map['preferred_sms_language'] = Variable<String>(preferredSmsLanguage);
    return map;
  }

  FarmersCompanion toCompanion(bool nullToAbsent) {
    return FarmersCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      villageId: villageId == null && nullToAbsent
          ? const Value.absent()
          : Value(villageId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      addressDetail: addressDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(addressDetail),
      balance: Value(balance),
      smsNotificationsEnabled: Value(smsNotificationsEnabled),
      preferredSmsLanguage: Value(preferredSmsLanguage),
    );
  }

  factory FarmerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmerRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $FarmersTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      villageId: serializer.fromJson<String?>(json['villageId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      addressDetail: serializer.fromJson<String?>(json['addressDetail']),
      balance: serializer.fromJson<double>(json['balance']),
      smsNotificationsEnabled: serializer.fromJson<bool>(
        json['smsNotificationsEnabled'],
      ),
      preferredSmsLanguage: serializer.fromJson<String>(
        json['preferredSmsLanguage'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $FarmersTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'villageId': serializer.toJson<String?>(villageId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'addressDetail': serializer.toJson<String?>(addressDetail),
      'balance': serializer.toJson<double>(balance),
      'smsNotificationsEnabled': serializer.toJson<bool>(
        smsNotificationsEnabled,
      ),
      'preferredSmsLanguage': serializer.toJson<String>(preferredSmsLanguage),
    };
  }

  FarmerRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    Value<String?> villageId = const Value.absent(),
    String? firstName,
    String? lastName,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> addressDetail = const Value.absent(),
    double? balance,
    bool? smsNotificationsEnabled,
    String? preferredSmsLanguage,
  }) => FarmerRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    villageId: villageId.present ? villageId.value : this.villageId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    addressDetail: addressDetail.present
        ? addressDetail.value
        : this.addressDetail,
    balance: balance ?? this.balance,
    smsNotificationsEnabled:
        smsNotificationsEnabled ?? this.smsNotificationsEnabled,
    preferredSmsLanguage: preferredSmsLanguage ?? this.preferredSmsLanguage,
  );
  FarmerRow copyWithCompanion(FarmersCompanion data) {
    return FarmerRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      addressDetail: data.addressDetail.present
          ? data.addressDetail.value
          : this.addressDetail,
      balance: data.balance.present ? data.balance.value : this.balance,
      smsNotificationsEnabled: data.smsNotificationsEnabled.present
          ? data.smsNotificationsEnabled.value
          : this.smsNotificationsEnabled,
      preferredSmsLanguage: data.preferredSmsLanguage.present
          ? data.preferredSmsLanguage.value
          : this.preferredSmsLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmerRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('villageId: $villageId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('addressDetail: $addressDetail, ')
          ..write('balance: $balance, ')
          ..write('smsNotificationsEnabled: $smsNotificationsEnabled, ')
          ..write('preferredSmsLanguage: $preferredSmsLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    villageId,
    firstName,
    lastName,
    phone,
    email,
    addressDetail,
    balance,
    smsNotificationsEnabled,
    preferredSmsLanguage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmerRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.villageId == this.villageId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.addressDetail == this.addressDetail &&
          other.balance == this.balance &&
          other.smsNotificationsEnabled == this.smsNotificationsEnabled &&
          other.preferredSmsLanguage == this.preferredSmsLanguage);
}

class FarmersCompanion extends UpdateCompanion<FarmerRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String?> villageId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> addressDetail;
  final Value<double> balance;
  final Value<bool> smsNotificationsEnabled;
  final Value<String> preferredSmsLanguage;
  final Value<int> rowid;
  const FarmersCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.villageId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.addressDetail = const Value.absent(),
    this.balance = const Value.absent(),
    this.smsNotificationsEnabled = const Value.absent(),
    this.preferredSmsLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmersCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.villageId = const Value.absent(),
    required String firstName,
    required String lastName,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.addressDetail = const Value.absent(),
    this.balance = const Value.absent(),
    this.smsNotificationsEnabled = const Value.absent(),
    this.preferredSmsLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       firstName = Value(firstName),
       lastName = Value(lastName);
  static Insertable<FarmerRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? villageId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? addressDetail,
    Expression<double>? balance,
    Expression<bool>? smsNotificationsEnabled,
    Expression<String>? preferredSmsLanguage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (villageId != null) 'village_id': villageId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (addressDetail != null) 'address_detail': addressDetail,
      if (balance != null) 'balance': balance,
      if (smsNotificationsEnabled != null)
        'sms_notifications_enabled': smsNotificationsEnabled,
      if (preferredSmsLanguage != null)
        'preferred_sms_language': preferredSmsLanguage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmersCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String?>? villageId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? addressDetail,
    Value<double>? balance,
    Value<bool>? smsNotificationsEnabled,
    Value<String>? preferredSmsLanguage,
    Value<int>? rowid,
  }) {
    return FarmersCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      villageId: villageId ?? this.villageId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      addressDetail: addressDetail ?? this.addressDetail,
      balance: balance ?? this.balance,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      preferredSmsLanguage: preferredSmsLanguage ?? this.preferredSmsLanguage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $FarmersTable.$converterlocalSyncStatus.toSql(localSyncStatus.value),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (addressDetail.present) {
      map['address_detail'] = Variable<String>(addressDetail.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (smsNotificationsEnabled.present) {
      map['sms_notifications_enabled'] = Variable<bool>(
        smsNotificationsEnabled.value,
      );
    }
    if (preferredSmsLanguage.present) {
      map['preferred_sms_language'] = Variable<String>(
        preferredSmsLanguage.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmersCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('villageId: $villageId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('addressDetail: $addressDetail, ')
          ..write('balance: $balance, ')
          ..write('smsNotificationsEnabled: $smsNotificationsEnabled, ')
          ..write('preferredSmsLanguage: $preferredSmsLanguage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalsTable extends Animals with TableInfo<$AnimalsTable, AnimalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus = GeneratedColumn<int>(
    'local_sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(LocalSyncStatus.synced.index),
  ).withConverter<LocalSyncStatus>($AnimalsTable.$converterlocalSyncStatus);
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _earTagMeta = const VerificationMeta('earTag');
  @override
  late final GeneratedColumn<String> earTag = GeneratedColumn<String>(
    'ear_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPregnantMeta = const VerificationMeta(
    'isPregnant',
  );
  @override
  late final GeneratedColumn<bool> isPregnant = GeneratedColumn<bool>(
    'is_pregnant',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pregnant" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastVaccinationAtMeta = const VerificationMeta(
    'lastVaccinationAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVaccinationAt =
      GeneratedColumn<DateTime>(
        'last_vaccination_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('alive'),
  );
  static const VerificationMeta _statusChangedAtMeta = const VerificationMeta(
    'statusChangedAt',
  );
  @override
  late final GeneratedColumn<DateTime> statusChangedAt =
      GeneratedColumn<DateTime>(
        'status_changed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusNotesMeta = const VerificationMeta(
    'statusNotes',
  );
  @override
  late final GeneratedColumn<String> statusNotes = GeneratedColumn<String>(
    'status_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    farmerId,
    villageId,
    earTag,
    name,
    species,
    breed,
    birthDate,
    gender,
    weightKg,
    color,
    isPregnant,
    lastVaccinationAt,
    status,
    statusChangedAt,
    statusNotes,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animals';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    }
    if (data.containsKey('ear_tag')) {
      context.handle(
        _earTagMeta,
        earTag.isAcceptableOrUnknown(data['ear_tag']!, _earTagMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_pregnant')) {
      context.handle(
        _isPregnantMeta,
        isPregnant.isAcceptableOrUnknown(data['is_pregnant']!, _isPregnantMeta),
      );
    }
    if (data.containsKey('last_vaccination_at')) {
      context.handle(
        _lastVaccinationAtMeta,
        lastVaccinationAt.isAcceptableOrUnknown(
          data['last_vaccination_at']!,
          _lastVaccinationAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('status_changed_at')) {
      context.handle(
        _statusChangedAtMeta,
        statusChangedAt.isAcceptableOrUnknown(
          data['status_changed_at']!,
          _statusChangedAtMeta,
        ),
      );
    }
    if (data.containsKey('status_notes')) {
      context.handle(
        _statusNotesMeta,
        statusNotes.isAcceptableOrUnknown(
          data['status_notes']!,
          _statusNotesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $AnimalsTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_id'],
      )!,
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_id'],
      ),
      earTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ear_tag'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      isPregnant: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pregnant'],
      )!,
      lastVaccinationAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_vaccination_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      statusChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}status_changed_at'],
      ),
      statusNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_notes'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $AnimalsTable createAlias(String alias) {
    return $AnimalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class AnimalRow extends DataClass implements Insertable<AnimalRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String farmerId;
  final String? villageId;
  final String? earTag;
  final String? name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final String? gender;
  final double? weightKg;
  final String? color;
  final bool isPregnant;
  final DateTime? lastVaccinationAt;
  final String status;
  final DateTime? statusChangedAt;
  final String? statusNotes;
  final String? notes;
  const AnimalRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    required this.farmerId,
    this.villageId,
    this.earTag,
    this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.gender,
    this.weightKg,
    this.color,
    required this.isPregnant,
    this.lastVaccinationAt,
    required this.status,
    this.statusChangedAt,
    this.statusNotes,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $AnimalsTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    map['farmer_id'] = Variable<String>(farmerId);
    if (!nullToAbsent || villageId != null) {
      map['village_id'] = Variable<String>(villageId);
    }
    if (!nullToAbsent || earTag != null) {
      map['ear_tag'] = Variable<String>(earTag);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_pregnant'] = Variable<bool>(isPregnant);
    if (!nullToAbsent || lastVaccinationAt != null) {
      map['last_vaccination_at'] = Variable<DateTime>(lastVaccinationAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || statusChangedAt != null) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt);
    }
    if (!nullToAbsent || statusNotes != null) {
      map['status_notes'] = Variable<String>(statusNotes);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AnimalsCompanion toCompanion(bool nullToAbsent) {
    return AnimalsCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      farmerId: Value(farmerId),
      villageId: villageId == null && nullToAbsent
          ? const Value.absent()
          : Value(villageId),
      earTag: earTag == null && nullToAbsent
          ? const Value.absent()
          : Value(earTag),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      species: Value(species),
      breed: breed == null && nullToAbsent
          ? const Value.absent()
          : Value(breed),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isPregnant: Value(isPregnant),
      lastVaccinationAt: lastVaccinationAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVaccinationAt),
      status: Value(status),
      statusChangedAt: statusChangedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statusChangedAt),
      statusNotes: statusNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(statusNotes),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory AnimalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $AnimalsTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      villageId: serializer.fromJson<String?>(json['villageId']),
      earTag: serializer.fromJson<String?>(json['earTag']),
      name: serializer.fromJson<String?>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String?>(json['breed']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      gender: serializer.fromJson<String?>(json['gender']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      color: serializer.fromJson<String?>(json['color']),
      isPregnant: serializer.fromJson<bool>(json['isPregnant']),
      lastVaccinationAt: serializer.fromJson<DateTime?>(
        json['lastVaccinationAt'],
      ),
      status: serializer.fromJson<String>(json['status']),
      statusChangedAt: serializer.fromJson<DateTime?>(json['statusChangedAt']),
      statusNotes: serializer.fromJson<String?>(json['statusNotes']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $AnimalsTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'farmerId': serializer.toJson<String>(farmerId),
      'villageId': serializer.toJson<String?>(villageId),
      'earTag': serializer.toJson<String?>(earTag),
      'name': serializer.toJson<String?>(name),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String?>(breed),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'gender': serializer.toJson<String?>(gender),
      'weightKg': serializer.toJson<double?>(weightKg),
      'color': serializer.toJson<String?>(color),
      'isPregnant': serializer.toJson<bool>(isPregnant),
      'lastVaccinationAt': serializer.toJson<DateTime?>(lastVaccinationAt),
      'status': serializer.toJson<String>(status),
      'statusChangedAt': serializer.toJson<DateTime?>(statusChangedAt),
      'statusNotes': serializer.toJson<String?>(statusNotes),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AnimalRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    String? farmerId,
    Value<String?> villageId = const Value.absent(),
    Value<String?> earTag = const Value.absent(),
    Value<String?> name = const Value.absent(),
    String? species,
    Value<String?> breed = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? isPregnant,
    Value<DateTime?> lastVaccinationAt = const Value.absent(),
    String? status,
    Value<DateTime?> statusChangedAt = const Value.absent(),
    Value<String?> statusNotes = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => AnimalRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    farmerId: farmerId ?? this.farmerId,
    villageId: villageId.present ? villageId.value : this.villageId,
    earTag: earTag.present ? earTag.value : this.earTag,
    name: name.present ? name.value : this.name,
    species: species ?? this.species,
    breed: breed.present ? breed.value : this.breed,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    gender: gender.present ? gender.value : this.gender,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    color: color.present ? color.value : this.color,
    isPregnant: isPregnant ?? this.isPregnant,
    lastVaccinationAt: lastVaccinationAt.present
        ? lastVaccinationAt.value
        : this.lastVaccinationAt,
    status: status ?? this.status,
    statusChangedAt: statusChangedAt.present
        ? statusChangedAt.value
        : this.statusChangedAt,
    statusNotes: statusNotes.present ? statusNotes.value : this.statusNotes,
    notes: notes.present ? notes.value : this.notes,
  );
  AnimalRow copyWithCompanion(AnimalsCompanion data) {
    return AnimalRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      earTag: data.earTag.present ? data.earTag.value : this.earTag,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      gender: data.gender.present ? data.gender.value : this.gender,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      color: data.color.present ? data.color.value : this.color,
      isPregnant: data.isPregnant.present
          ? data.isPregnant.value
          : this.isPregnant,
      lastVaccinationAt: data.lastVaccinationAt.present
          ? data.lastVaccinationAt.value
          : this.lastVaccinationAt,
      status: data.status.present ? data.status.value : this.status,
      statusChangedAt: data.statusChangedAt.present
          ? data.statusChangedAt.value
          : this.statusChangedAt,
      statusNotes: data.statusNotes.present
          ? data.statusNotes.value
          : this.statusNotes,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('farmerId: $farmerId, ')
          ..write('villageId: $villageId, ')
          ..write('earTag: $earTag, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('weightKg: $weightKg, ')
          ..write('color: $color, ')
          ..write('isPregnant: $isPregnant, ')
          ..write('lastVaccinationAt: $lastVaccinationAt, ')
          ..write('status: $status, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('statusNotes: $statusNotes, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    farmerId,
    villageId,
    earTag,
    name,
    species,
    breed,
    birthDate,
    gender,
    weightKg,
    color,
    isPregnant,
    lastVaccinationAt,
    status,
    statusChangedAt,
    statusNotes,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.farmerId == this.farmerId &&
          other.villageId == this.villageId &&
          other.earTag == this.earTag &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender &&
          other.weightKg == this.weightKg &&
          other.color == this.color &&
          other.isPregnant == this.isPregnant &&
          other.lastVaccinationAt == this.lastVaccinationAt &&
          other.status == this.status &&
          other.statusChangedAt == this.statusChangedAt &&
          other.statusNotes == this.statusNotes &&
          other.notes == this.notes);
}

class AnimalsCompanion extends UpdateCompanion<AnimalRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String> farmerId;
  final Value<String?> villageId;
  final Value<String?> earTag;
  final Value<String?> name;
  final Value<String> species;
  final Value<String?> breed;
  final Value<DateTime?> birthDate;
  final Value<String?> gender;
  final Value<double?> weightKg;
  final Value<String?> color;
  final Value<bool> isPregnant;
  final Value<DateTime?> lastVaccinationAt;
  final Value<String> status;
  final Value<DateTime?> statusChangedAt;
  final Value<String?> statusNotes;
  final Value<String?> notes;
  final Value<int> rowid;
  const AnimalsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.villageId = const Value.absent(),
    this.earTag = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.color = const Value.absent(),
    this.isPregnant = const Value.absent(),
    this.lastVaccinationAt = const Value.absent(),
    this.status = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.statusNotes = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    required String farmerId,
    this.villageId = const Value.absent(),
    this.earTag = const Value.absent(),
    this.name = const Value.absent(),
    required String species,
    this.breed = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.color = const Value.absent(),
    this.isPregnant = const Value.absent(),
    this.lastVaccinationAt = const Value.absent(),
    this.status = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.statusNotes = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmerId = Value(farmerId),
       species = Value(species);
  static Insertable<AnimalRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? farmerId,
    Expression<String>? villageId,
    Expression<String>? earTag,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<DateTime>? birthDate,
    Expression<String>? gender,
    Expression<double>? weightKg,
    Expression<String>? color,
    Expression<bool>? isPregnant,
    Expression<DateTime>? lastVaccinationAt,
    Expression<String>? status,
    Expression<DateTime>? statusChangedAt,
    Expression<String>? statusNotes,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (farmerId != null) 'farmer_id': farmerId,
      if (villageId != null) 'village_id': villageId,
      if (earTag != null) 'ear_tag': earTag,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (weightKg != null) 'weight_kg': weightKg,
      if (color != null) 'color': color,
      if (isPregnant != null) 'is_pregnant': isPregnant,
      if (lastVaccinationAt != null) 'last_vaccination_at': lastVaccinationAt,
      if (status != null) 'status': status,
      if (statusChangedAt != null) 'status_changed_at': statusChangedAt,
      if (statusNotes != null) 'status_notes': statusNotes,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String>? farmerId,
    Value<String?>? villageId,
    Value<String?>? earTag,
    Value<String?>? name,
    Value<String>? species,
    Value<String?>? breed,
    Value<DateTime?>? birthDate,
    Value<String?>? gender,
    Value<double?>? weightKg,
    Value<String?>? color,
    Value<bool>? isPregnant,
    Value<DateTime?>? lastVaccinationAt,
    Value<String>? status,
    Value<DateTime?>? statusChangedAt,
    Value<String?>? statusNotes,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return AnimalsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      farmerId: farmerId ?? this.farmerId,
      villageId: villageId ?? this.villageId,
      earTag: earTag ?? this.earTag,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      color: color ?? this.color,
      isPregnant: isPregnant ?? this.isPregnant,
      lastVaccinationAt: lastVaccinationAt ?? this.lastVaccinationAt,
      status: status ?? this.status,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      statusNotes: statusNotes ?? this.statusNotes,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $AnimalsTable.$converterlocalSyncStatus.toSql(localSyncStatus.value),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (earTag.present) {
      map['ear_tag'] = Variable<String>(earTag.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isPregnant.present) {
      map['is_pregnant'] = Variable<bool>(isPregnant.value);
    }
    if (lastVaccinationAt.present) {
      map['last_vaccination_at'] = Variable<DateTime>(lastVaccinationAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusChangedAt.present) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt.value);
    }
    if (statusNotes.present) {
      map['status_notes'] = Variable<String>(statusNotes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('farmerId: $farmerId, ')
          ..write('villageId: $villageId, ')
          ..write('earTag: $earTag, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('weightKg: $weightKg, ')
          ..write('color: $color, ')
          ..write('isPregnant: $isPregnant, ')
          ..write('lastVaccinationAt: $lastVaccinationAt, ')
          ..write('status: $status, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('statusNotes: $statusNotes, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, AppointmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus =
      GeneratedColumn<int>(
        'local_sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(LocalSyncStatus.synced.index),
      ).withConverter<LocalSyncStatus>(
        $AppointmentsTable.$converterlocalSyncStatus,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _animalIdMeta = const VerificationMeta(
    'animalId',
  );
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
    'animal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vetIdMeta = const VerificationMeta('vetId');
  @override
  late final GeneratedColumn<int> vetId = GeneratedColumn<int>(
    'vet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scheduled'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    farmerId,
    animalId,
    villageId,
    vetId,
    scheduledAt,
    reason,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppointmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    }
    if (data.containsKey('animal_id')) {
      context.handle(
        _animalIdMeta,
        animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta),
      );
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    }
    if (data.containsKey('vet_id')) {
      context.handle(
        _vetIdMeta,
        vetId.isAcceptableOrUnknown(data['vet_id']!, _vetIdMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppointmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppointmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $AppointmentsTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_id'],
      ),
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      ),
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_id'],
      ),
      vetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vet_id'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class AppointmentRow extends DataClass implements Insertable<AppointmentRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String? farmerId;
  final String? animalId;
  final String? villageId;
  final int? vetId;
  final DateTime scheduledAt;
  final String? reason;
  final String status;
  const AppointmentRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    this.farmerId,
    this.animalId,
    this.villageId,
    this.vetId,
    required this.scheduledAt,
    this.reason,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $AppointmentsTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    if (!nullToAbsent || farmerId != null) {
      map['farmer_id'] = Variable<String>(farmerId);
    }
    if (!nullToAbsent || animalId != null) {
      map['animal_id'] = Variable<String>(animalId);
    }
    if (!nullToAbsent || villageId != null) {
      map['village_id'] = Variable<String>(villageId);
    }
    if (!nullToAbsent || vetId != null) {
      map['vet_id'] = Variable<int>(vetId);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      farmerId: farmerId == null && nullToAbsent
          ? const Value.absent()
          : Value(farmerId),
      animalId: animalId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalId),
      villageId: villageId == null && nullToAbsent
          ? const Value.absent()
          : Value(villageId),
      vetId: vetId == null && nullToAbsent
          ? const Value.absent()
          : Value(vetId),
      scheduledAt: Value(scheduledAt),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      status: Value(status),
    );
  }

  factory AppointmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppointmentRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $AppointmentsTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      farmerId: serializer.fromJson<String?>(json['farmerId']),
      animalId: serializer.fromJson<String?>(json['animalId']),
      villageId: serializer.fromJson<String?>(json['villageId']),
      vetId: serializer.fromJson<int?>(json['vetId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      reason: serializer.fromJson<String?>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $AppointmentsTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'farmerId': serializer.toJson<String?>(farmerId),
      'animalId': serializer.toJson<String?>(animalId),
      'villageId': serializer.toJson<String?>(villageId),
      'vetId': serializer.toJson<int?>(vetId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'reason': serializer.toJson<String?>(reason),
      'status': serializer.toJson<String>(status),
    };
  }

  AppointmentRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    Value<String?> farmerId = const Value.absent(),
    Value<String?> animalId = const Value.absent(),
    Value<String?> villageId = const Value.absent(),
    Value<int?> vetId = const Value.absent(),
    DateTime? scheduledAt,
    Value<String?> reason = const Value.absent(),
    String? status,
  }) => AppointmentRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    farmerId: farmerId.present ? farmerId.value : this.farmerId,
    animalId: animalId.present ? animalId.value : this.animalId,
    villageId: villageId.present ? villageId.value : this.villageId,
    vetId: vetId.present ? vetId.value : this.vetId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    reason: reason.present ? reason.value : this.reason,
    status: status ?? this.status,
  );
  AppointmentRow copyWithCompanion(AppointmentsCompanion data) {
    return AppointmentRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      vetId: data.vetId.present ? data.vetId.value : this.vetId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('farmerId: $farmerId, ')
          ..write('animalId: $animalId, ')
          ..write('villageId: $villageId, ')
          ..write('vetId: $vetId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('reason: $reason, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    farmerId,
    animalId,
    villageId,
    vetId,
    scheduledAt,
    reason,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppointmentRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.farmerId == this.farmerId &&
          other.animalId == this.animalId &&
          other.villageId == this.villageId &&
          other.vetId == this.vetId &&
          other.scheduledAt == this.scheduledAt &&
          other.reason == this.reason &&
          other.status == this.status);
}

class AppointmentsCompanion extends UpdateCompanion<AppointmentRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String?> farmerId;
  final Value<String?> animalId;
  final Value<String?> villageId;
  final Value<int?> vetId;
  final Value<DateTime> scheduledAt;
  final Value<String?> reason;
  final Value<String> status;
  final Value<int> rowid;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.villageId = const Value.absent(),
    this.vetId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.villageId = const Value.absent(),
    this.vetId = const Value.absent(),
    required DateTime scheduledAt,
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scheduledAt = Value(scheduledAt);
  static Insertable<AppointmentRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? farmerId,
    Expression<String>? animalId,
    Expression<String>? villageId,
    Expression<int>? vetId,
    Expression<DateTime>? scheduledAt,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (farmerId != null) 'farmer_id': farmerId,
      if (animalId != null) 'animal_id': animalId,
      if (villageId != null) 'village_id': villageId,
      if (vetId != null) 'vet_id': vetId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String?>? farmerId,
    Value<String?>? animalId,
    Value<String?>? villageId,
    Value<int?>? vetId,
    Value<DateTime>? scheduledAt,
    Value<String?>? reason,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      farmerId: farmerId ?? this.farmerId,
      animalId: animalId ?? this.animalId,
      villageId: villageId ?? this.villageId,
      vetId: vetId ?? this.vetId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $AppointmentsTable.$converterlocalSyncStatus.toSql(
          localSyncStatus.value,
        ),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (vetId.present) {
      map['vet_id'] = Variable<int>(vetId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('farmerId: $farmerId, ')
          ..write('animalId: $animalId, ')
          ..write('villageId: $villageId, ')
          ..write('vetId: $vetId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicalRecordsTable extends MedicalRecords
    with TableInfo<$MedicalRecordsTable, MedicalRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus =
      GeneratedColumn<int>(
        'local_sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(LocalSyncStatus.synced.index),
      ).withConverter<LocalSyncStatus>(
        $MedicalRecordsTable.$converterlocalSyncStatus,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _animalIdMeta = const VerificationMeta(
    'animalId',
  );
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
    'animal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vetIdMeta = const VerificationMeta('vetId');
  @override
  late final GeneratedColumn<int> vetId = GeneratedColumn<int>(
    'vet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitTypeMeta = const VerificationMeta(
    'visitType',
  );
  @override
  late final GeneratedColumn<String> visitType = GeneratedColumn<String>(
    'visit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('routine'),
  );
  static const VerificationMeta _chiefComplaintMeta = const VerificationMeta(
    'chiefComplaint',
  );
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
    'chief_complaint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosisNotesMeta = const VerificationMeta(
    'diagnosisNotes',
  );
  @override
  late final GeneratedColumn<String> diagnosisNotes = GeneratedColumn<String>(
    'diagnosis_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _treatmentNotesMeta = const VerificationMeta(
    'treatmentNotes',
  );
  @override
  late final GeneratedColumn<String> treatmentNotes = GeneratedColumn<String>(
    'treatment_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendationsMeta = const VerificationMeta(
    'recommendations',
  );
  @override
  late final GeneratedColumn<String> recommendations = GeneratedColumn<String>(
    'recommendations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureCelsiusMeta =
      const VerificationMeta('temperatureCelsius');
  @override
  late final GeneratedColumn<double> temperatureCelsius =
      GeneratedColumn<double>(
        'temperature_celsius',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respiratoryRateMeta = const VerificationMeta(
    'respiratoryRate',
  );
  @override
  late final GeneratedColumn<int> respiratoryRate = GeneratedColumn<int>(
    'respiratory_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceFeeMeta = const VerificationMeta(
    'serviceFee',
  );
  @override
  late final GeneratedColumn<double> serviceFee = GeneratedColumn<double>(
    'service_fee',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examinedAtMeta = const VerificationMeta(
    'examinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> examinedAt = GeneratedColumn<DateTime>(
    'examined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _followUpNeededMeta = const VerificationMeta(
    'followUpNeeded',
  );
  @override
  late final GeneratedColumn<bool> followUpNeeded = GeneratedColumn<bool>(
    'follow_up_needed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("follow_up_needed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _followUpDateMeta = const VerificationMeta(
    'followUpDate',
  );
  @override
  late final GeneratedColumn<DateTime> followUpDate = GeneratedColumn<DateTime>(
    'follow_up_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    animalId,
    vetId,
    villageId,
    lat,
    lng,
    visitType,
    chiefComplaint,
    symptoms,
    diagnosisNotes,
    treatmentNotes,
    recommendations,
    temperatureCelsius,
    weightKg,
    heartRate,
    respiratoryRate,
    serviceFee,
    examinedAt,
    followUpNeeded,
    followUpDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medical_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicalRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('animal_id')) {
      context.handle(
        _animalIdMeta,
        animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('vet_id')) {
      context.handle(
        _vetIdMeta,
        vetId.isAcceptableOrUnknown(data['vet_id']!, _vetIdMeta),
      );
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('visit_type')) {
      context.handle(
        _visitTypeMeta,
        visitType.isAcceptableOrUnknown(data['visit_type']!, _visitTypeMeta),
      );
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
        _chiefComplaintMeta,
        chiefComplaint.isAcceptableOrUnknown(
          data['chief_complaint']!,
          _chiefComplaintMeta,
        ),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('diagnosis_notes')) {
      context.handle(
        _diagnosisNotesMeta,
        diagnosisNotes.isAcceptableOrUnknown(
          data['diagnosis_notes']!,
          _diagnosisNotesMeta,
        ),
      );
    }
    if (data.containsKey('treatment_notes')) {
      context.handle(
        _treatmentNotesMeta,
        treatmentNotes.isAcceptableOrUnknown(
          data['treatment_notes']!,
          _treatmentNotesMeta,
        ),
      );
    }
    if (data.containsKey('recommendations')) {
      context.handle(
        _recommendationsMeta,
        recommendations.isAcceptableOrUnknown(
          data['recommendations']!,
          _recommendationsMeta,
        ),
      );
    }
    if (data.containsKey('temperature_celsius')) {
      context.handle(
        _temperatureCelsiusMeta,
        temperatureCelsius.isAcceptableOrUnknown(
          data['temperature_celsius']!,
          _temperatureCelsiusMeta,
        ),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('respiratory_rate')) {
      context.handle(
        _respiratoryRateMeta,
        respiratoryRate.isAcceptableOrUnknown(
          data['respiratory_rate']!,
          _respiratoryRateMeta,
        ),
      );
    }
    if (data.containsKey('service_fee')) {
      context.handle(
        _serviceFeeMeta,
        serviceFee.isAcceptableOrUnknown(data['service_fee']!, _serviceFeeMeta),
      );
    }
    if (data.containsKey('examined_at')) {
      context.handle(
        _examinedAtMeta,
        examinedAt.isAcceptableOrUnknown(data['examined_at']!, _examinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_examinedAtMeta);
    }
    if (data.containsKey('follow_up_needed')) {
      context.handle(
        _followUpNeededMeta,
        followUpNeeded.isAcceptableOrUnknown(
          data['follow_up_needed']!,
          _followUpNeededMeta,
        ),
      );
    }
    if (data.containsKey('follow_up_date')) {
      context.handle(
        _followUpDateMeta,
        followUpDate.isAcceptableOrUnknown(
          data['follow_up_date']!,
          _followUpDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicalRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicalRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $MedicalRecordsTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      vetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vet_id'],
      ),
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_id'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      visitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_type'],
      )!,
      chiefComplaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chief_complaint'],
      ),
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      ),
      diagnosisNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosis_notes'],
      ),
      treatmentNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment_notes'],
      ),
      recommendations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommendations'],
      ),
      temperatureCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_celsius'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      respiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}respiratory_rate'],
      ),
      serviceFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}service_fee'],
      ),
      examinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}examined_at'],
      )!,
      followUpNeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}follow_up_needed'],
      )!,
      followUpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}follow_up_date'],
      ),
    );
  }

  @override
  $MedicalRecordsTable createAlias(String alias) {
    return $MedicalRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class MedicalRecordRow extends DataClass
    implements Insertable<MedicalRecordRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String animalId;
  final int? vetId;
  final String? villageId;
  final double? lat;
  final double? lng;
  final String visitType;
  final String? chiefComplaint;
  final String? symptoms;
  final String? diagnosisNotes;
  final String? treatmentNotes;
  final String? recommendations;
  final double? temperatureCelsius;
  final double? weightKg;
  final int? heartRate;
  final int? respiratoryRate;
  final double? serviceFee;
  final DateTime examinedAt;
  final bool followUpNeeded;
  final DateTime? followUpDate;
  const MedicalRecordRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    required this.animalId,
    this.vetId,
    this.villageId,
    this.lat,
    this.lng,
    required this.visitType,
    this.chiefComplaint,
    this.symptoms,
    this.diagnosisNotes,
    this.treatmentNotes,
    this.recommendations,
    this.temperatureCelsius,
    this.weightKg,
    this.heartRate,
    this.respiratoryRate,
    this.serviceFee,
    required this.examinedAt,
    required this.followUpNeeded,
    this.followUpDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $MedicalRecordsTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    map['animal_id'] = Variable<String>(animalId);
    if (!nullToAbsent || vetId != null) {
      map['vet_id'] = Variable<int>(vetId);
    }
    if (!nullToAbsent || villageId != null) {
      map['village_id'] = Variable<String>(villageId);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['visit_type'] = Variable<String>(visitType);
    if (!nullToAbsent || chiefComplaint != null) {
      map['chief_complaint'] = Variable<String>(chiefComplaint);
    }
    if (!nullToAbsent || symptoms != null) {
      map['symptoms'] = Variable<String>(symptoms);
    }
    if (!nullToAbsent || diagnosisNotes != null) {
      map['diagnosis_notes'] = Variable<String>(diagnosisNotes);
    }
    if (!nullToAbsent || treatmentNotes != null) {
      map['treatment_notes'] = Variable<String>(treatmentNotes);
    }
    if (!nullToAbsent || recommendations != null) {
      map['recommendations'] = Variable<String>(recommendations);
    }
    if (!nullToAbsent || temperatureCelsius != null) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    if (!nullToAbsent || respiratoryRate != null) {
      map['respiratory_rate'] = Variable<int>(respiratoryRate);
    }
    if (!nullToAbsent || serviceFee != null) {
      map['service_fee'] = Variable<double>(serviceFee);
    }
    map['examined_at'] = Variable<DateTime>(examinedAt);
    map['follow_up_needed'] = Variable<bool>(followUpNeeded);
    if (!nullToAbsent || followUpDate != null) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate);
    }
    return map;
  }

  MedicalRecordsCompanion toCompanion(bool nullToAbsent) {
    return MedicalRecordsCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      animalId: Value(animalId),
      vetId: vetId == null && nullToAbsent
          ? const Value.absent()
          : Value(vetId),
      villageId: villageId == null && nullToAbsent
          ? const Value.absent()
          : Value(villageId),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      visitType: Value(visitType),
      chiefComplaint: chiefComplaint == null && nullToAbsent
          ? const Value.absent()
          : Value(chiefComplaint),
      symptoms: symptoms == null && nullToAbsent
          ? const Value.absent()
          : Value(symptoms),
      diagnosisNotes: diagnosisNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosisNotes),
      treatmentNotes: treatmentNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(treatmentNotes),
      recommendations: recommendations == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendations),
      temperatureCelsius: temperatureCelsius == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureCelsius),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      respiratoryRate: respiratoryRate == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRate),
      serviceFee: serviceFee == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceFee),
      examinedAt: Value(examinedAt),
      followUpNeeded: Value(followUpNeeded),
      followUpDate: followUpDate == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpDate),
    );
  }

  factory MedicalRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicalRecordRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $MedicalRecordsTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      animalId: serializer.fromJson<String>(json['animalId']),
      vetId: serializer.fromJson<int?>(json['vetId']),
      villageId: serializer.fromJson<String?>(json['villageId']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      visitType: serializer.fromJson<String>(json['visitType']),
      chiefComplaint: serializer.fromJson<String?>(json['chiefComplaint']),
      symptoms: serializer.fromJson<String?>(json['symptoms']),
      diagnosisNotes: serializer.fromJson<String?>(json['diagnosisNotes']),
      treatmentNotes: serializer.fromJson<String?>(json['treatmentNotes']),
      recommendations: serializer.fromJson<String?>(json['recommendations']),
      temperatureCelsius: serializer.fromJson<double?>(
        json['temperatureCelsius'],
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      respiratoryRate: serializer.fromJson<int?>(json['respiratoryRate']),
      serviceFee: serializer.fromJson<double?>(json['serviceFee']),
      examinedAt: serializer.fromJson<DateTime>(json['examinedAt']),
      followUpNeeded: serializer.fromJson<bool>(json['followUpNeeded']),
      followUpDate: serializer.fromJson<DateTime?>(json['followUpDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $MedicalRecordsTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'animalId': serializer.toJson<String>(animalId),
      'vetId': serializer.toJson<int?>(vetId),
      'villageId': serializer.toJson<String?>(villageId),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'visitType': serializer.toJson<String>(visitType),
      'chiefComplaint': serializer.toJson<String?>(chiefComplaint),
      'symptoms': serializer.toJson<String?>(symptoms),
      'diagnosisNotes': serializer.toJson<String?>(diagnosisNotes),
      'treatmentNotes': serializer.toJson<String?>(treatmentNotes),
      'recommendations': serializer.toJson<String?>(recommendations),
      'temperatureCelsius': serializer.toJson<double?>(temperatureCelsius),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heartRate': serializer.toJson<int?>(heartRate),
      'respiratoryRate': serializer.toJson<int?>(respiratoryRate),
      'serviceFee': serializer.toJson<double?>(serviceFee),
      'examinedAt': serializer.toJson<DateTime>(examinedAt),
      'followUpNeeded': serializer.toJson<bool>(followUpNeeded),
      'followUpDate': serializer.toJson<DateTime?>(followUpDate),
    };
  }

  MedicalRecordRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    String? animalId,
    Value<int?> vetId = const Value.absent(),
    Value<String?> villageId = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    String? visitType,
    Value<String?> chiefComplaint = const Value.absent(),
    Value<String?> symptoms = const Value.absent(),
    Value<String?> diagnosisNotes = const Value.absent(),
    Value<String?> treatmentNotes = const Value.absent(),
    Value<String?> recommendations = const Value.absent(),
    Value<double?> temperatureCelsius = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<int?> heartRate = const Value.absent(),
    Value<int?> respiratoryRate = const Value.absent(),
    Value<double?> serviceFee = const Value.absent(),
    DateTime? examinedAt,
    bool? followUpNeeded,
    Value<DateTime?> followUpDate = const Value.absent(),
  }) => MedicalRecordRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    animalId: animalId ?? this.animalId,
    vetId: vetId.present ? vetId.value : this.vetId,
    villageId: villageId.present ? villageId.value : this.villageId,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    visitType: visitType ?? this.visitType,
    chiefComplaint: chiefComplaint.present
        ? chiefComplaint.value
        : this.chiefComplaint,
    symptoms: symptoms.present ? symptoms.value : this.symptoms,
    diagnosisNotes: diagnosisNotes.present
        ? diagnosisNotes.value
        : this.diagnosisNotes,
    treatmentNotes: treatmentNotes.present
        ? treatmentNotes.value
        : this.treatmentNotes,
    recommendations: recommendations.present
        ? recommendations.value
        : this.recommendations,
    temperatureCelsius: temperatureCelsius.present
        ? temperatureCelsius.value
        : this.temperatureCelsius,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    respiratoryRate: respiratoryRate.present
        ? respiratoryRate.value
        : this.respiratoryRate,
    serviceFee: serviceFee.present ? serviceFee.value : this.serviceFee,
    examinedAt: examinedAt ?? this.examinedAt,
    followUpNeeded: followUpNeeded ?? this.followUpNeeded,
    followUpDate: followUpDate.present ? followUpDate.value : this.followUpDate,
  );
  MedicalRecordRow copyWithCompanion(MedicalRecordsCompanion data) {
    return MedicalRecordRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      vetId: data.vetId.present ? data.vetId.value : this.vetId,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      visitType: data.visitType.present ? data.visitType.value : this.visitType,
      chiefComplaint: data.chiefComplaint.present
          ? data.chiefComplaint.value
          : this.chiefComplaint,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      diagnosisNotes: data.diagnosisNotes.present
          ? data.diagnosisNotes.value
          : this.diagnosisNotes,
      treatmentNotes: data.treatmentNotes.present
          ? data.treatmentNotes.value
          : this.treatmentNotes,
      recommendations: data.recommendations.present
          ? data.recommendations.value
          : this.recommendations,
      temperatureCelsius: data.temperatureCelsius.present
          ? data.temperatureCelsius.value
          : this.temperatureCelsius,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      respiratoryRate: data.respiratoryRate.present
          ? data.respiratoryRate.value
          : this.respiratoryRate,
      serviceFee: data.serviceFee.present
          ? data.serviceFee.value
          : this.serviceFee,
      examinedAt: data.examinedAt.present
          ? data.examinedAt.value
          : this.examinedAt,
      followUpNeeded: data.followUpNeeded.present
          ? data.followUpNeeded.value
          : this.followUpNeeded,
      followUpDate: data.followUpDate.present
          ? data.followUpDate.value
          : this.followUpDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicalRecordRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('animalId: $animalId, ')
          ..write('vetId: $vetId, ')
          ..write('villageId: $villageId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('visitType: $visitType, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('symptoms: $symptoms, ')
          ..write('diagnosisNotes: $diagnosisNotes, ')
          ..write('treatmentNotes: $treatmentNotes, ')
          ..write('recommendations: $recommendations, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('weightKg: $weightKg, ')
          ..write('heartRate: $heartRate, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('serviceFee: $serviceFee, ')
          ..write('examinedAt: $examinedAt, ')
          ..write('followUpNeeded: $followUpNeeded, ')
          ..write('followUpDate: $followUpDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    animalId,
    vetId,
    villageId,
    lat,
    lng,
    visitType,
    chiefComplaint,
    symptoms,
    diagnosisNotes,
    treatmentNotes,
    recommendations,
    temperatureCelsius,
    weightKg,
    heartRate,
    respiratoryRate,
    serviceFee,
    examinedAt,
    followUpNeeded,
    followUpDate,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalRecordRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.animalId == this.animalId &&
          other.vetId == this.vetId &&
          other.villageId == this.villageId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.visitType == this.visitType &&
          other.chiefComplaint == this.chiefComplaint &&
          other.symptoms == this.symptoms &&
          other.diagnosisNotes == this.diagnosisNotes &&
          other.treatmentNotes == this.treatmentNotes &&
          other.recommendations == this.recommendations &&
          other.temperatureCelsius == this.temperatureCelsius &&
          other.weightKg == this.weightKg &&
          other.heartRate == this.heartRate &&
          other.respiratoryRate == this.respiratoryRate &&
          other.serviceFee == this.serviceFee &&
          other.examinedAt == this.examinedAt &&
          other.followUpNeeded == this.followUpNeeded &&
          other.followUpDate == this.followUpDate);
}

class MedicalRecordsCompanion extends UpdateCompanion<MedicalRecordRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String> animalId;
  final Value<int?> vetId;
  final Value<String?> villageId;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String> visitType;
  final Value<String?> chiefComplaint;
  final Value<String?> symptoms;
  final Value<String?> diagnosisNotes;
  final Value<String?> treatmentNotes;
  final Value<String?> recommendations;
  final Value<double?> temperatureCelsius;
  final Value<double?> weightKg;
  final Value<int?> heartRate;
  final Value<int?> respiratoryRate;
  final Value<double?> serviceFee;
  final Value<DateTime> examinedAt;
  final Value<bool> followUpNeeded;
  final Value<DateTime?> followUpDate;
  final Value<int> rowid;
  const MedicalRecordsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.animalId = const Value.absent(),
    this.vetId = const Value.absent(),
    this.villageId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.visitType = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.diagnosisNotes = const Value.absent(),
    this.treatmentNotes = const Value.absent(),
    this.recommendations = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.serviceFee = const Value.absent(),
    this.examinedAt = const Value.absent(),
    this.followUpNeeded = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicalRecordsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    required String animalId,
    this.vetId = const Value.absent(),
    this.villageId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.visitType = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.diagnosisNotes = const Value.absent(),
    this.treatmentNotes = const Value.absent(),
    this.recommendations = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.serviceFee = const Value.absent(),
    required DateTime examinedAt,
    this.followUpNeeded = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animalId = Value(animalId),
       examinedAt = Value(examinedAt);
  static Insertable<MedicalRecordRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? animalId,
    Expression<int>? vetId,
    Expression<String>? villageId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? visitType,
    Expression<String>? chiefComplaint,
    Expression<String>? symptoms,
    Expression<String>? diagnosisNotes,
    Expression<String>? treatmentNotes,
    Expression<String>? recommendations,
    Expression<double>? temperatureCelsius,
    Expression<double>? weightKg,
    Expression<int>? heartRate,
    Expression<int>? respiratoryRate,
    Expression<double>? serviceFee,
    Expression<DateTime>? examinedAt,
    Expression<bool>? followUpNeeded,
    Expression<DateTime>? followUpDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (animalId != null) 'animal_id': animalId,
      if (vetId != null) 'vet_id': vetId,
      if (villageId != null) 'village_id': villageId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (visitType != null) 'visit_type': visitType,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (symptoms != null) 'symptoms': symptoms,
      if (diagnosisNotes != null) 'diagnosis_notes': diagnosisNotes,
      if (treatmentNotes != null) 'treatment_notes': treatmentNotes,
      if (recommendations != null) 'recommendations': recommendations,
      if (temperatureCelsius != null) 'temperature_celsius': temperatureCelsius,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heartRate != null) 'heart_rate': heartRate,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (serviceFee != null) 'service_fee': serviceFee,
      if (examinedAt != null) 'examined_at': examinedAt,
      if (followUpNeeded != null) 'follow_up_needed': followUpNeeded,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicalRecordsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String>? animalId,
    Value<int?>? vetId,
    Value<String?>? villageId,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String>? visitType,
    Value<String?>? chiefComplaint,
    Value<String?>? symptoms,
    Value<String?>? diagnosisNotes,
    Value<String?>? treatmentNotes,
    Value<String?>? recommendations,
    Value<double?>? temperatureCelsius,
    Value<double?>? weightKg,
    Value<int?>? heartRate,
    Value<int?>? respiratoryRate,
    Value<double?>? serviceFee,
    Value<DateTime>? examinedAt,
    Value<bool>? followUpNeeded,
    Value<DateTime?>? followUpDate,
    Value<int>? rowid,
  }) {
    return MedicalRecordsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      animalId: animalId ?? this.animalId,
      vetId: vetId ?? this.vetId,
      villageId: villageId ?? this.villageId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      visitType: visitType ?? this.visitType,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? this.symptoms,
      diagnosisNotes: diagnosisNotes ?? this.diagnosisNotes,
      treatmentNotes: treatmentNotes ?? this.treatmentNotes,
      recommendations: recommendations ?? this.recommendations,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      weightKg: weightKg ?? this.weightKg,
      heartRate: heartRate ?? this.heartRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      serviceFee: serviceFee ?? this.serviceFee,
      examinedAt: examinedAt ?? this.examinedAt,
      followUpNeeded: followUpNeeded ?? this.followUpNeeded,
      followUpDate: followUpDate ?? this.followUpDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $MedicalRecordsTable.$converterlocalSyncStatus.toSql(
          localSyncStatus.value,
        ),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (vetId.present) {
      map['vet_id'] = Variable<int>(vetId.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (visitType.present) {
      map['visit_type'] = Variable<String>(visitType.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (diagnosisNotes.present) {
      map['diagnosis_notes'] = Variable<String>(diagnosisNotes.value);
    }
    if (treatmentNotes.present) {
      map['treatment_notes'] = Variable<String>(treatmentNotes.value);
    }
    if (recommendations.present) {
      map['recommendations'] = Variable<String>(recommendations.value);
    }
    if (temperatureCelsius.present) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (respiratoryRate.present) {
      map['respiratory_rate'] = Variable<int>(respiratoryRate.value);
    }
    if (serviceFee.present) {
      map['service_fee'] = Variable<double>(serviceFee.value);
    }
    if (examinedAt.present) {
      map['examined_at'] = Variable<DateTime>(examinedAt.value);
    }
    if (followUpNeeded.present) {
      map['follow_up_needed'] = Variable<bool>(followUpNeeded.value);
    }
    if (followUpDate.present) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('animalId: $animalId, ')
          ..write('vetId: $vetId, ')
          ..write('villageId: $villageId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('visitType: $visitType, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('symptoms: $symptoms, ')
          ..write('diagnosisNotes: $diagnosisNotes, ')
          ..write('treatmentNotes: $treatmentNotes, ')
          ..write('recommendations: $recommendations, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('weightKg: $weightKg, ')
          ..write('heartRate: $heartRate, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('serviceFee: $serviceFee, ')
          ..write('examinedAt: $examinedAt, ')
          ..write('followUpNeeded: $followUpNeeded, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DrugsTable extends Drugs with TableInfo<$DrugsTable, DrugRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DrugsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus = GeneratedColumn<int>(
    'local_sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(LocalSyncStatus.synced.index),
  ).withConverter<LocalSyncStatus>($DrugsTable.$converterlocalSyncStatus);
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeIngredientMeta = const VerificationMeta(
    'activeIngredient',
  );
  @override
  late final GeneratedColumn<String> activeIngredient = GeneratedColumn<String>(
    'active_ingredient',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drugTypeMeta = const VerificationMeta(
    'drugType',
  );
  @override
  late final GeneratedColumn<String> drugType = GeneratedColumn<String>(
    'drug_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageSizeMeta = const VerificationMeta(
    'packageSize',
  );
  @override
  late final GeneratedColumn<double> packageSize = GeneratedColumn<double>(
    'package_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVaccineMeta = const VerificationMeta(
    'isVaccine',
  );
  @override
  late final GeneratedColumn<bool> isVaccine = GeneratedColumn<bool>(
    'is_vaccine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_vaccine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    name,
    activeIngredient,
    manufacturer,
    drugType,
    unit,
    packageSize,
    isVaccine,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drugs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DrugRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active_ingredient')) {
      context.handle(
        _activeIngredientMeta,
        activeIngredient.isAcceptableOrUnknown(
          data['active_ingredient']!,
          _activeIngredientMeta,
        ),
      );
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('drug_type')) {
      context.handle(
        _drugTypeMeta,
        drugType.isAcceptableOrUnknown(data['drug_type']!, _drugTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_drugTypeMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('package_size')) {
      context.handle(
        _packageSizeMeta,
        packageSize.isAcceptableOrUnknown(
          data['package_size']!,
          _packageSizeMeta,
        ),
      );
    }
    if (data.containsKey('is_vaccine')) {
      context.handle(
        _isVaccineMeta,
        isVaccine.isAcceptableOrUnknown(data['is_vaccine']!, _isVaccineMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DrugRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DrugRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $DrugsTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      activeIngredient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_ingredient'],
      ),
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      drugType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_type'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      packageSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}package_size'],
      ),
      isVaccine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_vaccine'],
      )!,
    );
  }

  @override
  $DrugsTable createAlias(String alias) {
    return $DrugsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class DrugRow extends DataClass implements Insertable<DrugRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String name;
  final String? activeIngredient;
  final String? manufacturer;
  final String drugType;
  final String unit;
  final double? packageSize;
  final bool isVaccine;
  const DrugRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    required this.name,
    this.activeIngredient,
    this.manufacturer,
    required this.drugType,
    required this.unit,
    this.packageSize,
    required this.isVaccine,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $DrugsTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || activeIngredient != null) {
      map['active_ingredient'] = Variable<String>(activeIngredient);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    map['drug_type'] = Variable<String>(drugType);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || packageSize != null) {
      map['package_size'] = Variable<double>(packageSize);
    }
    map['is_vaccine'] = Variable<bool>(isVaccine);
    return map;
  }

  DrugsCompanion toCompanion(bool nullToAbsent) {
    return DrugsCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      name: Value(name),
      activeIngredient: activeIngredient == null && nullToAbsent
          ? const Value.absent()
          : Value(activeIngredient),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      drugType: Value(drugType),
      unit: Value(unit),
      packageSize: packageSize == null && nullToAbsent
          ? const Value.absent()
          : Value(packageSize),
      isVaccine: Value(isVaccine),
    );
  }

  factory DrugRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DrugRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $DrugsTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      name: serializer.fromJson<String>(json['name']),
      activeIngredient: serializer.fromJson<String?>(json['activeIngredient']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      drugType: serializer.fromJson<String>(json['drugType']),
      unit: serializer.fromJson<String>(json['unit']),
      packageSize: serializer.fromJson<double?>(json['packageSize']),
      isVaccine: serializer.fromJson<bool>(json['isVaccine']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $DrugsTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'name': serializer.toJson<String>(name),
      'activeIngredient': serializer.toJson<String?>(activeIngredient),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'drugType': serializer.toJson<String>(drugType),
      'unit': serializer.toJson<String>(unit),
      'packageSize': serializer.toJson<double?>(packageSize),
      'isVaccine': serializer.toJson<bool>(isVaccine),
    };
  }

  DrugRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    String? name,
    Value<String?> activeIngredient = const Value.absent(),
    Value<String?> manufacturer = const Value.absent(),
    String? drugType,
    String? unit,
    Value<double?> packageSize = const Value.absent(),
    bool? isVaccine,
  }) => DrugRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    name: name ?? this.name,
    activeIngredient: activeIngredient.present
        ? activeIngredient.value
        : this.activeIngredient,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    drugType: drugType ?? this.drugType,
    unit: unit ?? this.unit,
    packageSize: packageSize.present ? packageSize.value : this.packageSize,
    isVaccine: isVaccine ?? this.isVaccine,
  );
  DrugRow copyWithCompanion(DrugsCompanion data) {
    return DrugRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      name: data.name.present ? data.name.value : this.name,
      activeIngredient: data.activeIngredient.present
          ? data.activeIngredient.value
          : this.activeIngredient,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      drugType: data.drugType.present ? data.drugType.value : this.drugType,
      unit: data.unit.present ? data.unit.value : this.unit,
      packageSize: data.packageSize.present
          ? data.packageSize.value
          : this.packageSize,
      isVaccine: data.isVaccine.present ? data.isVaccine.value : this.isVaccine,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DrugRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('drugType: $drugType, ')
          ..write('unit: $unit, ')
          ..write('packageSize: $packageSize, ')
          ..write('isVaccine: $isVaccine')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    name,
    activeIngredient,
    manufacturer,
    drugType,
    unit,
    packageSize,
    isVaccine,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DrugRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.name == this.name &&
          other.activeIngredient == this.activeIngredient &&
          other.manufacturer == this.manufacturer &&
          other.drugType == this.drugType &&
          other.unit == this.unit &&
          other.packageSize == this.packageSize &&
          other.isVaccine == this.isVaccine);
}

class DrugsCompanion extends UpdateCompanion<DrugRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String> name;
  final Value<String?> activeIngredient;
  final Value<String?> manufacturer;
  final Value<String> drugType;
  final Value<String> unit;
  final Value<double?> packageSize;
  final Value<bool> isVaccine;
  final Value<int> rowid;
  const DrugsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.name = const Value.absent(),
    this.activeIngredient = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.drugType = const Value.absent(),
    this.unit = const Value.absent(),
    this.packageSize = const Value.absent(),
    this.isVaccine = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DrugsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    required String name,
    this.activeIngredient = const Value.absent(),
    this.manufacturer = const Value.absent(),
    required String drugType,
    required String unit,
    this.packageSize = const Value.absent(),
    this.isVaccine = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       drugType = Value(drugType),
       unit = Value(unit);
  static Insertable<DrugRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? name,
    Expression<String>? activeIngredient,
    Expression<String>? manufacturer,
    Expression<String>? drugType,
    Expression<String>? unit,
    Expression<double>? packageSize,
    Expression<bool>? isVaccine,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (name != null) 'name': name,
      if (activeIngredient != null) 'active_ingredient': activeIngredient,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (drugType != null) 'drug_type': drugType,
      if (unit != null) 'unit': unit,
      if (packageSize != null) 'package_size': packageSize,
      if (isVaccine != null) 'is_vaccine': isVaccine,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DrugsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String>? name,
    Value<String?>? activeIngredient,
    Value<String?>? manufacturer,
    Value<String>? drugType,
    Value<String>? unit,
    Value<double?>? packageSize,
    Value<bool>? isVaccine,
    Value<int>? rowid,
  }) {
    return DrugsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      name: name ?? this.name,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      manufacturer: manufacturer ?? this.manufacturer,
      drugType: drugType ?? this.drugType,
      unit: unit ?? this.unit,
      packageSize: packageSize ?? this.packageSize,
      isVaccine: isVaccine ?? this.isVaccine,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $DrugsTable.$converterlocalSyncStatus.toSql(localSyncStatus.value),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (activeIngredient.present) {
      map['active_ingredient'] = Variable<String>(activeIngredient.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (drugType.present) {
      map['drug_type'] = Variable<String>(drugType.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (packageSize.present) {
      map['package_size'] = Variable<double>(packageSize.value);
    }
    if (isVaccine.present) {
      map['is_vaccine'] = Variable<bool>(isVaccine.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DrugsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('drugType: $drugType, ')
          ..write('unit: $unit, ')
          ..write('packageSize: $packageSize, ')
          ..write('isVaccine: $isVaccine, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocksTable extends Stocks with TableInfo<$StocksTable, StockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus = GeneratedColumn<int>(
    'local_sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(LocalSyncStatus.synced.index),
  ).withConverter<LocalSyncStatus>($StocksTable.$converterlocalSyncStatus);
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _drugIdMeta = const VerificationMeta('drugId');
  @override
  late final GeneratedColumn<String> drugId = GeneratedColumn<String>(
    'drug_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentQuantityMeta = const VerificationMeta(
    'currentQuantity',
  );
  @override
  late final GeneratedColumn<double> currentQuantity = GeneratedColumn<double>(
    'current_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criticalThresholdMeta = const VerificationMeta(
    'criticalThreshold',
  );
  @override
  late final GeneratedColumn<double> criticalThreshold =
      GeneratedColumn<double>(
        'critical_threshold',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reorderQuantityMeta = const VerificationMeta(
    'reorderQuantity',
  );
  @override
  late final GeneratedColumn<double> reorderQuantity = GeneratedColumn<double>(
    'reorder_quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPurchasedAtMeta = const VerificationMeta(
    'lastPurchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPurchasedAt =
      GeneratedColumn<DateTime>(
        'last_purchased_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _earliestExpiryAtMeta = const VerificationMeta(
    'earliestExpiryAt',
  );
  @override
  late final GeneratedColumn<DateTime> earliestExpiryAt =
      GeneratedColumn<DateTime>(
        'earliest_expiry_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    drugId,
    currentQuantity,
    criticalThreshold,
    reorderQuantity,
    lastPurchasedAt,
    earliestExpiryAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('drug_id')) {
      context.handle(
        _drugIdMeta,
        drugId.isAcceptableOrUnknown(data['drug_id']!, _drugIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drugIdMeta);
    }
    if (data.containsKey('current_quantity')) {
      context.handle(
        _currentQuantityMeta,
        currentQuantity.isAcceptableOrUnknown(
          data['current_quantity']!,
          _currentQuantityMeta,
        ),
      );
    }
    if (data.containsKey('critical_threshold')) {
      context.handle(
        _criticalThresholdMeta,
        criticalThreshold.isAcceptableOrUnknown(
          data['critical_threshold']!,
          _criticalThresholdMeta,
        ),
      );
    }
    if (data.containsKey('reorder_quantity')) {
      context.handle(
        _reorderQuantityMeta,
        reorderQuantity.isAcceptableOrUnknown(
          data['reorder_quantity']!,
          _reorderQuantityMeta,
        ),
      );
    }
    if (data.containsKey('last_purchased_at')) {
      context.handle(
        _lastPurchasedAtMeta,
        lastPurchasedAt.isAcceptableOrUnknown(
          data['last_purchased_at']!,
          _lastPurchasedAtMeta,
        ),
      );
    }
    if (data.containsKey('earliest_expiry_at')) {
      context.handle(
        _earliestExpiryAtMeta,
        earliestExpiryAt.isAcceptableOrUnknown(
          data['earliest_expiry_at']!,
          _earliestExpiryAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $StocksTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      drugId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_id'],
      )!,
      currentQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_quantity'],
      )!,
      criticalThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}critical_threshold'],
      ),
      reorderQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_quantity'],
      ),
      lastPurchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_purchased_at'],
      ),
      earliestExpiryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earliest_expiry_at'],
      ),
    );
  }

  @override
  $StocksTable createAlias(String alias) {
    return $StocksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class StockRow extends DataClass implements Insertable<StockRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String drugId;
  final double currentQuantity;
  final double? criticalThreshold;
  final double? reorderQuantity;
  final DateTime? lastPurchasedAt;
  final DateTime? earliestExpiryAt;
  const StockRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    required this.drugId,
    required this.currentQuantity,
    this.criticalThreshold,
    this.reorderQuantity,
    this.lastPurchasedAt,
    this.earliestExpiryAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $StocksTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    map['drug_id'] = Variable<String>(drugId);
    map['current_quantity'] = Variable<double>(currentQuantity);
    if (!nullToAbsent || criticalThreshold != null) {
      map['critical_threshold'] = Variable<double>(criticalThreshold);
    }
    if (!nullToAbsent || reorderQuantity != null) {
      map['reorder_quantity'] = Variable<double>(reorderQuantity);
    }
    if (!nullToAbsent || lastPurchasedAt != null) {
      map['last_purchased_at'] = Variable<DateTime>(lastPurchasedAt);
    }
    if (!nullToAbsent || earliestExpiryAt != null) {
      map['earliest_expiry_at'] = Variable<DateTime>(earliestExpiryAt);
    }
    return map;
  }

  StocksCompanion toCompanion(bool nullToAbsent) {
    return StocksCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      drugId: Value(drugId),
      currentQuantity: Value(currentQuantity),
      criticalThreshold: criticalThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(criticalThreshold),
      reorderQuantity: reorderQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderQuantity),
      lastPurchasedAt: lastPurchasedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPurchasedAt),
      earliestExpiryAt: earliestExpiryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(earliestExpiryAt),
    );
  }

  factory StockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $StocksTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      drugId: serializer.fromJson<String>(json['drugId']),
      currentQuantity: serializer.fromJson<double>(json['currentQuantity']),
      criticalThreshold: serializer.fromJson<double?>(
        json['criticalThreshold'],
      ),
      reorderQuantity: serializer.fromJson<double?>(json['reorderQuantity']),
      lastPurchasedAt: serializer.fromJson<DateTime?>(json['lastPurchasedAt']),
      earliestExpiryAt: serializer.fromJson<DateTime?>(
        json['earliestExpiryAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $StocksTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'drugId': serializer.toJson<String>(drugId),
      'currentQuantity': serializer.toJson<double>(currentQuantity),
      'criticalThreshold': serializer.toJson<double?>(criticalThreshold),
      'reorderQuantity': serializer.toJson<double?>(reorderQuantity),
      'lastPurchasedAt': serializer.toJson<DateTime?>(lastPurchasedAt),
      'earliestExpiryAt': serializer.toJson<DateTime?>(earliestExpiryAt),
    };
  }

  StockRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    String? drugId,
    double? currentQuantity,
    Value<double?> criticalThreshold = const Value.absent(),
    Value<double?> reorderQuantity = const Value.absent(),
    Value<DateTime?> lastPurchasedAt = const Value.absent(),
    Value<DateTime?> earliestExpiryAt = const Value.absent(),
  }) => StockRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    drugId: drugId ?? this.drugId,
    currentQuantity: currentQuantity ?? this.currentQuantity,
    criticalThreshold: criticalThreshold.present
        ? criticalThreshold.value
        : this.criticalThreshold,
    reorderQuantity: reorderQuantity.present
        ? reorderQuantity.value
        : this.reorderQuantity,
    lastPurchasedAt: lastPurchasedAt.present
        ? lastPurchasedAt.value
        : this.lastPurchasedAt,
    earliestExpiryAt: earliestExpiryAt.present
        ? earliestExpiryAt.value
        : this.earliestExpiryAt,
  );
  StockRow copyWithCompanion(StocksCompanion data) {
    return StockRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      drugId: data.drugId.present ? data.drugId.value : this.drugId,
      currentQuantity: data.currentQuantity.present
          ? data.currentQuantity.value
          : this.currentQuantity,
      criticalThreshold: data.criticalThreshold.present
          ? data.criticalThreshold.value
          : this.criticalThreshold,
      reorderQuantity: data.reorderQuantity.present
          ? data.reorderQuantity.value
          : this.reorderQuantity,
      lastPurchasedAt: data.lastPurchasedAt.present
          ? data.lastPurchasedAt.value
          : this.lastPurchasedAt,
      earliestExpiryAt: data.earliestExpiryAt.present
          ? data.earliestExpiryAt.value
          : this.earliestExpiryAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('drugId: $drugId, ')
          ..write('currentQuantity: $currentQuantity, ')
          ..write('criticalThreshold: $criticalThreshold, ')
          ..write('reorderQuantity: $reorderQuantity, ')
          ..write('lastPurchasedAt: $lastPurchasedAt, ')
          ..write('earliestExpiryAt: $earliestExpiryAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    drugId,
    currentQuantity,
    criticalThreshold,
    reorderQuantity,
    lastPurchasedAt,
    earliestExpiryAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.drugId == this.drugId &&
          other.currentQuantity == this.currentQuantity &&
          other.criticalThreshold == this.criticalThreshold &&
          other.reorderQuantity == this.reorderQuantity &&
          other.lastPurchasedAt == this.lastPurchasedAt &&
          other.earliestExpiryAt == this.earliestExpiryAt);
}

class StocksCompanion extends UpdateCompanion<StockRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String> drugId;
  final Value<double> currentQuantity;
  final Value<double?> criticalThreshold;
  final Value<double?> reorderQuantity;
  final Value<DateTime?> lastPurchasedAt;
  final Value<DateTime?> earliestExpiryAt;
  final Value<int> rowid;
  const StocksCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.drugId = const Value.absent(),
    this.currentQuantity = const Value.absent(),
    this.criticalThreshold = const Value.absent(),
    this.reorderQuantity = const Value.absent(),
    this.lastPurchasedAt = const Value.absent(),
    this.earliestExpiryAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocksCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    required String drugId,
    this.currentQuantity = const Value.absent(),
    this.criticalThreshold = const Value.absent(),
    this.reorderQuantity = const Value.absent(),
    this.lastPurchasedAt = const Value.absent(),
    this.earliestExpiryAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       drugId = Value(drugId);
  static Insertable<StockRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? drugId,
    Expression<double>? currentQuantity,
    Expression<double>? criticalThreshold,
    Expression<double>? reorderQuantity,
    Expression<DateTime>? lastPurchasedAt,
    Expression<DateTime>? earliestExpiryAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (drugId != null) 'drug_id': drugId,
      if (currentQuantity != null) 'current_quantity': currentQuantity,
      if (criticalThreshold != null) 'critical_threshold': criticalThreshold,
      if (reorderQuantity != null) 'reorder_quantity': reorderQuantity,
      if (lastPurchasedAt != null) 'last_purchased_at': lastPurchasedAt,
      if (earliestExpiryAt != null) 'earliest_expiry_at': earliestExpiryAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocksCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String>? drugId,
    Value<double>? currentQuantity,
    Value<double?>? criticalThreshold,
    Value<double?>? reorderQuantity,
    Value<DateTime?>? lastPurchasedAt,
    Value<DateTime?>? earliestExpiryAt,
    Value<int>? rowid,
  }) {
    return StocksCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      drugId: drugId ?? this.drugId,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      lastPurchasedAt: lastPurchasedAt ?? this.lastPurchasedAt,
      earliestExpiryAt: earliestExpiryAt ?? this.earliestExpiryAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $StocksTable.$converterlocalSyncStatus.toSql(localSyncStatus.value),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (drugId.present) {
      map['drug_id'] = Variable<String>(drugId.value);
    }
    if (currentQuantity.present) {
      map['current_quantity'] = Variable<double>(currentQuantity.value);
    }
    if (criticalThreshold.present) {
      map['critical_threshold'] = Variable<double>(criticalThreshold.value);
    }
    if (reorderQuantity.present) {
      map['reorder_quantity'] = Variable<double>(reorderQuantity.value);
    }
    if (lastPurchasedAt.present) {
      map['last_purchased_at'] = Variable<DateTime>(lastPurchasedAt.value);
    }
    if (earliestExpiryAt.present) {
      map['earliest_expiry_at'] = Variable<DateTime>(earliestExpiryAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('drugId: $drugId, ')
          ..write('currentQuantity: $currentQuantity, ')
          ..write('criticalThreshold: $criticalThreshold, ')
          ..write('reorderQuantity: $reorderQuantity, ')
          ..write('lastPurchasedAt: $lastPurchasedAt, ')
          ..write('earliestExpiryAt: $earliestExpiryAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus =
      GeneratedColumn<int>(
        'local_sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(LocalSyncStatus.synced.index),
      ).withConverter<LocalSyncStatus>(
        $StockMovementsTable.$converterlocalSyncStatus,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stockIdMeta = const VerificationMeta(
    'stockId',
  );
  @override
  late final GeneratedColumn<String> stockId = GeneratedColumn<String>(
    'stock_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drugIdMeta = const VerificationMeta('drugId');
  @override
  late final GeneratedColumn<String> drugId = GeneratedColumn<String>(
    'drug_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierNameMeta = const VerificationMeta(
    'supplierName',
  );
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
    'supplier_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performedByMeta = const VerificationMeta(
    'performedBy',
  );
  @override
  late final GeneratedColumn<int> performedBy = GeneratedColumn<int>(
    'performed_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    stockId,
    drugId,
    movementType,
    quantity,
    unitPrice,
    expiryDate,
    supplierName,
    performedBy,
    occurredAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('stock_id')) {
      context.handle(
        _stockIdMeta,
        stockId.isAcceptableOrUnknown(data['stock_id']!, _stockIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stockIdMeta);
    }
    if (data.containsKey('drug_id')) {
      context.handle(
        _drugIdMeta,
        drugId.isAcceptableOrUnknown(data['drug_id']!, _drugIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drugIdMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
        _supplierNameMeta,
        supplierName.isAcceptableOrUnknown(
          data['supplier_name']!,
          _supplierNameMeta,
        ),
      );
    }
    if (data.containsKey('performed_by')) {
      context.handle(
        _performedByMeta,
        performedBy.isAcceptableOrUnknown(
          data['performed_by']!,
          _performedByMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $StockMovementsTable.$converterlocalSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}local_sync_status'],
        )!,
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      stockId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_id'],
      )!,
      drugId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_id'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      supplierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_name'],
      ),
      performedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}performed_by'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class StockMovementRow extends DataClass
    implements Insertable<StockMovementRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String stockId;
  final String drugId;
  final String movementType;
  final double quantity;
  final double? unitPrice;
  final DateTime? expiryDate;
  final String? supplierName;
  final int? performedBy;
  final DateTime occurredAt;
  final String? notes;
  const StockMovementRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    required this.stockId,
    required this.drugId,
    required this.movementType,
    required this.quantity,
    this.unitPrice,
    this.expiryDate,
    this.supplierName,
    this.performedBy,
    required this.occurredAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $StockMovementsTable.$converterlocalSyncStatus.toSql(localSyncStatus),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    map['stock_id'] = Variable<String>(stockId);
    map['drug_id'] = Variable<String>(drugId);
    map['movement_type'] = Variable<String>(movementType);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unitPrice != null) {
      map['unit_price'] = Variable<double>(unitPrice);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || supplierName != null) {
      map['supplier_name'] = Variable<String>(supplierName);
    }
    if (!nullToAbsent || performedBy != null) {
      map['performed_by'] = Variable<int>(performedBy);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      stockId: Value(stockId),
      drugId: Value(drugId),
      movementType: Value(movementType),
      quantity: Value(quantity),
      unitPrice: unitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPrice),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      supplierName: supplierName == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierName),
      performedBy: performedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(performedBy),
      occurredAt: Value(occurredAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory StockMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $StockMovementsTable.$converterlocalSyncStatus.fromJson(
        serializer.fromJson<int>(json['localSyncStatus']),
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      stockId: serializer.fromJson<String>(json['stockId']),
      drugId: serializer.fromJson<String>(json['drugId']),
      movementType: serializer.fromJson<String>(json['movementType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double?>(json['unitPrice']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      supplierName: serializer.fromJson<String?>(json['supplierName']),
      performedBy: serializer.fromJson<int?>(json['performedBy']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $StockMovementsTable.$converterlocalSyncStatus.toJson(localSyncStatus),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'stockId': serializer.toJson<String>(stockId),
      'drugId': serializer.toJson<String>(drugId),
      'movementType': serializer.toJson<String>(movementType),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double?>(unitPrice),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'supplierName': serializer.toJson<String?>(supplierName),
      'performedBy': serializer.toJson<int?>(performedBy),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  StockMovementRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    String? stockId,
    String? drugId,
    String? movementType,
    double? quantity,
    Value<double?> unitPrice = const Value.absent(),
    Value<DateTime?> expiryDate = const Value.absent(),
    Value<String?> supplierName = const Value.absent(),
    Value<int?> performedBy = const Value.absent(),
    DateTime? occurredAt,
    Value<String?> notes = const Value.absent(),
  }) => StockMovementRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    stockId: stockId ?? this.stockId,
    drugId: drugId ?? this.drugId,
    movementType: movementType ?? this.movementType,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice.present ? unitPrice.value : this.unitPrice,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    supplierName: supplierName.present ? supplierName.value : this.supplierName,
    performedBy: performedBy.present ? performedBy.value : this.performedBy,
    occurredAt: occurredAt ?? this.occurredAt,
    notes: notes.present ? notes.value : this.notes,
  );
  StockMovementRow copyWithCompanion(StockMovementsCompanion data) {
    return StockMovementRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      stockId: data.stockId.present ? data.stockId.value : this.stockId,
      drugId: data.drugId.present ? data.drugId.value : this.drugId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      performedBy: data.performedBy.present
          ? data.performedBy.value
          : this.performedBy,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('stockId: $stockId, ')
          ..write('drugId: $drugId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('supplierName: $supplierName, ')
          ..write('performedBy: $performedBy, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    stockId,
    drugId,
    movementType,
    quantity,
    unitPrice,
    expiryDate,
    supplierName,
    performedBy,
    occurredAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.stockId == this.stockId &&
          other.drugId == this.drugId &&
          other.movementType == this.movementType &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.expiryDate == this.expiryDate &&
          other.supplierName == this.supplierName &&
          other.performedBy == this.performedBy &&
          other.occurredAt == this.occurredAt &&
          other.notes == this.notes);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovementRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String> stockId;
  final Value<String> drugId;
  final Value<String> movementType;
  final Value<double> quantity;
  final Value<double?> unitPrice;
  final Value<DateTime?> expiryDate;
  final Value<String?> supplierName;
  final Value<int?> performedBy;
  final Value<DateTime> occurredAt;
  final Value<String?> notes;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.stockId = const Value.absent(),
    this.drugId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.performedBy = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    required String stockId,
    required String drugId,
    required String movementType,
    required double quantity,
    this.unitPrice = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.performedBy = const Value.absent(),
    required DateTime occurredAt,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stockId = Value(stockId),
       drugId = Value(drugId),
       movementType = Value(movementType),
       quantity = Value(quantity),
       occurredAt = Value(occurredAt);
  static Insertable<StockMovementRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? stockId,
    Expression<String>? drugId,
    Expression<String>? movementType,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<DateTime>? expiryDate,
    Expression<String>? supplierName,
    Expression<int>? performedBy,
    Expression<DateTime>? occurredAt,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (stockId != null) 'stock_id': stockId,
      if (drugId != null) 'drug_id': drugId,
      if (movementType != null) 'movement_type': movementType,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (supplierName != null) 'supplier_name': supplierName,
      if (performedBy != null) 'performed_by': performedBy,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String>? stockId,
    Value<String>? drugId,
    Value<String>? movementType,
    Value<double>? quantity,
    Value<double?>? unitPrice,
    Value<DateTime?>? expiryDate,
    Value<String?>? supplierName,
    Value<int?>? performedBy,
    Value<DateTime>? occurredAt,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      stockId: stockId ?? this.stockId,
      drugId: drugId ?? this.drugId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierName: supplierName ?? this.supplierName,
      performedBy: performedBy ?? this.performedBy,
      occurredAt: occurredAt ?? this.occurredAt,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $StockMovementsTable.$converterlocalSyncStatus.toSql(
          localSyncStatus.value,
        ),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (stockId.present) {
      map['stock_id'] = Variable<String>(stockId.value);
    }
    if (drugId.present) {
      map['drug_id'] = Variable<String>(drugId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (performedBy.present) {
      map['performed_by'] = Variable<int>(performedBy.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('stockId: $stockId, ')
          ..write('drugId: $drugId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('supplierName: $supplierName, ')
          ..write('performedBy: $performedBy, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicalRecordDrugsTable extends MedicalRecordDrugs
    with TableInfo<$MedicalRecordDrugsTable, MedicalRecordDrugRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicalRecordDrugsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedAtMeta = const VerificationMeta(
    'lastModifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastModifiedAt =
      GeneratedColumn<DateTime>(
        'last_modified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clinicIdMeta = const VerificationMeta(
    'clinicId',
  );
  @override
  late final GeneratedColumn<String> clinicId = GeneratedColumn<String>(
    'clinic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, int>
  localSyncStatus =
      GeneratedColumn<int>(
        'local_sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(LocalSyncStatus.synced.index),
      ).withConverter<LocalSyncStatus>(
        $MedicalRecordDrugsTable.$converterlocalSyncStatus,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedLocalMeta = const VerificationMeta(
    'deletedLocal',
  );
  @override
  late final GeneratedColumn<bool> deletedLocal = GeneratedColumn<bool>(
    'deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _medicalRecordIdMeta = const VerificationMeta(
    'medicalRecordId',
  );
  @override
  late final GeneratedColumn<String> medicalRecordId = GeneratedColumn<String>(
    'medical_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _drugIdMeta = const VerificationMeta('drugId');
  @override
  late final GeneratedColumn<String> drugId = GeneratedColumn<String>(
    'drug_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageInstructionsMeta =
      const VerificationMeta('dosageInstructions');
  @override
  late final GeneratedColumn<String> dosageInstructions =
      GeneratedColumn<String>(
        'dosage_instructions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    medicalRecordId,
    drugId,
    quantity,
    dosageInstructions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medical_record_drugs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicalRecordDrugRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_modified_at')) {
      context.handle(
        _lastModifiedAtMeta,
        lastModifiedAt.isAcceptableOrUnknown(
          data['last_modified_at']!,
          _lastModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('clinic_id')) {
      context.handle(
        _clinicIdMeta,
        clinicId.isAcceptableOrUnknown(data['clinic_id']!, _clinicIdMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('deleted_local')) {
      context.handle(
        _deletedLocalMeta,
        deletedLocal.isAcceptableOrUnknown(
          data['deleted_local']!,
          _deletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('medical_record_id')) {
      context.handle(
        _medicalRecordIdMeta,
        medicalRecordId.isAcceptableOrUnknown(
          data['medical_record_id']!,
          _medicalRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicalRecordIdMeta);
    }
    if (data.containsKey('drug_id')) {
      context.handle(
        _drugIdMeta,
        drugId.isAcceptableOrUnknown(data['drug_id']!, _drugIdMeta),
      );
    } else if (isInserting) {
      context.missing(_drugIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('dosage_instructions')) {
      context.handle(
        _dosageInstructionsMeta,
        dosageInstructions.isAcceptableOrUnknown(
          data['dosage_instructions']!,
          _dosageInstructionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicalRecordDrugRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicalRecordDrugRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
      clinicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_id'],
      ),
      localSyncStatus: $MedicalRecordDrugsTable.$converterlocalSyncStatus
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}local_sync_status'],
            )!,
          ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      deletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_local'],
      )!,
      medicalRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_record_id'],
      )!,
      drugId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      dosageInstructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage_instructions'],
      ),
    );
  }

  @override
  $MedicalRecordDrugsTable createAlias(String alias) {
    return $MedicalRecordDrugsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, int, int>
  $converterlocalSyncStatus = const EnumIndexConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class MedicalRecordDrugRow extends DataClass
    implements Insertable<MedicalRecordDrugRow> {
  final String id;
  final int version;
  final DateTime? lastModifiedAt;
  final String? originDeviceId;
  final String? clinicId;
  final LocalSyncStatus localSyncStatus;
  final DateTime localUpdatedAt;
  final String? lastError;
  final bool deletedLocal;
  final String medicalRecordId;
  final String drugId;
  final double quantity;
  final String? dosageInstructions;
  const MedicalRecordDrugRow({
    required this.id,
    required this.version,
    this.lastModifiedAt,
    this.originDeviceId,
    this.clinicId,
    required this.localSyncStatus,
    required this.localUpdatedAt,
    this.lastError,
    required this.deletedLocal,
    required this.medicalRecordId,
    required this.drugId,
    required this.quantity,
    this.dosageInstructions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || lastModifiedAt != null) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    if (!nullToAbsent || clinicId != null) {
      map['clinic_id'] = Variable<String>(clinicId);
    }
    {
      map['local_sync_status'] = Variable<int>(
        $MedicalRecordDrugsTable.$converterlocalSyncStatus.toSql(
          localSyncStatus,
        ),
      );
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['deleted_local'] = Variable<bool>(deletedLocal);
    map['medical_record_id'] = Variable<String>(medicalRecordId);
    map['drug_id'] = Variable<String>(drugId);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || dosageInstructions != null) {
      map['dosage_instructions'] = Variable<String>(dosageInstructions);
    }
    return map;
  }

  MedicalRecordDrugsCompanion toCompanion(bool nullToAbsent) {
    return MedicalRecordDrugsCompanion(
      id: Value(id),
      version: Value(version),
      lastModifiedAt: lastModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModifiedAt),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      clinicId: clinicId == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicId),
      localSyncStatus: Value(localSyncStatus),
      localUpdatedAt: Value(localUpdatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deletedLocal: Value(deletedLocal),
      medicalRecordId: Value(medicalRecordId),
      drugId: Value(drugId),
      quantity: Value(quantity),
      dosageInstructions: dosageInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(dosageInstructions),
    );
  }

  factory MedicalRecordDrugRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicalRecordDrugRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModifiedAt: serializer.fromJson<DateTime?>(json['lastModifiedAt']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      clinicId: serializer.fromJson<String?>(json['clinicId']),
      localSyncStatus: $MedicalRecordDrugsTable.$converterlocalSyncStatus
          .fromJson(serializer.fromJson<int>(json['localSyncStatus'])),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deletedLocal: serializer.fromJson<bool>(json['deletedLocal']),
      medicalRecordId: serializer.fromJson<String>(json['medicalRecordId']),
      drugId: serializer.fromJson<String>(json['drugId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      dosageInstructions: serializer.fromJson<String?>(
        json['dosageInstructions'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'lastModifiedAt': serializer.toJson<DateTime?>(lastModifiedAt),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'clinicId': serializer.toJson<String?>(clinicId),
      'localSyncStatus': serializer.toJson<int>(
        $MedicalRecordDrugsTable.$converterlocalSyncStatus.toJson(
          localSyncStatus,
        ),
      ),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'deletedLocal': serializer.toJson<bool>(deletedLocal),
      'medicalRecordId': serializer.toJson<String>(medicalRecordId),
      'drugId': serializer.toJson<String>(drugId),
      'quantity': serializer.toJson<double>(quantity),
      'dosageInstructions': serializer.toJson<String?>(dosageInstructions),
    };
  }

  MedicalRecordDrugRow copyWith({
    String? id,
    int? version,
    Value<DateTime?> lastModifiedAt = const Value.absent(),
    Value<String?> originDeviceId = const Value.absent(),
    Value<String?> clinicId = const Value.absent(),
    LocalSyncStatus? localSyncStatus,
    DateTime? localUpdatedAt,
    Value<String?> lastError = const Value.absent(),
    bool? deletedLocal,
    String? medicalRecordId,
    String? drugId,
    double? quantity,
    Value<String?> dosageInstructions = const Value.absent(),
  }) => MedicalRecordDrugRow(
    id: id ?? this.id,
    version: version ?? this.version,
    lastModifiedAt: lastModifiedAt.present
        ? lastModifiedAt.value
        : this.lastModifiedAt,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
    clinicId: clinicId.present ? clinicId.value : this.clinicId,
    localSyncStatus: localSyncStatus ?? this.localSyncStatus,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    deletedLocal: deletedLocal ?? this.deletedLocal,
    medicalRecordId: medicalRecordId ?? this.medicalRecordId,
    drugId: drugId ?? this.drugId,
    quantity: quantity ?? this.quantity,
    dosageInstructions: dosageInstructions.present
        ? dosageInstructions.value
        : this.dosageInstructions,
  );
  MedicalRecordDrugRow copyWithCompanion(MedicalRecordDrugsCompanion data) {
    return MedicalRecordDrugRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModifiedAt: data.lastModifiedAt.present
          ? data.lastModifiedAt.value
          : this.lastModifiedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      clinicId: data.clinicId.present ? data.clinicId.value : this.clinicId,
      localSyncStatus: data.localSyncStatus.present
          ? data.localSyncStatus.value
          : this.localSyncStatus,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deletedLocal: data.deletedLocal.present
          ? data.deletedLocal.value
          : this.deletedLocal,
      medicalRecordId: data.medicalRecordId.present
          ? data.medicalRecordId.value
          : this.medicalRecordId,
      drugId: data.drugId.present ? data.drugId.value : this.drugId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      dosageInstructions: data.dosageInstructions.present
          ? data.dosageInstructions.value
          : this.dosageInstructions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicalRecordDrugRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('medicalRecordId: $medicalRecordId, ')
          ..write('drugId: $drugId, ')
          ..write('quantity: $quantity, ')
          ..write('dosageInstructions: $dosageInstructions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    lastModifiedAt,
    originDeviceId,
    clinicId,
    localSyncStatus,
    localUpdatedAt,
    lastError,
    deletedLocal,
    medicalRecordId,
    drugId,
    quantity,
    dosageInstructions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalRecordDrugRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModifiedAt == this.lastModifiedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.clinicId == this.clinicId &&
          other.localSyncStatus == this.localSyncStatus &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.lastError == this.lastError &&
          other.deletedLocal == this.deletedLocal &&
          other.medicalRecordId == this.medicalRecordId &&
          other.drugId == this.drugId &&
          other.quantity == this.quantity &&
          other.dosageInstructions == this.dosageInstructions);
}

class MedicalRecordDrugsCompanion
    extends UpdateCompanion<MedicalRecordDrugRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<DateTime?> lastModifiedAt;
  final Value<String?> originDeviceId;
  final Value<String?> clinicId;
  final Value<LocalSyncStatus> localSyncStatus;
  final Value<DateTime> localUpdatedAt;
  final Value<String?> lastError;
  final Value<bool> deletedLocal;
  final Value<String> medicalRecordId;
  final Value<String> drugId;
  final Value<double> quantity;
  final Value<String?> dosageInstructions;
  final Value<int> rowid;
  const MedicalRecordDrugsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    this.medicalRecordId = const Value.absent(),
    this.drugId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.dosageInstructions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicalRecordDrugsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.lastModifiedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.clinicId = const Value.absent(),
    this.localSyncStatus = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deletedLocal = const Value.absent(),
    required String medicalRecordId,
    required String drugId,
    required double quantity,
    this.dosageInstructions = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicalRecordId = Value(medicalRecordId),
       drugId = Value(drugId),
       quantity = Value(quantity);
  static Insertable<MedicalRecordDrugRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModifiedAt,
    Expression<String>? originDeviceId,
    Expression<String>? clinicId,
    Expression<int>? localSyncStatus,
    Expression<DateTime>? localUpdatedAt,
    Expression<String>? lastError,
    Expression<bool>? deletedLocal,
    Expression<String>? medicalRecordId,
    Expression<String>? drugId,
    Expression<double>? quantity,
    Expression<String>? dosageInstructions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModifiedAt != null) 'last_modified_at': lastModifiedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (clinicId != null) 'clinic_id': clinicId,
      if (localSyncStatus != null) 'local_sync_status': localSyncStatus,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (lastError != null) 'last_error': lastError,
      if (deletedLocal != null) 'deleted_local': deletedLocal,
      if (medicalRecordId != null) 'medical_record_id': medicalRecordId,
      if (drugId != null) 'drug_id': drugId,
      if (quantity != null) 'quantity': quantity,
      if (dosageInstructions != null) 'dosage_instructions': dosageInstructions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicalRecordDrugsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<DateTime?>? lastModifiedAt,
    Value<String?>? originDeviceId,
    Value<String?>? clinicId,
    Value<LocalSyncStatus>? localSyncStatus,
    Value<DateTime>? localUpdatedAt,
    Value<String?>? lastError,
    Value<bool>? deletedLocal,
    Value<String>? medicalRecordId,
    Value<String>? drugId,
    Value<double>? quantity,
    Value<String?>? dosageInstructions,
    Value<int>? rowid,
  }) {
    return MedicalRecordDrugsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      clinicId: clinicId ?? this.clinicId,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      lastError: lastError ?? this.lastError,
      deletedLocal: deletedLocal ?? this.deletedLocal,
      medicalRecordId: medicalRecordId ?? this.medicalRecordId,
      drugId: drugId ?? this.drugId,
      quantity: quantity ?? this.quantity,
      dosageInstructions: dosageInstructions ?? this.dosageInstructions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModifiedAt.present) {
      map['last_modified_at'] = Variable<DateTime>(lastModifiedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (clinicId.present) {
      map['clinic_id'] = Variable<String>(clinicId.value);
    }
    if (localSyncStatus.present) {
      map['local_sync_status'] = Variable<int>(
        $MedicalRecordDrugsTable.$converterlocalSyncStatus.toSql(
          localSyncStatus.value,
        ),
      );
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deletedLocal.present) {
      map['deleted_local'] = Variable<bool>(deletedLocal.value);
    }
    if (medicalRecordId.present) {
      map['medical_record_id'] = Variable<String>(medicalRecordId.value);
    }
    if (drugId.present) {
      map['drug_id'] = Variable<String>(drugId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (dosageInstructions.present) {
      map['dosage_instructions'] = Variable<String>(dosageInstructions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicalRecordDrugsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModifiedAt: $lastModifiedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('clinicId: $clinicId, ')
          ..write('localSyncStatus: $localSyncStatus, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('deletedLocal: $deletedLocal, ')
          ..write('medicalRecordId: $medicalRecordId, ')
          ..write('drugId: $drugId, ')
          ..write('quantity: $quantity, ')
          ..write('dosageInstructions: $dosageInstructions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaRow extends DataClass implements Insertable<SyncMetaRow> {
  final String key;
  final String? value;
  const SyncMetaRow({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SyncMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SyncMetaRow copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SyncMetaRow(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SyncMetaRow copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaRow> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
    'observed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    recordId,
    resolution,
    serverVersion,
    observedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['table_name']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    } else if (isInserting) {
      context.missing(_resolutionMeta);
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflictRow extends DataClass implements Insertable<SyncConflictRow> {
  final String id;
  final String targetTable;
  final String recordId;
  final String resolution;
  final int? serverVersion;
  final DateTime observedAt;
  const SyncConflictRow({
    required this.id,
    required this.targetTable,
    required this.recordId,
    required this.resolution,
    this.serverVersion,
    required this.observedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(targetTable);
    map['record_id'] = Variable<String>(recordId);
    map['resolution'] = Variable<String>(resolution);
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['observed_at'] = Variable<DateTime>(observedAt);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      resolution: Value(resolution),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      observedAt: Value(observedAt),
    );
  }

  factory SyncConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictRow(
      id: serializer.fromJson<String>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      resolution: serializer.fromJson<String>(json['resolution']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'recordId': serializer.toJson<String>(recordId),
      'resolution': serializer.toJson<String>(resolution),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'observedAt': serializer.toJson<DateTime>(observedAt),
    };
  }

  SyncConflictRow copyWith({
    String? id,
    String? targetTable,
    String? recordId,
    String? resolution,
    Value<int?> serverVersion = const Value.absent(),
    DateTime? observedAt,
  }) => SyncConflictRow(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    recordId: recordId ?? this.recordId,
    resolution: resolution ?? this.resolution,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    observedAt: observedAt ?? this.observedAt,
  );
  SyncConflictRow copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflictRow(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRow(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('resolution: $resolution, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('observedAt: $observedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    recordId,
    resolution,
    serverVersion,
    observedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictRow &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.recordId == this.recordId &&
          other.resolution == this.resolution &&
          other.serverVersion == this.serverVersion &&
          other.observedAt == this.observedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflictRow> {
  final Value<String> id;
  final Value<String> targetTable;
  final Value<String> recordId;
  final Value<String> resolution;
  final Value<int?> serverVersion;
  final Value<DateTime> observedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.resolution = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String targetTable,
    required String recordId,
    required String resolution,
    this.serverVersion = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetTable = Value(targetTable),
       recordId = Value(recordId),
       resolution = Value(resolution);
  static Insertable<SyncConflictRow> custom({
    Expression<String>? id,
    Expression<String>? targetTable,
    Expression<String>? recordId,
    Expression<String>? resolution,
    Expression<int>? serverVersion,
    Expression<DateTime>? observedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'table_name': targetTable,
      if (recordId != null) 'record_id': recordId,
      if (resolution != null) 'resolution': resolution,
      if (serverVersion != null) 'server_version': serverVersion,
      if (observedAt != null) 'observed_at': observedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? targetTable,
    Value<String>? recordId,
    Value<String>? resolution,
    Value<int?>? serverVersion,
    Value<DateTime>? observedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      recordId: recordId ?? this.recordId,
      resolution: resolution ?? this.resolution,
      serverVersion: serverVersion ?? this.serverVersion,
      observedAt: observedAt ?? this.observedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetTable.present) {
      map['table_name'] = Variable<String>(targetTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('recordId: $recordId, ')
          ..write('resolution: $resolution, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('observedAt: $observedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VillagesTable villages = $VillagesTable(this);
  late final $FarmersTable farmers = $FarmersTable(this);
  late final $AnimalsTable animals = $AnimalsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $MedicalRecordsTable medicalRecords = $MedicalRecordsTable(this);
  late final $DrugsTable drugs = $DrugsTable(this);
  late final $StocksTable stocks = $StocksTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $MedicalRecordDrugsTable medicalRecordDrugs =
      $MedicalRecordDrugsTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    villages,
    farmers,
    animals,
    appointments,
    medicalRecords,
    drugs,
    stocks,
    stockMovements,
    medicalRecordDrugs,
    syncMeta,
    syncConflicts,
  ];
}

typedef $$VillagesTableCreateCompanionBuilder =
    VillagesCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      required String name,
      Value<String?> district,
      Value<String?> city,
      Value<double?> lat,
      Value<double?> lng,
      Value<int> rowid,
    });
typedef $$VillagesTableUpdateCompanionBuilder =
    VillagesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String> name,
      Value<String?> district,
      Value<String?> city,
      Value<double?> lat,
      Value<double?> lng,
      Value<int> rowid,
    });

class $$VillagesTableFilterComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VillagesTableOrderingComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VillagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);
}

class $$VillagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VillagesTable,
          VillageRow,
          $$VillagesTableFilterComposer,
          $$VillagesTableOrderingComposer,
          $$VillagesTableAnnotationComposer,
          $$VillagesTableCreateCompanionBuilder,
          $$VillagesTableUpdateCompanionBuilder,
          (
            VillageRow,
            BaseReferences<_$AppDatabase, $VillagesTable, VillageRow>,
          ),
          VillageRow,
          PrefetchHooks Function()
        > {
  $$VillagesTableTableManager(_$AppDatabase db, $VillagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VillagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VillagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VillagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VillagesCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                name: name,
                district: district,
                city: city,
                lat: lat,
                lng: lng,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                required String name,
                Value<String?> district = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VillagesCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                name: name,
                district: district,
                city: city,
                lat: lat,
                lng: lng,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VillagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VillagesTable,
      VillageRow,
      $$VillagesTableFilterComposer,
      $$VillagesTableOrderingComposer,
      $$VillagesTableAnnotationComposer,
      $$VillagesTableCreateCompanionBuilder,
      $$VillagesTableUpdateCompanionBuilder,
      (VillageRow, BaseReferences<_$AppDatabase, $VillagesTable, VillageRow>),
      VillageRow,
      PrefetchHooks Function()
    >;
typedef $$FarmersTableCreateCompanionBuilder =
    FarmersCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String?> villageId,
      required String firstName,
      required String lastName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> addressDetail,
      Value<double> balance,
      Value<bool> smsNotificationsEnabled,
      Value<String> preferredSmsLanguage,
      Value<int> rowid,
    });
typedef $$FarmersTableUpdateCompanionBuilder =
    FarmersCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String?> villageId,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> addressDetail,
      Value<double> balance,
      Value<bool> smsNotificationsEnabled,
      Value<String> preferredSmsLanguage,
      Value<int> rowid,
    });

class $$FarmersTableFilterComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressDetail => $composableBuilder(
    column: $table.addressDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get smsNotificationsEnabled => $composableBuilder(
    column: $table.smsNotificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredSmsLanguage => $composableBuilder(
    column: $table.preferredSmsLanguage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmersTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressDetail => $composableBuilder(
    column: $table.addressDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get smsNotificationsEnabled => $composableBuilder(
    column: $table.smsNotificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredSmsLanguage => $composableBuilder(
    column: $table.preferredSmsLanguage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get addressDetail => $composableBuilder(
    column: $table.addressDetail,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<bool> get smsNotificationsEnabled => $composableBuilder(
    column: $table.smsNotificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredSmsLanguage => $composableBuilder(
    column: $table.preferredSmsLanguage,
    builder: (column) => column,
  );
}

class $$FarmersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmersTable,
          FarmerRow,
          $$FarmersTableFilterComposer,
          $$FarmersTableOrderingComposer,
          $$FarmersTableAnnotationComposer,
          $$FarmersTableCreateCompanionBuilder,
          $$FarmersTableUpdateCompanionBuilder,
          (FarmerRow, BaseReferences<_$AppDatabase, $FarmersTable, FarmerRow>),
          FarmerRow,
          PrefetchHooks Function()
        > {
  $$FarmersTableTableManager(_$AppDatabase db, $FarmersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> addressDetail = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<bool> smsNotificationsEnabled = const Value.absent(),
                Value<String> preferredSmsLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmersCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                villageId: villageId,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                email: email,
                addressDetail: addressDetail,
                balance: balance,
                smsNotificationsEnabled: smsNotificationsEnabled,
                preferredSmsLanguage: preferredSmsLanguage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                required String firstName,
                required String lastName,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> addressDetail = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<bool> smsNotificationsEnabled = const Value.absent(),
                Value<String> preferredSmsLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmersCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                villageId: villageId,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                email: email,
                addressDetail: addressDetail,
                balance: balance,
                smsNotificationsEnabled: smsNotificationsEnabled,
                preferredSmsLanguage: preferredSmsLanguage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmersTable,
      FarmerRow,
      $$FarmersTableFilterComposer,
      $$FarmersTableOrderingComposer,
      $$FarmersTableAnnotationComposer,
      $$FarmersTableCreateCompanionBuilder,
      $$FarmersTableUpdateCompanionBuilder,
      (FarmerRow, BaseReferences<_$AppDatabase, $FarmersTable, FarmerRow>),
      FarmerRow,
      PrefetchHooks Function()
    >;
typedef $$AnimalsTableCreateCompanionBuilder =
    AnimalsCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      required String farmerId,
      Value<String?> villageId,
      Value<String?> earTag,
      Value<String?> name,
      required String species,
      Value<String?> breed,
      Value<DateTime?> birthDate,
      Value<String?> gender,
      Value<double?> weightKg,
      Value<String?> color,
      Value<bool> isPregnant,
      Value<DateTime?> lastVaccinationAt,
      Value<String> status,
      Value<DateTime?> statusChangedAt,
      Value<String?> statusNotes,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$AnimalsTableUpdateCompanionBuilder =
    AnimalsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String> farmerId,
      Value<String?> villageId,
      Value<String?> earTag,
      Value<String?> name,
      Value<String> species,
      Value<String?> breed,
      Value<DateTime?> birthDate,
      Value<String?> gender,
      Value<double?> weightKg,
      Value<String?> color,
      Value<bool> isPregnant,
      Value<DateTime?> lastVaccinationAt,
      Value<String> status,
      Value<DateTime?> statusChangedAt,
      Value<String?> statusNotes,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$AnimalsTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get earTag => $composableBuilder(
    column: $table.earTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPregnant => $composableBuilder(
    column: $table.isPregnant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVaccinationAt => $composableBuilder(
    column: $table.lastVaccinationAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusNotes => $composableBuilder(
    column: $table.statusNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimalsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get earTag => $composableBuilder(
    column: $table.earTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPregnant => $composableBuilder(
    column: $table.isPregnant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVaccinationAt => $composableBuilder(
    column: $table.lastVaccinationAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusNotes => $composableBuilder(
    column: $table.statusNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalsTable> {
  $$AnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<String> get earTag =>
      $composableBuilder(column: $table.earTag, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isPregnant => $composableBuilder(
    column: $table.isPregnant,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVaccinationAt => $composableBuilder(
    column: $table.lastVaccinationAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusNotes => $composableBuilder(
    column: $table.statusNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AnimalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimalsTable,
          AnimalRow,
          $$AnimalsTableFilterComposer,
          $$AnimalsTableOrderingComposer,
          $$AnimalsTableAnnotationComposer,
          $$AnimalsTableCreateCompanionBuilder,
          $$AnimalsTableUpdateCompanionBuilder,
          (AnimalRow, BaseReferences<_$AppDatabase, $AnimalsTable, AnimalRow>),
          AnimalRow,
          PrefetchHooks Function()
        > {
  $$AnimalsTableTableManager(_$AppDatabase db, $AnimalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                Value<String?> earTag = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isPregnant = const Value.absent(),
                Value<DateTime?> lastVaccinationAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                Value<String?> statusNotes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalsCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                farmerId: farmerId,
                villageId: villageId,
                earTag: earTag,
                name: name,
                species: species,
                breed: breed,
                birthDate: birthDate,
                gender: gender,
                weightKg: weightKg,
                color: color,
                isPregnant: isPregnant,
                lastVaccinationAt: lastVaccinationAt,
                status: status,
                statusChangedAt: statusChangedAt,
                statusNotes: statusNotes,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                required String farmerId,
                Value<String?> villageId = const Value.absent(),
                Value<String?> earTag = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required String species,
                Value<String?> breed = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isPregnant = const Value.absent(),
                Value<DateTime?> lastVaccinationAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                Value<String?> statusNotes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalsCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                farmerId: farmerId,
                villageId: villageId,
                earTag: earTag,
                name: name,
                species: species,
                breed: breed,
                birthDate: birthDate,
                gender: gender,
                weightKg: weightKg,
                color: color,
                isPregnant: isPregnant,
                lastVaccinationAt: lastVaccinationAt,
                status: status,
                statusChangedAt: statusChangedAt,
                statusNotes: statusNotes,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimalsTable,
      AnimalRow,
      $$AnimalsTableFilterComposer,
      $$AnimalsTableOrderingComposer,
      $$AnimalsTableAnnotationComposer,
      $$AnimalsTableCreateCompanionBuilder,
      $$AnimalsTableUpdateCompanionBuilder,
      (AnimalRow, BaseReferences<_$AppDatabase, $AnimalsTable, AnimalRow>),
      AnimalRow,
      PrefetchHooks Function()
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String?> farmerId,
      Value<String?> animalId,
      Value<String?> villageId,
      Value<int?> vetId,
      required DateTime scheduledAt,
      Value<String?> reason,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String?> farmerId,
      Value<String?> animalId,
      Value<String?> villageId,
      Value<int?> vetId,
      Value<DateTime> scheduledAt,
      Value<String?> reason,
      Value<String> status,
      Value<int> rowid,
    });

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vetId => $composableBuilder(
    column: $table.vetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmerId => $composableBuilder(
    column: $table.farmerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vetId => $composableBuilder(
    column: $table.vetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<int> get vetId =>
      $composableBuilder(column: $table.vetId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          AppointmentRow,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (
            AppointmentRow,
            BaseReferences<_$AppDatabase, $AppointmentsTable, AppointmentRow>,
          ),
          AppointmentRow,
          PrefetchHooks Function()
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String?> farmerId = const Value.absent(),
                Value<String?> animalId = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                Value<int?> vetId = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                farmerId: farmerId,
                animalId: animalId,
                villageId: villageId,
                vetId: vetId,
                scheduledAt: scheduledAt,
                reason: reason,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String?> farmerId = const Value.absent(),
                Value<String?> animalId = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                Value<int?> vetId = const Value.absent(),
                required DateTime scheduledAt,
                Value<String?> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                farmerId: farmerId,
                animalId: animalId,
                villageId: villageId,
                vetId: vetId,
                scheduledAt: scheduledAt,
                reason: reason,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      AppointmentRow,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (
        AppointmentRow,
        BaseReferences<_$AppDatabase, $AppointmentsTable, AppointmentRow>,
      ),
      AppointmentRow,
      PrefetchHooks Function()
    >;
typedef $$MedicalRecordsTableCreateCompanionBuilder =
    MedicalRecordsCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      required String animalId,
      Value<int?> vetId,
      Value<String?> villageId,
      Value<double?> lat,
      Value<double?> lng,
      Value<String> visitType,
      Value<String?> chiefComplaint,
      Value<String?> symptoms,
      Value<String?> diagnosisNotes,
      Value<String?> treatmentNotes,
      Value<String?> recommendations,
      Value<double?> temperatureCelsius,
      Value<double?> weightKg,
      Value<int?> heartRate,
      Value<int?> respiratoryRate,
      Value<double?> serviceFee,
      required DateTime examinedAt,
      Value<bool> followUpNeeded,
      Value<DateTime?> followUpDate,
      Value<int> rowid,
    });
typedef $$MedicalRecordsTableUpdateCompanionBuilder =
    MedicalRecordsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String> animalId,
      Value<int?> vetId,
      Value<String?> villageId,
      Value<double?> lat,
      Value<double?> lng,
      Value<String> visitType,
      Value<String?> chiefComplaint,
      Value<String?> symptoms,
      Value<String?> diagnosisNotes,
      Value<String?> treatmentNotes,
      Value<String?> recommendations,
      Value<double?> temperatureCelsius,
      Value<double?> weightKg,
      Value<int?> heartRate,
      Value<int?> respiratoryRate,
      Value<double?> serviceFee,
      Value<DateTime> examinedAt,
      Value<bool> followUpNeeded,
      Value<DateTime?> followUpDate,
      Value<int> rowid,
    });

class $$MedicalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicalRecordsTable> {
  $$MedicalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vetId => $composableBuilder(
    column: $table.vetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosisNotes => $composableBuilder(
    column: $table.diagnosisNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatmentNotes => $composableBuilder(
    column: $table.treatmentNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendations => $composableBuilder(
    column: $table.recommendations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get serviceFee => $composableBuilder(
    column: $table.serviceFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get examinedAt => $composableBuilder(
    column: $table.examinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get followUpNeeded => $composableBuilder(
    column: $table.followUpNeeded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicalRecordsTable> {
  $$MedicalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vetId => $composableBuilder(
    column: $table.vetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosisNotes => $composableBuilder(
    column: $table.diagnosisNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatmentNotes => $composableBuilder(
    column: $table.treatmentNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendations => $composableBuilder(
    column: $table.recommendations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get serviceFee => $composableBuilder(
    column: $table.serviceFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get examinedAt => $composableBuilder(
    column: $table.examinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get followUpNeeded => $composableBuilder(
    column: $table.followUpNeeded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicalRecordsTable> {
  $$MedicalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<int> get vetId =>
      $composableBuilder(column: $table.vetId, builder: (column) => column);

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get visitType =>
      $composableBuilder(column: $table.visitType, builder: (column) => column);

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
    column: $table.chiefComplaint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get diagnosisNotes => $composableBuilder(
    column: $table.diagnosisNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get treatmentNotes => $composableBuilder(
    column: $table.treatmentNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendations => $composableBuilder(
    column: $table.recommendations,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<int> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get serviceFee => $composableBuilder(
    column: $table.serviceFee,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get examinedAt => $composableBuilder(
    column: $table.examinedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get followUpNeeded => $composableBuilder(
    column: $table.followUpNeeded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => column,
  );
}

class $$MedicalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicalRecordsTable,
          MedicalRecordRow,
          $$MedicalRecordsTableFilterComposer,
          $$MedicalRecordsTableOrderingComposer,
          $$MedicalRecordsTableAnnotationComposer,
          $$MedicalRecordsTableCreateCompanionBuilder,
          $$MedicalRecordsTableUpdateCompanionBuilder,
          (
            MedicalRecordRow,
            BaseReferences<
              _$AppDatabase,
              $MedicalRecordsTable,
              MedicalRecordRow
            >,
          ),
          MedicalRecordRow,
          PrefetchHooks Function()
        > {
  $$MedicalRecordsTableTableManager(
    _$AppDatabase db,
    $MedicalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<int?> vetId = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String> visitType = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> diagnosisNotes = const Value.absent(),
                Value<String?> treatmentNotes = const Value.absent(),
                Value<String?> recommendations = const Value.absent(),
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> respiratoryRate = const Value.absent(),
                Value<double?> serviceFee = const Value.absent(),
                Value<DateTime> examinedAt = const Value.absent(),
                Value<bool> followUpNeeded = const Value.absent(),
                Value<DateTime?> followUpDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicalRecordsCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                animalId: animalId,
                vetId: vetId,
                villageId: villageId,
                lat: lat,
                lng: lng,
                visitType: visitType,
                chiefComplaint: chiefComplaint,
                symptoms: symptoms,
                diagnosisNotes: diagnosisNotes,
                treatmentNotes: treatmentNotes,
                recommendations: recommendations,
                temperatureCelsius: temperatureCelsius,
                weightKg: weightKg,
                heartRate: heartRate,
                respiratoryRate: respiratoryRate,
                serviceFee: serviceFee,
                examinedAt: examinedAt,
                followUpNeeded: followUpNeeded,
                followUpDate: followUpDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                required String animalId,
                Value<int?> vetId = const Value.absent(),
                Value<String?> villageId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String> visitType = const Value.absent(),
                Value<String?> chiefComplaint = const Value.absent(),
                Value<String?> symptoms = const Value.absent(),
                Value<String?> diagnosisNotes = const Value.absent(),
                Value<String?> treatmentNotes = const Value.absent(),
                Value<String?> recommendations = const Value.absent(),
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> respiratoryRate = const Value.absent(),
                Value<double?> serviceFee = const Value.absent(),
                required DateTime examinedAt,
                Value<bool> followUpNeeded = const Value.absent(),
                Value<DateTime?> followUpDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicalRecordsCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                animalId: animalId,
                vetId: vetId,
                villageId: villageId,
                lat: lat,
                lng: lng,
                visitType: visitType,
                chiefComplaint: chiefComplaint,
                symptoms: symptoms,
                diagnosisNotes: diagnosisNotes,
                treatmentNotes: treatmentNotes,
                recommendations: recommendations,
                temperatureCelsius: temperatureCelsius,
                weightKg: weightKg,
                heartRate: heartRate,
                respiratoryRate: respiratoryRate,
                serviceFee: serviceFee,
                examinedAt: examinedAt,
                followUpNeeded: followUpNeeded,
                followUpDate: followUpDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicalRecordsTable,
      MedicalRecordRow,
      $$MedicalRecordsTableFilterComposer,
      $$MedicalRecordsTableOrderingComposer,
      $$MedicalRecordsTableAnnotationComposer,
      $$MedicalRecordsTableCreateCompanionBuilder,
      $$MedicalRecordsTableUpdateCompanionBuilder,
      (
        MedicalRecordRow,
        BaseReferences<_$AppDatabase, $MedicalRecordsTable, MedicalRecordRow>,
      ),
      MedicalRecordRow,
      PrefetchHooks Function()
    >;
typedef $$DrugsTableCreateCompanionBuilder =
    DrugsCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      required String name,
      Value<String?> activeIngredient,
      Value<String?> manufacturer,
      required String drugType,
      required String unit,
      Value<double?> packageSize,
      Value<bool> isVaccine,
      Value<int> rowid,
    });
typedef $$DrugsTableUpdateCompanionBuilder =
    DrugsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String> name,
      Value<String?> activeIngredient,
      Value<String?> manufacturer,
      Value<String> drugType,
      Value<String> unit,
      Value<double?> packageSize,
      Value<bool> isVaccine,
      Value<int> rowid,
    });

class $$DrugsTableFilterComposer extends Composer<_$AppDatabase, $DrugsTable> {
  $$DrugsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugType => $composableBuilder(
    column: $table.drugType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get packageSize => $composableBuilder(
    column: $table.packageSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVaccine => $composableBuilder(
    column: $table.isVaccine,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DrugsTableOrderingComposer
    extends Composer<_$AppDatabase, $DrugsTable> {
  $$DrugsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugType => $composableBuilder(
    column: $table.drugType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get packageSize => $composableBuilder(
    column: $table.packageSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVaccine => $composableBuilder(
    column: $table.isVaccine,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DrugsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DrugsTable> {
  $$DrugsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drugType =>
      $composableBuilder(column: $table.drugType, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get packageSize => $composableBuilder(
    column: $table.packageSize,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVaccine =>
      $composableBuilder(column: $table.isVaccine, builder: (column) => column);
}

class $$DrugsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DrugsTable,
          DrugRow,
          $$DrugsTableFilterComposer,
          $$DrugsTableOrderingComposer,
          $$DrugsTableAnnotationComposer,
          $$DrugsTableCreateCompanionBuilder,
          $$DrugsTableUpdateCompanionBuilder,
          (DrugRow, BaseReferences<_$AppDatabase, $DrugsTable, DrugRow>),
          DrugRow,
          PrefetchHooks Function()
        > {
  $$DrugsTableTableManager(_$AppDatabase db, $DrugsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DrugsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DrugsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DrugsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> activeIngredient = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String> drugType = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double?> packageSize = const Value.absent(),
                Value<bool> isVaccine = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrugsCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                name: name,
                activeIngredient: activeIngredient,
                manufacturer: manufacturer,
                drugType: drugType,
                unit: unit,
                packageSize: packageSize,
                isVaccine: isVaccine,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                required String name,
                Value<String?> activeIngredient = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                required String drugType,
                required String unit,
                Value<double?> packageSize = const Value.absent(),
                Value<bool> isVaccine = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DrugsCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                name: name,
                activeIngredient: activeIngredient,
                manufacturer: manufacturer,
                drugType: drugType,
                unit: unit,
                packageSize: packageSize,
                isVaccine: isVaccine,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DrugsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DrugsTable,
      DrugRow,
      $$DrugsTableFilterComposer,
      $$DrugsTableOrderingComposer,
      $$DrugsTableAnnotationComposer,
      $$DrugsTableCreateCompanionBuilder,
      $$DrugsTableUpdateCompanionBuilder,
      (DrugRow, BaseReferences<_$AppDatabase, $DrugsTable, DrugRow>),
      DrugRow,
      PrefetchHooks Function()
    >;
typedef $$StocksTableCreateCompanionBuilder =
    StocksCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      required String drugId,
      Value<double> currentQuantity,
      Value<double?> criticalThreshold,
      Value<double?> reorderQuantity,
      Value<DateTime?> lastPurchasedAt,
      Value<DateTime?> earliestExpiryAt,
      Value<int> rowid,
    });
typedef $$StocksTableUpdateCompanionBuilder =
    StocksCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String> drugId,
      Value<double> currentQuantity,
      Value<double?> criticalThreshold,
      Value<double?> reorderQuantity,
      Value<DateTime?> lastPurchasedAt,
      Value<DateTime?> earliestExpiryAt,
      Value<int> rowid,
    });

class $$StocksTableFilterComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugId => $composableBuilder(
    column: $table.drugId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentQuantity => $composableBuilder(
    column: $table.currentQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get criticalThreshold => $composableBuilder(
    column: $table.criticalThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderQuantity => $composableBuilder(
    column: $table.reorderQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPurchasedAt => $composableBuilder(
    column: $table.lastPurchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earliestExpiryAt => $composableBuilder(
    column: $table.earliestExpiryAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StocksTableOrderingComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugId => $composableBuilder(
    column: $table.drugId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentQuantity => $composableBuilder(
    column: $table.currentQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get criticalThreshold => $composableBuilder(
    column: $table.criticalThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderQuantity => $composableBuilder(
    column: $table.reorderQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPurchasedAt => $composableBuilder(
    column: $table.lastPurchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earliestExpiryAt => $composableBuilder(
    column: $table.earliestExpiryAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drugId =>
      $composableBuilder(column: $table.drugId, builder: (column) => column);

  GeneratedColumn<double> get currentQuantity => $composableBuilder(
    column: $table.currentQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get criticalThreshold => $composableBuilder(
    column: $table.criticalThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<double> get reorderQuantity => $composableBuilder(
    column: $table.reorderQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPurchasedAt => $composableBuilder(
    column: $table.lastPurchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get earliestExpiryAt => $composableBuilder(
    column: $table.earliestExpiryAt,
    builder: (column) => column,
  );
}

class $$StocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StocksTable,
          StockRow,
          $$StocksTableFilterComposer,
          $$StocksTableOrderingComposer,
          $$StocksTableAnnotationComposer,
          $$StocksTableCreateCompanionBuilder,
          $$StocksTableUpdateCompanionBuilder,
          (StockRow, BaseReferences<_$AppDatabase, $StocksTable, StockRow>),
          StockRow,
          PrefetchHooks Function()
        > {
  $$StocksTableTableManager(_$AppDatabase db, $StocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String> drugId = const Value.absent(),
                Value<double> currentQuantity = const Value.absent(),
                Value<double?> criticalThreshold = const Value.absent(),
                Value<double?> reorderQuantity = const Value.absent(),
                Value<DateTime?> lastPurchasedAt = const Value.absent(),
                Value<DateTime?> earliestExpiryAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                drugId: drugId,
                currentQuantity: currentQuantity,
                criticalThreshold: criticalThreshold,
                reorderQuantity: reorderQuantity,
                lastPurchasedAt: lastPurchasedAt,
                earliestExpiryAt: earliestExpiryAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                required String drugId,
                Value<double> currentQuantity = const Value.absent(),
                Value<double?> criticalThreshold = const Value.absent(),
                Value<double?> reorderQuantity = const Value.absent(),
                Value<DateTime?> lastPurchasedAt = const Value.absent(),
                Value<DateTime?> earliestExpiryAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                drugId: drugId,
                currentQuantity: currentQuantity,
                criticalThreshold: criticalThreshold,
                reorderQuantity: reorderQuantity,
                lastPurchasedAt: lastPurchasedAt,
                earliestExpiryAt: earliestExpiryAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StocksTable,
      StockRow,
      $$StocksTableFilterComposer,
      $$StocksTableOrderingComposer,
      $$StocksTableAnnotationComposer,
      $$StocksTableCreateCompanionBuilder,
      $$StocksTableUpdateCompanionBuilder,
      (StockRow, BaseReferences<_$AppDatabase, $StocksTable, StockRow>),
      StockRow,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      required String stockId,
      required String drugId,
      required String movementType,
      required double quantity,
      Value<double?> unitPrice,
      Value<DateTime?> expiryDate,
      Value<String?> supplierName,
      Value<int?> performedBy,
      required DateTime occurredAt,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String> stockId,
      Value<String> drugId,
      Value<String> movementType,
      Value<double> quantity,
      Value<double?> unitPrice,
      Value<DateTime?> expiryDate,
      Value<String?> supplierName,
      Value<int?> performedBy,
      Value<DateTime> occurredAt,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockId => $composableBuilder(
    column: $table.stockId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugId => $composableBuilder(
    column: $table.drugId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockId => $composableBuilder(
    column: $table.stockId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugId => $composableBuilder(
    column: $table.drugId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stockId =>
      $composableBuilder(column: $table.stockId, builder: (column) => column);

  GeneratedColumn<String> get drugId =>
      $composableBuilder(column: $table.drugId, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get performedBy => $composableBuilder(
    column: $table.performedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovementRow,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (
            StockMovementRow,
            BaseReferences<
              _$AppDatabase,
              $StockMovementsTable,
              StockMovementRow
            >,
          ),
          StockMovementRow,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String> stockId = const Value.absent(),
                Value<String> drugId = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> unitPrice = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String?> supplierName = const Value.absent(),
                Value<int?> performedBy = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                stockId: stockId,
                drugId: drugId,
                movementType: movementType,
                quantity: quantity,
                unitPrice: unitPrice,
                expiryDate: expiryDate,
                supplierName: supplierName,
                performedBy: performedBy,
                occurredAt: occurredAt,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                required String stockId,
                required String drugId,
                required String movementType,
                required double quantity,
                Value<double?> unitPrice = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<String?> supplierName = const Value.absent(),
                Value<int?> performedBy = const Value.absent(),
                required DateTime occurredAt,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                stockId: stockId,
                drugId: drugId,
                movementType: movementType,
                quantity: quantity,
                unitPrice: unitPrice,
                expiryDate: expiryDate,
                supplierName: supplierName,
                performedBy: performedBy,
                occurredAt: occurredAt,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovementRow,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (
        StockMovementRow,
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow>,
      ),
      StockMovementRow,
      PrefetchHooks Function()
    >;
typedef $$MedicalRecordDrugsTableCreateCompanionBuilder =
    MedicalRecordDrugsCompanion Function({
      required String id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      required String medicalRecordId,
      required String drugId,
      required double quantity,
      Value<String?> dosageInstructions,
      Value<int> rowid,
    });
typedef $$MedicalRecordDrugsTableUpdateCompanionBuilder =
    MedicalRecordDrugsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<DateTime?> lastModifiedAt,
      Value<String?> originDeviceId,
      Value<String?> clinicId,
      Value<LocalSyncStatus> localSyncStatus,
      Value<DateTime> localUpdatedAt,
      Value<String?> lastError,
      Value<bool> deletedLocal,
      Value<String> medicalRecordId,
      Value<String> drugId,
      Value<double> quantity,
      Value<String?> dosageInstructions,
      Value<int> rowid,
    });

class $$MedicalRecordDrugsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicalRecordDrugsTable> {
  $$MedicalRecordDrugsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, int>
  get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalRecordId => $composableBuilder(
    column: $table.medicalRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugId => $composableBuilder(
    column: $table.drugId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosageInstructions => $composableBuilder(
    column: $table.dosageInstructions,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicalRecordDrugsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicalRecordDrugsTable> {
  $$MedicalRecordDrugsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicId => $composableBuilder(
    column: $table.clinicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncStatus => $composableBuilder(
    column: $table.localSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalRecordId => $composableBuilder(
    column: $table.medicalRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugId => $composableBuilder(
    column: $table.drugId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosageInstructions => $composableBuilder(
    column: $table.dosageInstructions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicalRecordDrugsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicalRecordDrugsTable> {
  $$MedicalRecordDrugsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModifiedAt => $composableBuilder(
    column: $table.lastModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clinicId =>
      $composableBuilder(column: $table.clinicId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, int> get localSyncStatus =>
      $composableBuilder(
        column: $table.localSyncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocal => $composableBuilder(
    column: $table.deletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicalRecordId => $composableBuilder(
    column: $table.medicalRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drugId =>
      $composableBuilder(column: $table.drugId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get dosageInstructions => $composableBuilder(
    column: $table.dosageInstructions,
    builder: (column) => column,
  );
}

class $$MedicalRecordDrugsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicalRecordDrugsTable,
          MedicalRecordDrugRow,
          $$MedicalRecordDrugsTableFilterComposer,
          $$MedicalRecordDrugsTableOrderingComposer,
          $$MedicalRecordDrugsTableAnnotationComposer,
          $$MedicalRecordDrugsTableCreateCompanionBuilder,
          $$MedicalRecordDrugsTableUpdateCompanionBuilder,
          (
            MedicalRecordDrugRow,
            BaseReferences<
              _$AppDatabase,
              $MedicalRecordDrugsTable,
              MedicalRecordDrugRow
            >,
          ),
          MedicalRecordDrugRow,
          PrefetchHooks Function()
        > {
  $$MedicalRecordDrugsTableTableManager(
    _$AppDatabase db,
    $MedicalRecordDrugsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicalRecordDrugsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicalRecordDrugsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicalRecordDrugsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                Value<String> medicalRecordId = const Value.absent(),
                Value<String> drugId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> dosageInstructions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicalRecordDrugsCompanion(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                medicalRecordId: medicalRecordId,
                drugId: drugId,
                quantity: quantity,
                dosageInstructions: dosageInstructions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<DateTime?> lastModifiedAt = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<String?> clinicId = const Value.absent(),
                Value<LocalSyncStatus> localSyncStatus = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> deletedLocal = const Value.absent(),
                required String medicalRecordId,
                required String drugId,
                required double quantity,
                Value<String?> dosageInstructions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicalRecordDrugsCompanion.insert(
                id: id,
                version: version,
                lastModifiedAt: lastModifiedAt,
                originDeviceId: originDeviceId,
                clinicId: clinicId,
                localSyncStatus: localSyncStatus,
                localUpdatedAt: localUpdatedAt,
                lastError: lastError,
                deletedLocal: deletedLocal,
                medicalRecordId: medicalRecordId,
                drugId: drugId,
                quantity: quantity,
                dosageInstructions: dosageInstructions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicalRecordDrugsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicalRecordDrugsTable,
      MedicalRecordDrugRow,
      $$MedicalRecordDrugsTableFilterComposer,
      $$MedicalRecordDrugsTableOrderingComposer,
      $$MedicalRecordDrugsTableAnnotationComposer,
      $$MedicalRecordDrugsTableCreateCompanionBuilder,
      $$MedicalRecordDrugsTableUpdateCompanionBuilder,
      (
        MedicalRecordDrugRow,
        BaseReferences<
          _$AppDatabase,
          $MedicalRecordDrugsTable,
          MedicalRecordDrugRow
        >,
      ),
      MedicalRecordDrugRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
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
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaRow,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaRow,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>,
          ),
          SyncMetaRow,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaRow,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (SyncMetaRow, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>),
      SyncMetaRow,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String targetTable,
      required String recordId,
      required String resolution,
      Value<int?> serverVersion,
      Value<DateTime> observedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> targetTable,
      Value<String> recordId,
      Value<String> resolution,
      Value<int?> serverVersion,
      Value<DateTime> observedAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflictRow,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflictRow,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflictRow>,
          ),
          SyncConflictRow,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> resolution = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                resolution: resolution,
                serverVersion: serverVersion,
                observedAt: observedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetTable,
                required String recordId,
                required String resolution,
                Value<int?> serverVersion = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                targetTable: targetTable,
                recordId: recordId,
                resolution: resolution,
                serverVersion: serverVersion,
                observedAt: observedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflictRow,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflictRow,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflictRow>,
      ),
      SyncConflictRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db, _db.villages);
  $$FarmersTableTableManager get farmers =>
      $$FarmersTableTableManager(_db, _db.farmers);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db, _db.animals);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$MedicalRecordsTableTableManager get medicalRecords =>
      $$MedicalRecordsTableTableManager(_db, _db.medicalRecords);
  $$DrugsTableTableManager get drugs =>
      $$DrugsTableTableManager(_db, _db.drugs);
  $$StocksTableTableManager get stocks =>
      $$StocksTableTableManager(_db, _db.stocks);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$MedicalRecordDrugsTableTableManager get medicalRecordDrugs =>
      $$MedicalRecordDrugsTableTableManager(_db, _db.medicalRecordDrugs);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
}
