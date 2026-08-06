import '../../domain/entities/user_entity.dart';

class UserModel {
  const UserModel({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'BankDump User',
      email: json['email']?.toString() ?? '',
    );
  }

  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email);
  }
}
