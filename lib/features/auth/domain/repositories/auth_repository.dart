import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signIn({required String email, required String password});
  Future<UserEntity> signUp({required String email, required String password, String? name});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<void> updateProfile({String? name, String? photoUrl});
  Stream<UserEntity?> get authStateChanges;
}