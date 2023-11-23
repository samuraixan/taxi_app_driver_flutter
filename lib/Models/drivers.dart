import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

class Drivers {
  String? name;
  String? phone;
  String? email;
  String? id;
  String? car_color;
  String? car_model;
  String? car_number;

  Drivers({this.name, this.phone, this.email, this.id, this.car_color, this.car_model, this.car_number});

  Drivers.fromSnapshot(DataSnapshot dataSnapshot) {
    // Map<String, dynamic> data = dataSnapshot.value as Map<String, dynamic>;
    Map<String, dynamic> data = jsonDecode(jsonEncode(dataSnapshot.value));
    id = dataSnapshot.key;
    phone = data['phone'];
    email = data['email'];
    name = data['name'];
    car_color = data['car_details']['car_color'];
    car_model = data['car_details']['car_model'];
    car_number = data['car_details']['car_number'];
  }
}