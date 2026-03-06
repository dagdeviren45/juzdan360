// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PortfolioItemAdapter extends TypeAdapter<PortfolioItem> {
  @override
  final int typeId = 1;

  @override
  PortfolioItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortfolioItem(
      id: fields[0] as String,
      name: fields[1] as String,
      symbol: fields[2] as String,
      amount: fields[3] as double,
      category: fields[4] as PortfolioCategory,
      note: fields[5] as String?,
      dateAdded: fields[6] as DateTime,
      isPhysical: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PortfolioItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.dateAdded)
      ..writeByte(7)
      ..write(obj.isPhysical);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PortfolioCategoryAdapter extends TypeAdapter<PortfolioCategory> {
  @override
  final int typeId = 0;

  @override
  PortfolioCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PortfolioCategory.gold;
      case 1:
        return PortfolioCategory.silver;
      case 2:
        return PortfolioCategory.crypto;
      case 3:
        return PortfolioCategory.forex;
      case 4:
        return PortfolioCategory.debt;
      case 5:
        return PortfolioCategory.cash;
      default:
        return PortfolioCategory.gold;
    }
  }

  @override
  void write(BinaryWriter writer, PortfolioCategory obj) {
    switch (obj) {
      case PortfolioCategory.gold:
        writer.writeByte(0);
        break;
      case PortfolioCategory.silver:
        writer.writeByte(1);
        break;
      case PortfolioCategory.crypto:
        writer.writeByte(2);
        break;
      case PortfolioCategory.forex:
        writer.writeByte(3);
        break;
      case PortfolioCategory.debt:
        writer.writeByte(4);
        break;
      case PortfolioCategory.cash:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
