import 'package:equatable/equatable.dart';

class RecipientEntity extends Equatable {
  const RecipientEntity({required this.phoneNumber, required this.created});

  final String phoneNumber;
  final DateTime created;

  @override
  List<Object?> get props => [phoneNumber, created];
}
