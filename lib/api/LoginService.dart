import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pd_app/Constants.dart';
import 'package:pd_app/model/Session.dart';
import 'package:pd_app/prefs/SessionPrefs.dart';

class LoginService {
  static Future<Session> login(String username, String password) async {
    var url = Uri.http(Constants.BASE_HOST, "api/login");
    final response = await http.post(url, body: {'username': username, 'password': password});
    return Session.fromJson(jsonDecode(response.body));
  }

  static Future<Session> refresh() async {
    var url = Uri.http(Constants.BASE_HOST, "api/token/refresh");
    var session = await SessionPrefs.getSession();
    final response = await http.post(url, headers: {'Authorization': "Bearer ${session!.access}"}, body: {'refresh': session.refresh});
    return Session(
        access: jsonDecode(response.body)['access'],
        refresh: session.refresh,
        username: session.username
    );
  }

  static Future<Session> staffLogin(String username, String password) async {
    var url = Uri.http(Constants.BASE_HOST, "api/medical_staff_login");
    final response = await http.post(url, body: {'username': username, 'password': password});
    return Session.fromJson(jsonDecode(response.body));
  }

  static Future<Session> google_login(String token) async {
    var url = Uri.http(Constants.BASE_HOST, "api/google_login");
    final response = await http.post(url, body: {'token': token});
    return Session.fromJson(jsonDecode(response.body));
  }
}
