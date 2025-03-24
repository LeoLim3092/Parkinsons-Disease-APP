import 'package:flutter/cupertino.dart';

class Patient {
  String? name;
  String? patientId;
  bool? takingPdMedicine;
  int? gender_code;
  int? age;
  String? gender;

  Patient(
      { this.name,
        this.patientId,
        this.takingPdMedicine,
        this.gender,
        this.age});

  Patient.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    patientId = json['patientId'].toString();
    takingPdMedicine = json['taking_pd_medicine'];
    gender_code = json['gender'];
    if (gender_code == 1)
      gender = "男";
    else
      gender = '女';
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['patientId'] = this.patientId;
    data['taking_pd_medicine'] = this.takingPdMedicine;
    data['gender'] = this.gender;
    data['age'] = this.age;
    return data;
  }
}
