import 'package:equatable/equatable.dart';

/// Mirrors the API's `DirectoryUser` shape: `{ phoneNumber, created }`.
/// Deliberately has no balance — the directory endpoint never returns one.
class RecipientEntity extends Equatable {
  const RecipientEntity({required this.phoneNumber, required this.created});

  final String phoneNumber;
  final DateTime created;

  @override
  List<Object?> get props => [phoneNumber, created];
}
