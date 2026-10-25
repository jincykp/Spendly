// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';


class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final typeId = 20;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      category: fields[0] as String,
      limit: (fields[1] as num).toDouble(),
      isMonthly: fields[2] == null ? false : fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.limit)
      ..writeByte(2)
      ..write(obj.isMonthly);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
