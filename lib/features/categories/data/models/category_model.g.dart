// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$CategoryTypeEnumMap, json['type']),
      colorValue: (json['color_value'] as num).toInt(),
      iconCode: (json['icon_code'] as num).toInt(),
      parentId: json['parentId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$CategoryTypeEnumMap[instance.type]!,
      'parentId': instance.parentId,
      'isActive': instance.isActive,
      'isPremium': instance.isPremium,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'color_value': instance.colorValue,
      'icon_code': instance.iconCode,
    };

const _$CategoryTypeEnumMap = {
  CategoryType.personal: 'personal',
  CategoryType.child: 'child',
  CategoryType.pet: 'pet',
  CategoryType.subscription: 'subscription',
  CategoryType.home: 'home',
  CategoryType.food: 'food',
};
