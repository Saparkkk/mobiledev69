import 'dart:convert';

class AppointmentModel {
  final String id;
  final String houseName;
  final String date;
  final String phone;

  AppointmentModel({
    required this.id,
    required this.houseName,
    required this.date,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'houseName': houseName,
      'date': date,
      'phone': phone,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      houseName: map['houseName'],
      date: map['date'],
      phone: map['phone'],
    );
  }

  String toJson() => json.encode(toMap());
  factory AppointmentModel.fromJson(String source) => AppointmentModel.fromMap(json.decode(source));
}