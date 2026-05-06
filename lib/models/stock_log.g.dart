// lib/models/stock_log.g.dart
part of 'stock_log.dart';

class StockLogAdapter extends TypeAdapter<StockLog> {
  @override
  final int typeId = 1;

  @override
  StockLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockLog(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      type: fields[3] as StockLogType,
      quantity: fields[4] as double,
      quantityBefore: fields[5] as double,
      quantityAfter: fields[6] as double,
      timestamp: fields[7] as DateTime,
      note: fields[8] as String?,
      synced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StockLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.quantityBefore)
      ..writeByte(6)
      ..write(obj.quantityAfter)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.synced);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class StockLogTypeAdapter extends TypeAdapter<StockLogType> {
  @override
  final int typeId = 2;

  @override
  StockLogType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StockLogType.stockIn;
      case 1:
        return StockLogType.stockOut;
      case 2:
        return StockLogType.adjustment;
      default:
        return StockLogType.stockIn;
    }
  }

  @override
  void write(BinaryWriter writer, StockLogType obj) {
    switch (obj) {
      case StockLogType.stockIn:
        writer.writeByte(0);
        break;
      case StockLogType.stockOut:
        writer.writeByte(1);
        break;
      case StockLogType.adjustment:
        writer.writeByte(2);
        break;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockLogTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
