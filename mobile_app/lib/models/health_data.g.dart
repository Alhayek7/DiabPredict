// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthDataAdapter extends TypeAdapter<HealthData> {
  @override
  final int typeId = 0;

  @override
  HealthData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthData(
      age: fields[0] as int,
      bmi: fields[1] as double,
      hba1c: fields[2] as double,
      glucose: fields[3] as double,
      bloodPressureSystolic: fields[4] as double,
      bloodPressureDiastolic: fields[5] as double,
      cholesterol: fields[6] as double,
      familyHistory: fields[7] as int,
      smoking: fields[8] as int,
      physicalActivity: fields[9] as int,
      waistCircumference: fields[10] as double,
      hba1cDetailed: fields[11] as double?,
      timestamp: fields[12] as DateTime?,
      synced: fields[13] as bool,
      localRisk: fields[14] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthData obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.age)
      ..writeByte(1)
      ..write(obj.bmi)
      ..writeByte(2)
      ..write(obj.hba1c)
      ..writeByte(3)
      ..write(obj.glucose)
      ..writeByte(4)
      ..write(obj.bloodPressureSystolic)
      ..writeByte(5)
      ..write(obj.bloodPressureDiastolic)
      ..writeByte(6)
      ..write(obj.cholesterol)
      ..writeByte(7)
      ..write(obj.familyHistory)
      ..writeByte(8)
      ..write(obj.smoking)
      ..writeByte(9)
      ..write(obj.physicalActivity)
      ..writeByte(10)
      ..write(obj.waistCircumference)
      ..writeByte(11)
      ..write(obj.hba1cDetailed)
      ..writeByte(12)
      ..write(obj.timestamp)
      ..writeByte(13)
      ..write(obj.synced)
      ..writeByte(14)
      ..write(obj.localRisk);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
