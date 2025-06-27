import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isPremium;
  final String? subscriptionType;
  final DateTime? subscriptionEndDate;
  
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.subscriptionType,
    this.subscriptionEndDate,
  });
  
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    createdAt,
    lastLoginAt,
    isPremium,
    subscriptionType,
    subscriptionEndDate,
  ];
}