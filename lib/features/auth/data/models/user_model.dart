import '../../domain/entities/user_entity.dart';

class UserModel {
  const UserModel({
    required this.phoneNumber,
    required this.balance,
    required this.created,
  });

  final String phoneNumber;
  final double balance;
  final DateTime created;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      created:
          DateTime.tryParse(json['created']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      phoneNumber: phoneNumber,
      balance: balance,
      created: created,
    );
  }
}
