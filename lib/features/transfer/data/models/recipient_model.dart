import '../../domain/entities/recipient_entity.dart';

class RecipientModel {
  const RecipientModel({required this.phoneNumber, required this.created});

  final String phoneNumber;
  final DateTime created;

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      created:
          DateTime.tryParse(json['created']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  RecipientEntity toEntity() {
    return RecipientEntity(phoneNumber: phoneNumber, created: created);
  }
}
