import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends CategoryEntity {
  @JsonKey(name: 'color_value')
  final int colorValue;
  
  @JsonKey(name: 'icon_code')
  final int iconCode;
  
  const CategoryModel({
    required String id,
    required String name,
    String? description,
    required CategoryType type,
    required this.colorValue,
    required this.iconCode,
    String? parentId,
    bool isActive = true,
    bool isPremium = false,
    int sortOrder = 0,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
    id: id,
    name: name,
    description: description,
    type: type,
    color: Color(colorValue),
    icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
    parentId: parentId,
    isActive: isActive,
    isPremium: isPremium,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
  
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      colorValue: entity.color.value,
      iconCode: entity.icon.codePoint,
      parentId: entity.parentId,
      isActive: entity.isActive,
      isPremium: entity.isPremium,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}