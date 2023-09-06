import 'dart:convert';
import 'package:pd_app/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/prefs/SessionPrefs.dart';

class PatientService {
  static Utf8Decoder decoder = const Utf8Decoder();
  static Future<List<Patient>> getPatientList() async {
    var session = await SessionPrefs.getSession();
    var url = Uri.http(Constants.BASE_HOST, "api/patient/");
    var response = await http.get(url, headers: {'Authorization' : "Bearer ${session!.access}"});
    List jsonArray = jsonDecode(decoder.convert(response.bodyBytes));
    return jsonArray.map((e) => Patient.fromJson(e)).toList();

  }

  static Future<Patient> getPatientData(String user_name) async {
    var session = await SessionPrefs.getSession();
    var url = Uri.http(Constants.BASE_HOST, "api/get_user_data", {'user_name': user_name});
    var response = await http.get(url, headers: {'Authorization' : "Bearer ${session!.access}"});

    if (response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load patient');
    }
  }
}
