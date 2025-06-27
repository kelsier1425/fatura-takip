import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    String? name,
    String? photoUrl,
    required DateTime createdAt,
    DateTime? lastLoginAt,
    bool isPremium = false,
    String? subscriptionType,
    DateTime? subscriptionEndDate,
  }) : super(
    id: id,
    email: email,
    name: name,
    photoUrl: photoUrl,
    createdAt: createdAt,
    lastLoginAt: lastLoginAt,
    isPremium: isPremium,
    subscriptionType: subscriptionType,
    subscriptionEndDate: subscriptionEndDate,
  );
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isPremium: entity.isPremium,
      subscriptionType: entity.subscriptionType,
      subscriptionEndDate: entity.subscriptionEndDate,
    );
  }
}