import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.phoneNumber,
    required this.balance,
    required this.created,
  });

  final String phoneNumber;
  final double balance;
  final DateTime created;

  @override
  List<Object?> get props => [phoneNumber, balance, created];
}
