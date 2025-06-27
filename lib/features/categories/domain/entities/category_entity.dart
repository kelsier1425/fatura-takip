import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CategoryType {
  personal,
  child,
  pet,
  subscription,
  home,
  food,
  professional,
  health,
  technology,
  digital,
  gaming,
  vehicle,
}

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final CategoryType type;
  final Color color;
  final IconData icon;
  final String? parentId;
  final String? subParentId; // Alt-alt kategoriler için
  final bool isActive;
  final bool isPremium;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.color,
    required this.icon,
    this.parentId,
    this.subParentId,
    this.isActive = true,
    this.isPremium = false,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });
  
  bool get isSubcategory => parentId != null && subParentId == null;
  bool get isMainCategory => parentId == null && subParentId == null;
  bool get isSubSubcategory => subParentId != null;
  
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    CategoryType? type,
    Color? color,
    IconData? icon,
    String? parentId,
    String? subParentId,
    bool? isActive,
    bool? isPremium,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      subParentId: subParentId ?? this.subParentId,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    color,
    icon,
    parentId,
    subParentId,
    isActive,
    isPremium,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}