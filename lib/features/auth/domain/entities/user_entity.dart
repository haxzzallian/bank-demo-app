import 'package:equatable/equatable.dart';

/// Mirrors the API's `User` shape exactly: `{ phoneNumber, balance, created }`.
/// The phone number doubles as the account number — there is no separate
/// name, email, or account-type field anywhere in the API.
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
